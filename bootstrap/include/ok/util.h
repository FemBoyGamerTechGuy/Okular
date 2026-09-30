/* util.h — buffers, arenas, small string helpers. */
#ifndef OK_UTIL_H
#define OK_UTIL_H

#include "ok.h"

/* Growable byte/text buffer. */
typedef struct {
    char *data;
    size_t len, cap;
} Buf;

void buf_init(Buf *b);
void buf_free(Buf *b);
void buf_putc(Buf *b, char c);
void buf_put(Buf *b, const char *s, size_t n);
void buf_puts(Buf *b, const char *s);
void buf_printf(Buf *b, const char *fmt, ...);
void buf_pad(Buf *b, char c, size_t n);

/* Arena allocator: the parser and AST live in one; freeing is one call.
 * Impossible-to-leak by construction. */
typedef struct Arena Arena;
Arena *arena_new(void);
void arena_free(Arena *a);
void *arena_alloc(Arena *a, size_t n);

/* Pointer vector */
typedef struct {
    void **items;
    size_t len, cap;
} Vec;

void vec_init(Vec *v);
void vec_free(Vec *v);
void vec_push(Vec *v, void *item);
void vec_clear(Vec *v);

/* C-string vector */
typedef struct {
    char **items;
    size_t len, cap;
} StrVec;

void svec_init(StrVec *v);
void svec_free(StrVec *v);
void svec_push(StrVec *v, char *s); /* takes ownership */
bool svec_contains(const StrVec *v, const char *s);

/* case-insensitive file extension check */
bool ok_has_ext(const char *name, const char *ext);

/* path helpers (no libc path functions; small and honest) */
const char *ok_path_basename(const char *path);
char *ok_path_join(const char *dir, const char *name); /* malloc'd */
char *ok_path_noext(const char *path);                 /* malloc'd, basename w/o ext */

#endif /* OK_UTIL_H */
