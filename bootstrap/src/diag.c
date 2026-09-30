/* diag.c — diagnostics rendering (spec §14, brief §42). */
#include "ok/diag.h"

Diag *diag_emit(DiagEngine *e, DiagSev sev, const SourceFile *f,
                size_t line, size_t col, const char *fmt, ...) {
    if (e->len == e->cap) {
        e->cap = e->cap ? e->cap * 2 : 16;
        e->items = ok_xrealloc(e->items, e->cap * sizeof(Diag));
    }
    Diag *d = &e->items[e->len++];
    memset(d, 0, sizeof *d);
    /* optional-source downgrade (brief §36) */
    if (e->force_warning && sev == DIAG_ERROR) {
        sev = DIAG_WARNING;
        d->downgraded = true;
    }
    d->sev = sev;
    d->file = f;
    d->line = line;
    d->col = col;

    va_list ap; va_start(ap, fmt);
    va_list ap2; va_copy(ap2, ap);
    int n = vsnprintf(NULL, 0, fmt, ap);
    va_end(ap);
    d->msg = ok_xmalloc((size_t)(n < 0 ? 16 : n + 1));
    vsnprintf(d->msg, (size_t)(n < 0 ? 16 : n + 1), fmt, ap2);
    va_end(ap2);

    svec_init(&d->notes);

    if (sev == DIAG_ERROR) {
        if (++e->errors >= OK_MAX_ERRORS) {
            /* brief §43: never produce a falsely successful build; but stop
             * drowning the user after a pile of cascade errors. */
            fprintf(stderr, "okular: too many errors (stopping at %d)\n", OK_MAX_ERRORS);
            diag_render_all(e);
            exit(1);
        }
    } else {
        e->warnings++;
    }
    return d;
}

void diag_found(Diag *d, const char *found_fmt, ...) {
    va_list ap; va_start(ap, found_fmt);
    va_list ap2; va_copy(ap2, ap);
    int n = vsnprintf(NULL, 0, found_fmt, ap);
    va_end(ap);
    free(d->found);
    d->found = ok_xmalloc((size_t)(n < 0 ? 16 : n + 1));
    vsnprintf(d->found, (size_t)(n < 0 ? 16 : n + 1), found_fmt, ap2);
    va_end(ap2);
}

void diag_note(Diag *d, const char *fmt, ...) {
    va_list ap; va_start(ap, fmt);
    va_list ap2; va_copy(ap2, ap);
    int n = vsnprintf(NULL, 0, fmt, ap);
    va_end(ap);
    char *s = ok_xmalloc((size_t)(n < 0 ? 16 : n + 1));
    vsnprintf(s, (size_t)(n < 0 ? 16 : n + 1), fmt, ap2);
    va_end(ap2);
    svec_push(&d->notes, s);
}

Diag *diag_error_noloc(DiagEngine *e, const char *fmt, ...) {
    va_list ap; va_start(ap, fmt);
    char buf[1024]; vsnprintf(buf, sizeof buf, fmt, ap); va_end(ap);
    return diag_emit(e, DIAG_ERROR, NULL, 0, 0, "%s", buf);
}

Diag *diag_warn_noloc(DiagEngine *e, const char *fmt, ...) {
    va_list ap; va_start(ap, fmt);
    char buf[1024]; vsnprintf(buf, sizeof buf, fmt, ap); va_end(ap);
    return diag_emit(e, DIAG_WARNING, NULL, 0, 0, "%s", buf);
}

/* ---- rendering ---- */

static void render_one(Diag *d) {
    FILE *out = stderr;

    if (d->file && d->line > 0) {
        fprintf(out, "%s:%zu:%zu\n\n", d->file->path, d->line, d->col);
    } else {
        fprintf(out, "okular\n\n");
    }

    fprintf(out, "%s: %s\n\n", d->sev == DIAG_ERROR ? "Error" : "Warning", d->msg);

    if (d->file && d->line > 0) {
        const char *text; size_t tlen;
        source_line(d->file, d->line, &text, &tlen);
        if (tlen > 0 || d->col > 1) {
            /* gutter: line number, right-padded to fixed width */
            char num[32];
            snprintf(num, sizeof num, "%zu", d->line);
            size_t gw = strlen(num) + 2; /* "NN | " */
            fprintf(out, "%s | %.*s\n", num, (int)tlen, text);
            /* caret under the column (byte column, 1-based) */
            size_t caret = d->col ? d->col : 1;
            fprintf(out, "%*s", (int)gw, "");
            for (size_t i = 1; i < caret && i <= tlen + 1; i++) fputc(' ', out);
            fprintf(out, "^\n\n");
        }
    }

    if (d->found)
        fprintf(out, "Found: %s\n\n", d->found);

    for (size_t i = 0; i < d->notes.len; i++)
        fprintf(out, "note: %s\n", d->notes.items[i]);

    fputc('\n', out);
}

void diag_render_all(DiagEngine *e) {
    for (size_t i = 0; i < e->len; i++)
        render_one(&e->items[i]);
    if (e->errors || e->warnings) {
        fprintf(stderr, "okular: %zu error%s, %zu warning%s\n\n",
                e->errors, e->errors == 1 ? "" : "s",
                e->warnings, e->warnings == 1 ? "" : "s");
    }
    /* rendered items are released: diagnostics reference source files that
     * may be freed afterwards, so a second render must be a no-op. Counts
     * (errors/warnings) are kept for the driver's decisions. */
    for (size_t i = 0; i < e->len; i++) {
        free(e->items[i].msg);
        free(e->items[i].found);
        svec_free(&e->items[i].notes);
    }
    e->len = 0;
}

void diag_init(DiagEngine *e) { e->items = NULL; e->len = e->cap = 0; e->errors = e->warnings = 0; }

void diag_free(DiagEngine *e) {
    for (size_t i = 0; i < e->len; i++) {
        free(e->items[i].msg);
        free(e->items[i].found);
        svec_free(&e->items[i].notes);
    }
    free(e->items);
    e->items = NULL; e->len = e->cap = 0;
}
