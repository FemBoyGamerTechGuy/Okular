/* source.h — source manager: owns loaded files and line indexes. */
#ifndef OK_SOURCE_H
#define OK_SOURCE_H

#include "ok.h"

typedef struct SourceFile {
    char *path;        /* as given (for display) */
    char *name;        /* basename without extension = module name */
    char *data;        /* file bytes, NUL-terminated */
    size_t len;
    size_t *line_off;  /* byte offset of each line start */
    size_t nlines;
} SourceFile;

/* Loads a file; returns NULL and prints to stderr if unreadable.
 * `display` overrides the path shown in diagnostics (NULL = use path). */
SourceFile *source_load(const char *path, const char *display);

/* 1-based line access: returns pointer into file data + length (no NUL). */
void source_line(const SourceFile *f, size_t line, const char **out, size_t *out_len);

/* Read a whole file; NULL on failure. */
char *ok_read_file(const char *path, size_t *out_len);

#endif /* OK_SOURCE_H */
