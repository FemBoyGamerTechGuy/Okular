/* source.c — source manager. */
#include "ok/source.h"
#include "ok/util.h"

char *ok_read_file(const char *path, size_t *out_len) {
    FILE *f = fopen(path, "rb");
    if (!f) return NULL;
    if (fseek(f, 0, SEEK_END) != 0) { fclose(f); return NULL; }
    long n = ftell(f);
    if (n < 0) { fclose(f); return NULL; }
    rewind(f);
    char *data = ok_xmalloc((size_t)n + 1);
    size_t got = fread(data, 1, (size_t)n, f);
    fclose(f);
    if (got != (size_t)n) { free(data); return NULL; }
    data[n] = 0;
    if (out_len) *out_len = (size_t)n;
    return data;
}

SourceFile *source_load(const char *path, const char *display) {
    size_t len = 0;
    char *data = ok_read_file(path, &len);
    if (!data) return NULL;

    SourceFile *f = ok_xmalloc(sizeof *f);
    f->path = ok_xstrdup(display ? display : path);
    f->name = ok_path_noext(path);
    f->data = data;
    f->len = len;

    /* line index: offset of each line start */
    size_t cap = 64;
    f->line_off = ok_xmalloc(cap * sizeof(size_t));
    f->nlines = 0;
    f->line_off[f->nlines++] = 0;
    for (size_t i = 0; i < len; i++) {
        if (data[i] == '\n') {
            if (f->nlines == cap) {
                cap *= 2;
                f->line_off = ok_xrealloc(f->line_off, cap * sizeof(size_t));
            }
            f->line_off[f->nlines++] = i + 1;
        }
    }
    return f;
}

void source_line(const SourceFile *f, size_t line, const char **out, size_t *out_len) {
    if (line == 0) line = 1;
    if (line > f->nlines) { *out = ""; *out_len = 0; return; }
    size_t start = f->line_off[line - 1];
    size_t end = (line < f->nlines) ? f->line_off[line] : f->len;
    /* strip trailing \r\n */
    while (end > start && (f->data[end - 1] == '\n' || f->data[end - 1] == '\r'))
        end--;
    *out = f->data + start;
    *out_len = end - start;
}
