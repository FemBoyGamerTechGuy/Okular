/* driver.c — the compile pipeline: load, lex, parse, sema, IR, codegen,
 * assemble (as), link (ld). Freestanding executables; no libc in output. */
#define _POSIX_C_SOURCE 200809L
#include "ok/driver.h"
#include "ok/project.h"
#include "ok/sema.h"
#include "ok/ir.h"
#include "ok/codegen.h"
#include "ok/selfhost.h"
#include "ok/parser.h"
#include "ok/ast.h"
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>

/* the bootstrap runtime shim lives next to the okular executable (or one
 * or two levels up — the binary commonly sits in build/) */
static char g_rt_path[4096];

static const char *runtime_obj_path(void) {
    const char *fallback = "runtime/rt.o";
    char exe[4096];
    ssize_t n = readlink("/proc/self/exe", exe, sizeof exe - 1);
    if (n < 0) return fallback;
    exe[n] = 0;
    char *slash = strrchr(exe, '/');
    if (!slash) return fallback;
    /* try <dir>/runtime/rt.o, <dir>/../runtime/rt.o, <dir>/../../runtime/rt.o */
    for (int up = 0; up < 3; up++) {
        snprintf(g_rt_path, sizeof g_rt_path, "%s", exe);
        for (int k = 0; k < up; k++) {
            char *s = strrchr(g_rt_path, '/');
            if (!s || s == g_rt_path) break;
            *s = 0;
        }
        char *s = strrchr(g_rt_path, '/');
        if (!s) continue;
        s[1] = 0;
        size_t used = strlen(g_rt_path);
        snprintf(g_rt_path + used, sizeof g_rt_path - used, "runtime/rt.o");
        if (access(g_rt_path, F_OK) == 0)
            return g_rt_path;
    }
    return fallback;
}

static int run_tool(const char *argv[], const char *what) {
    /* quiet: capture nothing; as/ld report their own errors on stderr */
    fflush(NULL);
    pid_t pid = fork();
    if (pid < 0) {
        fprintf(stderr, "okular: fork failed (%s)\n", what);
        return -1;
    }
    if (pid == 0) {
        execvp(argv[0], (char *const *)argv);
        fprintf(stderr, "okular: cannot run %s (`%s`)\n", what, argv[0]);
        _exit(127);
    }
    int st;
    if (waitpid(pid, &st, 0) < 0) return -1;
    if (WIFEXITED(st)) return WEXITSTATUS(st);
    return -1;
}

static void ensure_dir(const char *path) {
    /* best-effort mkdir -p for build output (brief §65: never touch sources) */
    char *tmp = ok_xstrdup(path);
    for (char *p = tmp + 1; *p; p++) {
        if (*p == '/') {
            *p = 0;
            mkdir(tmp, 0755);
            *p = '/';
        }
    }
    mkdir(tmp, 0755);
    free(tmp);
}

int driver_compile(OkOptions *opt) {
    DiagEngine de;
    diag_init(&de);
    de.force_warning = false;

    /* M4 bridge: route tokenization through the Okular-written lexer when
     * requested (--selfhost-lex); set before anything lexes a file */
    selfhost_set_lexer(opt->selfhost_lex);
    /* M4 bridge: route parsing through the Okular-written parser when
     * requested (--selfhost-parse) */
    selfhost_set_parser(opt->selfhost_parse);

    /* --selfhost-verify BIN: differential testing — every module is
     * parsed BOTH ways and the machine AST serializations compared byte
     * for byte. Equal streams mean identical trees: the Okular parser
     * is a drop-in replacement for the C one on this input. */
    if (opt->selfhost_verify) {
        /* the project itself parses in C (the reference); each module is
         * then re-parsed through the Okular binary and compared */
        selfhost_set_parser(NULL);
        OkProject *proj = project_load(opt->main_path, &de, false);
        selfhost_set_parser(opt->selfhost_verify);
        if (!proj) {
            diag_render_all(&de);
            diag_free(&de);
            return 2;
        }
        size_t mismatches = 0, compared = 0;
        for (size_t i = 0; i < proj->modules.len; i++) {
            OkModule *m = proj->modules.items[i];
            if (!m->src || m->state == MOD_FAILED) continue;

            /* C side: serialize the already-parsed tree */
            Buf want;
            buf_init(&want);
            ast_serialize(m->ast, &want);

            /* Okular side: the bridge parse of the same file */
            size_t mark = de.errors;
            Arena *ar = arena_new();
            Node *theirs = selfhost_parse_file(m->src, m->path, &de, ar);
            if (de.errors > mark || !theirs) {
                diag_emit(&de, DIAG_ERROR, m->src, 1, 1,
                          "selfhost verify: the Okular parser failed on `%s` where the C parser succeeded.",
                          m->display);
                mismatches++;
                arena_free(ar);
                buf_free(&want);
                continue;
            }
            Buf got;
            buf_init(&got);
            ast_serialize(theirs, &got);
            compared++;
            if (want.len != got.len ||
                (want.len > 0 && memcmp(want.data, got.data, want.len) != 0)) {
                size_t at = 0;
                size_t limit = want.len < got.len ? want.len : got.len;
                while (at < limit && want.data[at] == got.data[at]) at++;
                Diag *d = diag_emit(&de, DIAG_ERROR, m->src, 1, 1,
                                    "selfhost verify: the Okular parser's AST differs from the C parser's at byte %zu of `%s`.",
                                    at, m->display);
                (void)d;
                mismatches++;
            }
            arena_free(ar);
            buf_free(&want);
            buf_free(&got);
        }
        fprintf(stderr,
                "selfhost verify: %zu module(s) compared, %zu mismatch(es).\n",
                compared, mismatches);
        diag_render_all(&de);
        project_free(proj);
        diag_free(&de);
        return mismatches ? 1 : 0;
    }

    /* debug dumps that only need the front end */
    if (opt->dump_tokens || opt->dump_ast) {
        SourceFile *f = source_load(opt->main_path, "main.ok");
        if (!f) {
            fprintf(stderr, "okular: cannot read `%s`\n", opt->main_path);
            diag_free(&de);
            return 2;
        }
        TokList *toks = selfhost_enabled() ? selfhost_lex_file(f, opt->main_path, &de)
                                           : lex_file(f, &de);
        if (opt->dump_tokens) {
            printf("== TOKENS: main.ok ==\n");
            for (size_t i = 0; i < toks->len; i++) {
                Tok *t = &toks->items[i];
                printf("%4zu %3zu:%-3zu %-14s", i, t->line, t->col, tok_kind_name(t->kind));
                if (t->kind == T_IDENT || t->kind == T_KW_RESERVED) printf(" %s", t->text);
                else if (t->kind == T_TEXT) printf(" \"%s\" (%zu)", t->text, t->slen);
                else if (t->kind == T_INT) printf(" %llu", (unsigned long long)t->ival);
                else if (t->kind == T_DEC) printf(" %g", t->dval);
                printf("\n");
            }
        }
        if (opt->dump_ast && de.errors == 0) {
            Arena *ar = arena_new();
            Node *ast = parse_file_tokens(toks, f, &de, ar);
            ast_dump(ast, "main.ok");
            arena_free(ar);
        }
        toklist_free(toks);
        free(f->path); free(f->name); free(f->data); free(f->line_off); free(f);
        diag_render_all(&de);
        int rc = de.errors ? 1 : 0;
        diag_free(&de);
        return rc;
    }

    /* 1. project + front end */
    OkProject *proj = project_load(opt->main_path, &de, opt->strict);
    if (!proj) {
        diag_render_all(&de);
        diag_free(&de);
        return 2;
    }

    if (opt->dump_symbols) {
        /* quick symbol sketch via sema collect */
        (void)proj;
    }

    /* 2. semantic analysis (collect + check, with optional-source policy) */
    sema_run(proj, &de, opt);

    /* 3. library existence checks (spec §6.3) */
    project_check_libs(proj, &de, opt->strict);

    /* failures that matter? */
    bool required_broken = false;
    for (size_t i = 0; i < proj->modules.len; i++) {
        OkModule *m = proj->modules.items[i];
        if (m->broken && (m->required || opt->strict)) required_broken = true;
        if (m->broken && !m->required && !opt->strict) {
            /* already downgraded to warnings by the loader/sema */
        }
    }
    if (de.errors > 0 || required_broken) {
        diag_render_all(&de);
        fprintf(stderr, "okular: compilation failed; no executable was produced.\n");
        project_free(proj);
        diag_free(&de);
        return 1;
    }

    /* 4. IR for required modules only (optional modules are not linked) */
    Vec irs; vec_init(&irs);
    for (size_t i = 0; i < proj->modules.len; i++) {
        OkModule *m = proj->modules.items[i];
        if (!m->required) continue;
        IrModule *im = ir_build_module(m);
        if (im) {
            vec_push(&irs, im);
            if (opt->dump_ir) ir_dump(im);
        }
    }

    /* main module must exist (entry) */
    if (!proj->main_mod->entry && proj->main_mod->state == MOD_LOADED) {
        /* no top-level statements: still fine — empty program */
    }

    /* 5. codegen to build/objects (one .s per module) */
    char *bld = ok_path_join(proj->root, "build");
    char *objs = ok_path_join(bld, "objects");
    char *outd = ok_path_join(bld, "output");
    ensure_dir(objs);
    ensure_dir(outd);

    Vec obj_files; vec_init(&obj_files);
    for (size_t i = 0; i < irs.len; i++) {
        IrModule *im = irs.items[i];
        char sname[256], oname[256];
        snprintf(sname, sizeof sname, "%s/%s.s", objs, im->mod->name);
        snprintf(oname, sizeof oname, "%s/%s.o", objs, im->mod->name);
        if (opt->emit_asm_only) {
            if (!codegen_module(im, sname))
                fprintf(stderr, "okular: cannot write `%s`\n", sname);
            continue;
        }
        if (!codegen_module(im, sname)) {
            fprintf(stderr, "okular: cannot write `%s`\n", sname);
            continue;
        }
        const char *as_argv[] = { "as", "--64", "-o", oname, sname, NULL };
        if (run_tool(as_argv, "assembler") != 0) {
            fprintf(stderr, "okular: assembly failed for module `%s` (`as` reported the error above).\n",
                    im->mod->name);
            project_free(proj);
            diag_free(&de);
            return 1;
        }
        vec_push(&obj_files, ok_xstrdup(oname));
    }

    if (opt->emit_asm_only) {
        fprintf(stderr, "okular: --emit-asm: wrote assembly to %s (no executable)\n", objs);
        project_free(proj);
        diag_free(&de);
        return 0;
    }

    /* 6. link: objects + bootstrap runtime shim (freestanding, no libc) */
    const char *outname = opt->output;
    char defout[512];
    if (!outname) {
        snprintf(defout, sizeof defout, "%s/%s", outd, proj->main_mod->name);
        outname = defout;
    }

    {
        /* build argv: ld -o out rt.o obj... */
        size_t n = 4 + obj_files.len + 1;
        const char **ld_argv = ok_xmalloc(n * sizeof(char *));
        size_t k = 0;
        ld_argv[k++] = "ld";
        ld_argv[k++] = "-o";
        ld_argv[k++] = outname;
        ld_argv[k++] = runtime_obj_path();
        for (size_t i = 0; i < obj_files.len; i++)
            ld_argv[k++] = obj_files.items[i];
        ld_argv[k++] = NULL;
        if (run_tool(ld_argv, "linker") != 0) {
            fprintf(stderr, "okular: linking failed (`ld` reported the error above).\n");
            free(ld_argv);
            project_free(proj);
            diag_free(&de);
            return 1;
        }
        free(ld_argv);
    }

    /* report skipped optional modules (normal mode summary) */
    for (size_t i = 0; i < proj->modules.len; i++) {
        OkModule *m = proj->modules.items[i];
        if (m->broken && !m->required) {
            fprintf(stderr, "okular: note: src/%s.ok was skipped (broken and unused; --strict makes this fatal).\n",
                    m->name);
        }
    }

    if (!opt->output)
        fprintf(stderr, "okular: wrote %s\n", outname);

    /* render diagnostics while the project (and its source files) are still
     * alive — they are referenced from every located diagnostic */
    diag_render_all(&de);

    /* report skipped optional modules (normal mode summary) */
    for (size_t i = 0; i < proj->modules.len; i++) {
        OkModule *m = proj->modules.items[i];
        if (m->broken && !m->required) {
            fprintf(stderr, "okular: note: src/%s.ok was skipped (broken and unused; --strict makes this fatal).\n",
                    m->name);
        }
    }

    for (size_t i = 0; i < obj_files.len; i++) free(obj_files.items[i]);
    vec_free(&obj_files);
    for (size_t i = 0; i < irs.len; i++) ir_module_free(irs.items[i]);
    vec_free(&irs);
    free(bld); free(objs); free(outd);
    project_free(proj);
    diag_free(&de);
    return 0;
}
