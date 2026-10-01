/* main.c — the `okular` CLI (spec §15/§41).
 *
 *   okular --compile [-w] [-l] [-xw] [-s] [-o PATH] path/to/main.ok
 *
 * Debug flags (used by the test suite): --dump-tokens --dump-ast --dump-ir
 * --emit-asm.
 */
#include "ok/driver.h"
#include "ok/util.h"
#include <unistd.h>

#define OK_RUNTIME_OBJ "runtime/rt.o"

static void usage(FILE *out) {
    fprintf(out,
        "Okular %s — bootstrap compiler (x86-64 Linux)\n\n"
        "usage: okular --compile [flags] path/to/project/main.ok\n\n"
        "flags:\n"
        "  --compile          compile the project (required)\n"
        "  -w, --warnings     enable warnings\n"
        "  -xw, --extra-warnings  enable extra diagnostics\n"
        "  -s, --strict       strict build mode (spec §2.1/§14)\n"
        "  -l, --legacy       legacy compatibility (spec §14; no legacy syntax exists yet)\n"
        "  -o, --output PATH  executable output path (default build/output/<name>)\n"
        "  --selfhost-lex BIN tokenize through the Okular-written lexer (M4 bridge)\n"
        "  --selfhost-parse BIN parse through the Okular-written parser (M4 bridge)\n"
        "  --selfhost-verify BIN parse both ways; compare the ASTs byte for byte\n"
        "  --version          print the version\n"
        "  --help             this help\n\n"
        "debug (test suite):\n"
        "  --dump-tokens  --dump-ast  --dump-ir  --emit-asm\n",
        OK_VERSION);
}

int main(int argc, char **argv) {
    OkOptions opt;
    memset(&opt, 0, sizeof opt);
    bool want_compile = false;

    for (int i = 1; i < argc; i++) {
        const char *a = argv[i];
        if (strcmp(a, "--compile") == 0) {
            want_compile = true;
        } else if (strcmp(a, "-w") == 0 || strcmp(a, "--warnings") == 0) {
            opt.warnings = true;
        } else if (strcmp(a, "-xw") == 0 || strcmp(a, "--extra-warnings") == 0) {
            opt.extra_warnings = true;
            opt.warnings = true; /* extra implies normal warnings */
        } else if (strcmp(a, "-s") == 0 || strcmp(a, "--s") == 0 || strcmp(a, "--strict") == 0) {
            opt.strict = true;
        } else if (strcmp(a, "-l") == 0 || strcmp(a, "--legacy") == 0) {
            opt.legacy = true;
        } else if (strcmp(a, "-o") == 0 || strcmp(a, "--output") == 0) {
            if (i + 1 >= argc) {
                fprintf(stderr, "okular: `%s` needs a path argument.\n", a);
                return 2;
            }
            opt.output = argv[++i];
        } else if (strcmp(a, "--selfhost-lex") == 0) {
            if (i + 1 >= argc) {
                fprintf(stderr, "okular: `%s` needs the path to the compiled selfhost/lexer program.\n", a);
                return 2;
            }
            opt.selfhost_lex = argv[++i];
        } else if (strcmp(a, "--selfhost-parse") == 0) {
            if (i + 1 >= argc) {
                fprintf(stderr, "okular: `%s` needs the path to the compiled selfhost/parser program.\n", a);
                return 2;
            }
            opt.selfhost_parse = argv[++i];
        } else if (strcmp(a, "--selfhost-verify") == 0) {
            if (i + 1 >= argc) {
                fprintf(stderr, "okular: `%s` needs the path to the compiled selfhost/parser program.\n", a);
                return 2;
            }
            opt.selfhost_verify = argv[++i];
        } else if (strcmp(a, "--version") == 0) {
            printf("Okular %s\n", OK_VERSION);
            return 0;
        } else if (strcmp(a, "--help") == 0 || strcmp(a, "-h") == 0) {
            usage(stdout);
            return 0;
        } else if (strcmp(a, "--dump-tokens") == 0) {
            opt.dump_tokens = true;
        } else if (strcmp(a, "--dump-ast") == 0) {
            opt.dump_ast = true;
        } else if (strcmp(a, "--dump-ir") == 0) {
            opt.dump_ir = true;
        } else if (strcmp(a, "--dump-symbols") == 0) {
            opt.dump_symbols = true;
        } else if (strcmp(a, "--emit-asm") == 0) {
            opt.emit_asm_only = true;
        } else if (a[0] == '-' && a[1] != 0) {
            fprintf(stderr, "okular: unknown flag `%s` (see `okular --help`).\n", a);
            return 2;
        } else if (!opt.main_path) {
            opt.main_path = a;
        } else {
            fprintf(stderr, "okular: unexpected extra argument `%s`.\n", a);
            return 2;
        }
    }

    if (!want_compile && !opt.dump_tokens && !opt.dump_ast && !opt.selfhost_verify) {
        usage(stderr);
        fprintf(stderr, "okular: nothing to do — pass `--compile` and a `main.ok` path.\n");
        return 2;
    }
    if (!opt.main_path) {
        fprintf(stderr, "okular: no input file — pass the path to the project's `main.ok`.\n");
        return 2;
    }

    int rc = driver_compile(&opt);
    return rc;
}
