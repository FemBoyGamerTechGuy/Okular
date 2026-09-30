/* util.c — buffers, arenas, vectors, path helpers. */
#include "ok/util.h"

/* ---------------- Buf ---------------- */

void buf_init(Buf *b) { b->data = NULL; b->len = b->cap = 0; }
void buf_free(Buf *b) { free(b->data); b->data = NULL; b->len = b->cap = 0; }

static void buf_reserve(Buf *b, size_t extra) {
    if (b->len + extra + 1 > b->cap) {
        size_t nc = b->cap ? b->cap * 2 : 64;
        while (nc < b->len + extra + 1) nc *= 2;
        b->data = ok_xrealloc(b->data, nc);
        b->cap = nc;
    }
}

void buf_putc(Buf *b, char c)        { buf_reserve(b, 1); b->data[b->len++] = c; b->data[b->len] = 0; }
void buf_put(Buf *b, const char *s, size_t n) { buf_reserve(b, n); memcpy(b->data + b->len, s, n); b->len += n; b->data[b->len] = 0; }
void buf_puts(Buf *b, const char *s) { buf_put(b, s, strlen(s)); }
void buf_pad(Buf *b, char c, size_t n) { buf_reserve(b, n); memset(b->data + b->len, c, n); b->len += n; b->data[b->len] = 0; }

void buf_printf(Buf *b, const char *fmt, ...) {
    va_list ap; va_start(ap, fmt);
    va_list ap2; va_copy(ap2, ap);
    int n = vsnprintf(NULL, 0, fmt, ap);
    va_end(ap);
    if (n < 0) { va_end(ap2); return; }
    buf_reserve(b, (size_t)n);
    vsnprintf(b->data + b->len, (size_t)n + 1, fmt, ap2);
    b->len += (size_t)n;
    va_end(ap2);
}

/* ---------------- Arena ---------------- */

typedef struct ArenaBlock {
    struct ArenaBlock *next;
    size_t used, cap;
    /* data follows */
} ArenaBlock;

struct Arena {
    ArenaBlock *head; /* most recent first */
};

Arena *arena_new(void) {
    Arena *a = ok_xmalloc(sizeof *a);
    a->head = NULL;
    return a;
}

void arena_free(Arena *a) {
    if (!a) return;
    ArenaBlock *b = a->head;
    while (b) { ArenaBlock *n = b->next; free(b); b = n; }
    free(a);
}

void *arena_alloc(Arena *a, size_t n) {
    n = (n + 15) & ~(size_t)15;
    if (!a->head || a->head->used + n > a->head->cap) {
        size_t cap = 8192; if (cap < n) cap = n;
        ArenaBlock *b = ok_xmalloc(sizeof *b + cap);
        b->next = a->head; b->used = 0; b->cap = cap;
        a->head = b;
    }
    void *p = (char *)(a->head + 1) + a->head->used;
    a->head->used += n;
    return p;
}

/* ---------------- Vec / StrVec ---------------- */

void vec_init(Vec *v) { v->items = NULL; v->len = v->cap = 0; }
void vec_free(Vec *v) { free(v->items); v->items = NULL; v->len = v->cap = 0; }
void vec_push(Vec *v, void *item) {
    if (v->len == v->cap) {
        v->cap = v->cap ? v->cap * 2 : 8;
        v->items = ok_xrealloc(v->items, v->cap * sizeof(void *));
    }
    v->items[v->len++] = item;
}
void vec_clear(Vec *v) { v->len = 0; }

void svec_init(StrVec *v) { v->items = NULL; v->len = v->cap = 0; }
void svec_free(StrVec *v) {
    for (size_t i = 0; i < v->len; i++) free(v->items[i]);
    free(v->items); v->items = NULL; v->len = v->cap = 0;
}
void svec_push(StrVec *v, char *s) {
    if (v->len == v->cap) {
        v->cap = v->cap ? v->cap * 2 : 8;
        v->items = ok_xrealloc(v->items, v->cap * sizeof(char *));
    }
    v->items[v->len++] = s;
}
bool svec_contains(const StrVec *v, const char *s) {
    for (size_t i = 0; i < v->len; i++)
        if (strcmp(v->items[i], s) == 0) return true;
    return false;
}

/* ---------------- paths ---------------- */

bool ok_has_ext(const char *name, const char *ext) {
    size_t nl = strlen(name), el = strlen(ext);
    if (nl <= el + 1) return false;
    const char *dot = name + nl - el;
    return dot[-1] == '.' && strcmp(dot, ext) == 0;
}

const char *ok_path_basename(const char *path) {
    const char *slash = strrchr(path, '/');
    return slash ? slash + 1 : path;
}

char *ok_path_join(const char *dir, const char *name) {
    size_t dl = strlen(dir);
    if (dl == 0) return ok_xstrdup(name);
    if (dir[dl - 1] == '/') {
        char *out = ok_xmalloc(dl + strlen(name) + 1);
        sprintf(out, "%s%s", dir, name);
        return out;
    }
    char *out = ok_xmalloc(dl + strlen(name) + 2);
    sprintf(out, "%s/%s", dir, name);
    return out;
}

char *ok_path_noext(const char *path) {
    const char *base = ok_path_basename(path);
    const char *dot = strrchr(base, '.');
    size_t n = dot && dot != base ? (size_t)(dot - base) : strlen(base);
    return ok_xstrndup(base, n);
}
