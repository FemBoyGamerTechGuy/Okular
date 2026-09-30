/* ok.c — shared definitions for ok.h */
#include "ok/ok.h"
#include "ok/util.h"

const char *ok_feature_names[OK_FEATURE_COUNT] = {
    "text",
};

void *ok_xmalloc(size_t n) {
    void *p = malloc(n ? n : 1);
    if (!p) { fprintf(stderr, "okular: out of memory (%zu bytes)\n", n); exit(2); }
    return p;
}

void *ok_xrealloc(void *p, size_t n) {
    void *q = realloc(p, n ? n : 1);
    if (!q) { fprintf(stderr, "okular: out of memory (%zu bytes)\n", n); exit(2); }
    return q;
}

char *ok_xstrdup(const char *s) {
    size_t n = strlen(s) + 1;
    char *p = ok_xmalloc(n);
    memcpy(p, s, n);
    return p;
}

char *ok_xstrndup(const char *s, size_t n) {
    char *p = ok_xmalloc(n + 1);
    memcpy(p, s, n);
    p[n] = 0;
    return p;
}

void ok_ice(const char *file, int line, const char *fmt, ...) {
    va_list ap; va_start(ap, fmt);
    fprintf(stderr, "\nokular: internal compiler error at %s:%d\n  ",
            ok_path_basename(file), line);
    vfprintf(stderr, fmt, ap);
    fprintf(stderr, "\n\nThis is a bug in the bootstrap compiler, not in your Okular code.\n"
                    "Please report it with the source that triggered it.\n");
    va_end(ap);
    exit(2);
}
