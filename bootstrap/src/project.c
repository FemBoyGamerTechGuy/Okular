/* project.c — project discovery, module graph, optional-source policy. */
#include "ok/project.h"
#include "ok/lexer.h"
#include "ok/selfhost.h"
#include <dirent.h>
#include <sys/stat.h>

/* ---------------- module loading ---------------- */

static OkModule *module_new(OkProject *p, const char *name, const char *path,
                            const char *display, bool required) {
    OkModule *m = ok_xmalloc(sizeof *m);
    memset(m, 0, sizeof *m);
    m->name = ok_xstrdup(name);
    m->path = ok_xstrdup(path);
    m->display = ok_xstrdup(display);
    m->required = required;
    m->state = MOD_LOADING;
    vec_init(&m->uses);
    vec_push(&p->modules, m);
    return m;
}

/* Extract `[source.files.use]` and `[libs.use]` items from a token stream.
 * A light, tolerant scan: only trusts well-formed columns; the real parser
 * reports syntax problems in malformed ones. */
static void prescan_columns(TokList *toks, Vec *uses, StrVec *libs) {
    for (size_t i = 0; i < toks->len; i++) {
        Tok *t = &toks->items[i];
        if (t->kind != T_LBRACKET) continue;

        /* path: IDENT ( T_DOT IDENT )* T_RBRACKET */
        char pathbuf[128]; size_t pn = 0;
        size_t j = i + 1;
        if (j >= toks->len || toks->items[j].kind != T_IDENT) continue;
        pn = snprintf(pathbuf, sizeof pathbuf, "%s", toks->items[j].text);
        j++;
        while (j + 1 < toks->len && toks->items[j].kind == T_DOT &&
               toks->items[j + 1].kind == T_IDENT) {
            size_t left = sizeof pathbuf - pn - 1;
            pn += snprintf(pathbuf + pn, left > 0 ? left : 0, ".%s", toks->items[j + 1].text);
            j += 2;
        }
        if (j >= toks->len || toks->items[j].kind != T_RBRACKET) continue;
        j++;
        if (j >= toks->len || toks->items[j].kind != T_EQ) continue;
        j++;
        if (j >= toks->len || toks->items[j].kind != T_LBRACE) continue;
        j++;

        /* items: T_TEXT (, T_TEXT)* } */
        bool want_source = strcmp(pathbuf, "source.files.use") == 0;
        bool want_libs = strcmp(pathbuf, "libs.use") == 0;
        while (j < toks->len) {
            Tok *it = &toks->items[j];
            if (it->kind == T_TEXT) {
                if (want_source) vec_push(uses, ok_xstrdup(it->text));
                if (want_libs) svec_push(libs, ok_xstrdup(it->text));
            } else if (it->kind == T_COMMA || it->kind == T_NL) {
                /* separators */
            } else break;
            j++;
        }
        i = j; /* continue scanning after the column */
    }
}

/* Lex one module (phase A of the two-phase load: every file is lexed and
 * dependency-scanned BEFORE any file is parsed, so struct names declared
 * anywhere in the project resolve everywhere — spec §8.3 flat type
 * namespace). Records diagnostics; sets m->broken. The module stays
 * MOD_LOADING after a successful lex until its dependencies have been
 * expanded — that is what makes cycle detection work. */
static void module_lex(OkModule *m, DiagEngine *de) {
    m->err_watermark = de->errors;
    m->src = source_load(m->path, m->display);
    if (!m->src) {
        diag_error(de, NULL, 0, 0, "cannot read `%s`.", m->path);
        m->state = MOD_FAILED;
        m->broken = true;
        return;
    }
    /* M4 bridge: --selfhost-lex routes tokenization through the
     * Okular-written lexer (docs/roadmap.md); otherwise the C lexer.
     * m->path is the real filesystem path (m->src->path is a display name) */
    m->toks = selfhost_enabled() ? selfhost_lex_file(m->src, m->path, de)
                                 : lex_file(m->src, de);
    if (de->errors > m->err_watermark) {
        m->state = MOD_FAILED;
        m->broken = true;
        return; /* parser output would be garbage */
    }
}

/* Parse one module (phase B): the parser's struct-name registry has been
 * seeded from every module's tokens by the caller. */
static void module_parse(OkModule *m, DiagEngine *de) {
    if (m->state == MOD_FAILED || !m->toks) return;
    size_t mark = de->errors;
    m->arena = arena_new();
    m->ast = parse_file_tokens(m->toks, m->src, de, m->arena);
    if (de->errors > mark) {
        m->state = MOD_FAILED;
        m->broken = true;
    }
}

/* Load `name` from src/ recursively; cycle detection via MOD_LOADING. */
static OkModule *load_source_module(OkProject *p, DiagEngine *de,
                                    const char *name, const char *via_display,
                                    bool required, bool downgrade);

static void expand_module_deps(OkProject *p, OkModule *m, DiagEngine *de,
                               bool downgrade) {
    Vec uses = m->uses;
    for (size_t i = 0; i < uses.len; i++) {
        const char *dep = uses.items[i];
        OkModule *existing = project_find(p, dep);
        if (existing) {
            if (existing->state == MOD_LOADING) {
                diag_error(de, NULL, 0, 0,
                           "cyclic source dependency: `%s` is being loaded (directly or indirectly) through `%s` — cycles are not allowed.",
                           dep, m->display);
            } else if (existing->required && !m->required) {
                /* an optional module pulling a required one: fine */
            }
            continue;
        }
        load_source_module(p, de, dep, m->display, m->required, downgrade);
    }
}

static OkModule *load_source_module(OkProject *p, DiagEngine *de,
                                    const char *name, const char *via_display,
                                    bool required, bool downgrade) {
    char *src_path = ok_path_join(p->root, "src");
    char *file = ok_xmalloc(strlen(name) + 4);
    sprintf(file, "%s.ok", name);
    char *full = ok_path_join(src_path, file);
    free(file); free(src_path);

    char *display = ok_xmalloc(strlen(name) + 16);
    sprintf(display, "src/%s.ok", name);

    bool saved = de->force_warning;
    if (downgrade) de->force_warning = true;

    struct stat st;
    if (stat(full, &st) != 0) {
        diag_error(de, NULL, 0, 0,
                   "source file `%s` was not found in `src/` (used by `%s`).",
                   name, via_display);
        if (downgrade) de->force_warning = saved;
        free(full); free(display);
        return NULL;
    }

    OkModule *m = module_new(p, name, full, display, required);
    module_lex(m, de);
    if (m->state == MOD_LOADING) {
        prescan_columns(m->toks, &m->uses, &p->libs);
        expand_module_deps(p, m, de, downgrade);
        if (m->state == MOD_LOADING)
            m->state = MOD_LOADED;
    }

    if (downgrade) {
        de->force_warning = saved;
        if (m->broken) {
            Diag *d = diag_warn(de, NULL, 0, 0,
                                "src/%s.ok failed to compile, but it is not used by the project — skipped.",
                                name);
            diag_note(d, "use `--strict` (`-s`) to make failures in unused source files fatal.");
            diag_note(d, "failures above were reported as warnings for this file only.");
        }
    }
    free(full); free(display);
    return m;
}

/* ---------------- project ---------------- */

OkProject *project_load(const char *main_path, DiagEngine *de, bool strict) {
    OkProject *p = ok_xmalloc(sizeof *p);
    memset(p, 0, sizeof *p);
    vec_init(&p->modules);
    svec_init(&p->libs);
    p->main_path = ok_xstrdup(main_path);

    /* root = directory of main.ok ("" for bare names) */
    const char *slash = strrchr(main_path, '/');
    if (slash) p->root = ok_xstrndup(main_path, (size_t)(slash - main_path));
    else p->root = ok_xstrdup(".");

    /* main module */
    const char *base = ok_path_basename(main_path);
    if (strcmp(base, "main.ok") != 0) {
        Diag *d = diag_error_noloc(de,
            "the entry point must be `main.ok`, but `%s` was given.", base);
        diag_note(d, "Okular projects are rooted at a `main.ok` file (specs/spec-v0.2.md §2).");
        free(p->root); free(p->main_path); free(p);
        return NULL;
    }

    OkModule *main_mod = module_new(p, "main", main_path, "main.ok", true);
    p->main_mod = main_mod;
    module_lex(main_mod, de);
    if (main_mod->state == MOD_LOADING) {
        prescan_columns(main_mod->toks, &main_mod->uses, &p->libs);
        expand_module_deps(p, main_mod, de, false);
        if (main_mod->state == MOD_LOADING)
            main_mod->state = MOD_LOADED;
    }

    /* discover optional src/ files not already loaded (brief §36) */
    char *srcdir = ok_path_join(p->root, "src");
    DIR *d = opendir(srcdir);
    if (d) {
        struct dirent *ent;
        while ((ent = readdir(d)) != NULL) {
            if (!ok_has_ext(ent->d_name, "ok")) continue;
            char *nm = ok_path_noext(ent->d_name);
            if (strcmp(nm, "main") == 0) { free(nm); continue; }
            if (project_find(p, nm)) { free(nm); continue; }
            load_source_module(p, de, nm, "(optional scan)", false, !strict);
            free(nm);
        }
        closedir(d);
    }
    free(srcdir);

    /* phase B: seed the parser's struct-name registry from every module's
     * tokens, then parse all modules (spec §8.3 — struct types form one
     * flat namespace across files) */
    for (size_t i = 0; i < p->modules.len; i++) {
        OkModule *m = p->modules.items[i];
        if (m->toks) parser_register_struct_names(m->toks);
    }
    for (size_t i = 0; i < p->modules.len; i++) {
        OkModule *m = p->modules.items[i];
        module_parse(m, de);
    }

    return p;
}

void project_finish_optional(OkProject *p, DiagEngine *de, bool strict) {
    (void)p; (void)de; (void)strict;
    /* policy is applied at load/compile time; kept as an API seam for the
     * sema phase (driver marks m->broken there directly). */
}

OkModule *project_find(OkProject *p, const char *name) {
    for (size_t i = 0; i < p->modules.len; i++) {
        OkModule *m = p->modules.items[i];
        if (strcmp(m->name, name) == 0) return m;
    }
    return NULL;
}

/* ---------------- libs ---------------- */

static bool dir_exists(const char *path) {
    struct stat st;
    return stat(path, &st) == 0 && S_ISDIR(st.st_mode);
}
static bool file_exists(const char *path) {
    struct stat st;
    return stat(path, &st) == 0 && S_ISREG(st.st_mode);
}

void project_check_libs(OkProject *p, DiagEngine *de, bool strict) {
    /* dedupe */
    StrVec seen; svec_init(&seen);
    for (size_t i = 0; i < p->libs.len; i++) {
        const char *name = p->libs.items[i];
        if (svec_contains(&seen, name)) continue;
        svec_push(&seen, ok_xstrdup(name));

        char *a = ok_path_join(p->root, "libs");
        char *b = ok_path_join(a, name);
        char *c = ok_xmalloc(strlen(b) + 8);
        sprintf(c, "%s.oklib", b);
        char *dd = ok_path_join(p->root, "deps");
        char *e = ok_path_join(dd, name);
        bool found = dir_exists(b) || file_exists(c) || dir_exists(e);
        free(a); free(b); free(c); free(dd); free(e);

        if (!found) {
            Diag *dg = strict
                ? diag_error_noloc(de, "library `%s` was not found (searched: libs/, deps/, standard library).", name)
                : diag_warn_noloc(de, "library `%s` was not found (searched: libs/, deps/, standard library) — ignored.", name);
            diag_note(dg, "library binding is not implemented in Okular 0.2; entries are validated only (specs/spec-v0.2.md §6.3).");
        } else {
            Diag *dg = diag_warn_noloc(de, "library `%s` resolved, but library binding is NOT IMPLEMENTED in 0.2 — symbols will not be available.", name);
            (void)dg;
        }
    }
    svec_free(&seen);
}

void project_free(OkProject *p) {
    if (!p) return;
    for (size_t i = 0; i < p->modules.len; i++) {
        OkModule *m = p->modules.items[i];
        free(m->name); free(m->path); free(m->display);
        if (m->src) { free(m->src->path); free(m->src->name); free(m->src->data); free(m->src->line_off); free(m->src); }
        toklist_free(m->toks);
        for (size_t k = 0; k < m->uses.len; k++) free(m->uses.items[k]);
        vec_free(&m->uses);
        if (m->arena) arena_free(m->arena);
        free(m);
    }
    vec_free(&p->modules);
    svec_free(&p->libs);
    free(p->root); free(p->main_path);
    free(p);
}
