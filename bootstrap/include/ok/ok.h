/* ok.h — common definitions for the Okular bootstrap compiler.
 *
 * The C implementation is bootstrap scaffolding (see docs/architecture.md).
 * Keep it readable, modular, and easy to replace.
 */
#ifndef OK_H
#define OK_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>

#define OK_VERSION "0.3"
#define OK_MAX_ERRORS 50
#define OK_OUTBUF_BYTES 65536
#define OK_TEXT_ARENA_BYTES (1 << 20)

/* ---- Okular types (spec §4) ---- */
/* OkType (the interned type descriptors) is defined in types.h, which this
 * file includes at the bottom. */

/* ---- compile-time feature directives (spec §5) ---- */
enum { OK_FEATURE_TEXT = 0, OK_FEATURE_COUNT };
extern const char *ok_feature_names[OK_FEATURE_COUNT];

/* ---- build modes ---- */
typedef struct OkOptions {
    bool warnings;       /* -w  */
    bool extra_warnings; /* -xw */
    bool strict;         /* -s  */
    bool legacy;         /* -l  */
    const char *output;  /* -o  (NULL = build/output/<mainname>) */
    const char *main_path;
    /* debug dumps (used by the test suite) */
    bool dump_tokens, dump_ast, dump_ir, dump_symbols, emit_asm_only;
} OkOptions;

/* fatal internal error: brief §67 — an ICE must produce a useful diagnostic */
void ok_ice(const char *file, int line, const char *fmt, ...);
#define OK_ICE(...) ok_ice(__FILE__, __LINE__, __VA_ARGS__)

void *ok_xmalloc(size_t n);
void *ok_xrealloc(void *p, size_t n);
char *ok_xstrdup(const char *s);
char *ok_xstrndup(const char *s, size_t n);

/* type descriptors: must come after the declarations above so types.h can
 * itself include ok.h under its include guard */
#include "ok/types.h"

#endif /* OK_H */
