/* types.c — interned type descriptors (see types.h). */
#include "ok/types.h"

/* bootstrap limits (documented in the spec §8.4):
 * arrays are stack/static storage, so their size is bounded to keep frames
 * and .data sane while the language is young. */
#define OK_MAX_ARRAY_LEN 65536
#define OK_MAX_ARRAY_BYTES (1u << 20)

static Type t_void_s   = { OK_VOID,   NULL, 0, "void" };
static Type t_number_s = { OK_NUMBER, NULL, 0, "number" };
static Type t_dec_s    = { OK_DECIMAL, NULL, 0, "decimal" };
static Type t_text_s   = { OK_TEXT,   NULL, 0, "text" };
static Type t_bool_s   = { OK_BOOL,   NULL, 0, "bool" };

OkType ty_void    = &t_void_s;
OkType ty_number  = &t_number_s;
OkType ty_decimal = &t_dec_s;
OkType ty_text    = &t_text_s;
OkType ty_bool    = &t_bool_s;

/* ---- array interning ---- */

typedef struct ArrEntry {
    Type t;              /* embedded descriptor */
    struct ArrEntry *next;
} ArrEntry;

static ArrEntry *arr_table[256]; /* hash by (elem ptr, count) */

static size_t arr_hash(OkType elem, size_t count) {
    return (((size_t)(uintptr_t)elem) * 31u + count) & 255u;
}

static size_t scalar_bytes(TypeKind k) {
    switch (k) {
    case OK_TEXT: return 16;
    case OK_VOID: return 0;
    default: return 8;   /* number, decimal, bool */
    }
}

size_t ty_bytes(OkType t) {
    if (!t) return 0;
    if (t->kind == OK_ARRAY) return ty_bytes(t->elem) * t->count;
    return scalar_bytes(t->kind);
}

OkType ty_array(OkType elem, size_t count) {
    if (!elem || elem->kind == OK_VOID || count == 0 || count > OK_MAX_ARRAY_LEN)
        return NULL;

    /* nested-size limit: total bytes bounded (checked before interning) */
    size_t eb = ty_bytes(elem);
    if (eb == 0 || count > OK_MAX_ARRAY_BYTES / eb) return NULL;

    size_t h = arr_hash(elem, count);
    for (ArrEntry *e = arr_table[h]; e; e = e->next) {
        if (e->t.elem == elem && e->t.count == count) return &e->t;
    }

    ArrEntry *e = ok_xmalloc(sizeof *e);
    memset(e, 0, sizeof *e);
    e->t.kind = OK_ARRAY;
    e->t.elem = elem;
    e->t.count = count;

    /* rendered name: "array<number, 5>" */
    char buf[256];
    int n = snprintf(buf, sizeof buf, "array<%s, %zu>", elem->name, count);
    if (n < 0 || (size_t)n >= sizeof buf) n = (int)sizeof buf - 1;
    e->t.name = ok_xstrndup(buf, (size_t)n);

    e->next = arr_table[h];
    arr_table[h] = e;
    return &e->t;
}

bool ty_from_scalar_name(const char *s, OkType *out) {
    if (strcmp(s, "number") == 0) { *out = ty_number; return true; }
    if (strcmp(s, "decimal") == 0) { *out = ty_decimal; return true; }
    if (strcmp(s, "text") == 0)    { *out = ty_text; return true; }
    if (strcmp(s, "bool") == 0)    { *out = ty_bool; return true; }
    return false;
}

const char *ok_type_name(OkType t) {
    return t ? t->name : "?";
}
