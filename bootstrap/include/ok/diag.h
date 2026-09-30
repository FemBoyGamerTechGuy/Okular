/* diag.h — diagnostics engine (spec §14, brief §42/§43).
 *
 * Required render format:
 *
 *   src/player.ok:42:17
 *
 *   Error: expected a number after the `=` operator.
 *
 *   42 | number.health =
 *                    ^
 *
 *   Found: `}`
 *
 *   note: the declaration is missing an initializer.
 */
#ifndef OK_DIAG_H
#define OK_DIAG_H

#include "ok.h"
#include "source.h"
#include "util.h"

typedef enum { DIAG_ERROR, DIAG_WARNING } DiagSev;

typedef struct Diag {
    DiagSev sev;
    bool downgraded;       /* was an error, downgraded by the optional-source policy */
    const SourceFile *file; /* NULL allowed for project-level messages */
    size_t line, col;       /* 1-based; 0 = no location */
    char *msg;              /* owned */
    char *found;            /* owned, optional ("Found: `}`") */
    StrVec notes;           /* owned lines, each "note: ..." rendered */
} Diag;

typedef struct DiagEngine {
    Diag *items;
    size_t len, cap;
    size_t errors, warnings;
    bool force_warning; /* optional-source policy: report errors as warnings
                         * (brief §36: unused broken sources warn, not fail) */
} DiagEngine;

void diag_init(DiagEngine *e);
void diag_free(DiagEngine *e);

/* Emit and remember; returns the Diag so the caller can attach details. */
Diag *diag_emit(DiagEngine *e, DiagSev sev, const SourceFile *f,
                size_t line, size_t col, const char *fmt, ...)
    __attribute__((format(printf, 6, 7)));

static inline Diag *diag_error(DiagEngine *e, const SourceFile *f,
                               size_t line, size_t col, const char *fmt, ...)
    __attribute__((format(printf, 5, 6)));
static inline Diag *diag_warn(DiagEngine *e, const SourceFile *f,
                              size_t line, size_t col, const char *fmt, ...)
    __attribute__((format(printf, 5, 6)));

/* Attach details to a just-emitted diagnostic. */
void diag_found(Diag *d, const char *found_fmt, ...) __attribute__((format(printf, 2, 3)));
void diag_note(Diag *d, const char *fmt, ...) __attribute__((format(printf, 2, 3)));

/* Render everything collected so far to stderr (in emission order). */
void diag_render_all(DiagEngine *e);

static inline bool diag_has_errors(const DiagEngine *e) { return e->errors > 0; }

/* Project-level message with no source location (usage errors etc.). */
Diag *diag_error_noloc(DiagEngine *e, const char *fmt, ...)
    __attribute__((format(printf, 2, 3)));
Diag *diag_warn_noloc(DiagEngine *e, const char *fmt, ...)
    __attribute__((format(printf, 2, 3)));

/* inline va_list forwarders */
static inline Diag *diag_error(DiagEngine *e, const SourceFile *f,
                               size_t line, size_t col, const char *fmt, ...) {
    va_list ap; va_start(ap, fmt);
    char buf[1024]; vsnprintf(buf, sizeof buf, fmt, ap); va_end(ap);
    return diag_emit(e, DIAG_ERROR, f, line, col, "%s", buf);
}
static inline Diag *diag_warn(DiagEngine *e, const SourceFile *f,
                              size_t line, size_t col, const char *fmt, ...) {
    va_list ap; va_start(ap, fmt);
    char buf[1024]; vsnprintf(buf, sizeof buf, fmt, ap); va_end(ap);
    return diag_emit(e, DIAG_WARNING, f, line, col, "%s", buf);
}

#endif /* OK_DIAG_H */
