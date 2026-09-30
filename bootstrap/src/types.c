/* types.c — interned type descriptors (see types.h). */
#include "ok/types.h"

/* bootstrap limits (documented in the spec §8.4):
 * arrays are stack/static storage, so their size is bounded to keep frames
 * and .data sane while the language is young. */
#define OK_MAX_ARRAY_LEN 65536
#define OK_MAX_ARRAY_BYTES (1u << 20)

static Type t_void_s   = { OK_VOID,   NULL, 0, "void",     0, false };
static Type t_number_s = { OK_NUMBER, NULL, 0, "number",  64, true  };
static Type t_dec_s    = { OK_DECIMAL, NULL, 0, "decimal", 0, false };
static Type t_text_s   = { OK_TEXT,   NULL, 0, "text",     0, false };
static Type t_bool_s   = { OK_BOOL,   NULL, 0, "bool",     0, false };

static Type t_i8_s     = { OK_INT8,   NULL, 0, "int8",     8, true  };
static Type t_i16_s    = { OK_INT16,  NULL, 0, "int16",   16, true  };
static Type t_i32_s    = { OK_INT32,  NULL, 0, "int32",   32, true  };
static Type t_u8_s     = { OK_UINT8,  NULL, 0, "uint8",    8, false };
static Type t_u16_s    = { OK_UINT16, NULL, 0, "uint16",  16, false };
static Type t_u32_s    = { OK_UINT32, NULL, 0, "uint32",  32, false };
static Type t_u64_s    = { OK_UINT64, NULL, 0, "uint64",  64, false };

OkType ty_void    = &t_void_s;
OkType ty_number  = &t_number_s;
OkType ty_decimal = &t_dec_s;
OkType ty_text    = &t_text_s;
OkType ty_bool    = &t_bool_s;

OkType ty_int8    = &t_i8_s;
OkType ty_int16   = &t_i16_s;
OkType ty_int32   = &t_i32_s;
OkType ty_uint8   = &t_u8_s;
OkType ty_uint16  = &t_u16_s;
OkType ty_uint32  = &t_u32_s;
OkType ty_uint64  = &t_u64_s;

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
    case OK_BOOL: return 1;   /* spec §4.1: bool is 1 byte */
    case OK_INT8: case OK_UINT8: return 1;
    case OK_INT16: case OK_UINT16: return 2;
    case OK_INT32: case OK_UINT32: return 4;
    default: return 8;   /* number, decimal */
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
    /* fixed-width family + aliases (spec §4.2) */
    if (strcmp(s, "int8") == 0)   { *out = ty_int8; return true; }
    if (strcmp(s, "int16") == 0)  { *out = ty_int16; return true; }
    if (strcmp(s, "int32") == 0)  { *out = ty_int32; return true; }
    if (strcmp(s, "int64") == 0)  { *out = ty_number; return true; }  /* alias */
    if (strcmp(s, "uint8") == 0)  { *out = ty_uint8; return true; }
    if (strcmp(s, "uint16") == 0) { *out = ty_uint16; return true; }
    if (strcmp(s, "uint32") == 0) { *out = ty_uint32; return true; }
    if (strcmp(s, "uint64") == 0) { *out = ty_uint64; return true; }
    if (strcmp(s, "byte") == 0)   { *out = ty_uint8; return true; }   /* alias */
    if (strcmp(s, "f64") == 0)    { *out = ty_decimal; return true; } /* alias */
    return false;
}

/* ---- integer ranges (spec §4.2) ---- */

int64_t ty_min_i64(OkType t) {
    if (!ty_is_integer(t) || !t->is_signed) return 0;
    switch (t->bits) {
    case 8:  return -128;
    case 16: return -32768;
    case 32: return (int64_t)INT32_MIN;
    default: return INT64_MIN;
    }
}

int64_t ty_max_i64(OkType t) {
    if (!ty_is_integer(t)) return 0;
    if (!t->is_signed) return -1; /* callers use ty_uint_fits for unsigned */
    switch (t->bits) {
    case 8:  return 127;
    case 16: return 32767;
    case 32: return INT32_MAX;
    default: return INT64_MAX;
    }
}

bool ty_uint_fits(uint64_t v, OkType t) {
    if (!ty_is_integer(t)) return false;
    if (t->kind == OK_NUMBER) return true; /* literal wraps, as in 0.2 */
    if (t->is_signed) {
        switch (t->bits) {
        case 8:  return v <= 127;
        case 16: return v <= 32767;
        case 32: return v <= (uint64_t)INT32_MAX;
        default: return v <= (uint64_t)INT64_MAX;
        }
    }
    switch (t->bits) {
    case 8:  return v <= 0xFFu;
    case 16: return v <= 0xFFFFu;
    case 32: return v <= 0xFFFFFFFFu;
    default: return true; /* uint64: every literal fits */
    }
}

bool ty_sint_fits(int64_t v, OkType t) {
    if (!ty_is_integer(t)) return false;
    if (t->kind == OK_NUMBER) return true;
    if (t->is_signed) {
        return v >= ty_min_i64(t) && v <= ty_max_i64(t);
    }
    /* unsigned target: constants must be non-negative and in range */
    if (v < 0) return false;
    switch (t->bits) {
    case 8:  return v <= 0xFF;
    case 16: return v <= 0xFFFF;
    case 32: return v <= 0xFFFFFFFFLL;
    default: return true;
    }
}

/* ---- conversions (spec §4.4) ---- */

bool ty_assignable(OkType from, OkType to) {
    if (!from || !to) return false;
    if (from == to) return true;
    /* integer -> decimal widens implicitly (as number did in 0.2) */
    if (to == ty_decimal && ty_is_integer(from)) return true;
    if (!ty_is_integer(from) || !ty_is_integer(to)) return false;
    /* safe integer widening lattice */
    int bf = from->bits, bt = to->bits;
    bool sf = from->is_signed, st = to->is_signed;
    if (bf < bt) {
        if (sf == st) return true;              /* same signedness, wider */
        if (!sf && st) return true;             /* unsigned -> wider signed */
    }
    return false;
}

OkType ty_common(OkType a, OkType b) {
    if (!a || !b) return NULL;
    if (a == b) return a;
    /* decimal dominates when both sides are numeric */
    if (a == ty_decimal && ty_is_integer(b)) return ty_decimal;
    if (b == ty_decimal && ty_is_integer(a)) return ty_decimal;
    if (!ty_is_integer(a) || !ty_is_integer(b)) return NULL;
    int ba = a->bits, bb = b->bits;
    bool sa = a->is_signed, sb = b->is_signed;
    if (sa == sb) return (ba >= bb) ? a : b;
    /* mixed signedness: the signed type must be strictly wider */
    OkType u = sa ? b : a;   /* unsigned side */
    OkType s = sa ? a : b;   /* signed side   */
    if (s->bits > u->bits) return s;
    return NULL;             /* e.g. int8 + uint8, number + uint64 */
}

bool ty_convertible(OkType from, OkType to) {
    if (!from || !to) return false;
    if (from == to) return true; /* identity is a legal explicit conversion */
    if (from == ty_text || to == ty_text) return false; /* planned, not built */
    if (ty_kind(from) == OK_ARRAY || ty_kind(to) == OK_ARRAY) return false;
    if (from == ty_void || to == ty_void) return false;
    if (ty_is_integer(from) && ty_is_integer(to)) return true;
    if (ty_is_integer(from) && to == ty_decimal) return true;
    if (from == ty_decimal && ty_is_integer(to)) return true;
    if (from == ty_bool && (ty_is_integer(to) || to == ty_decimal)) return true;
    return false; /* integer -> bool, decimal -> bool: no silent truthiness */
}

uint64_t ty_reencode(uint64_t v, OkType to) {
    if (!to || !ty_is_integer(to)) return v;
    int n = to->bits;
    if (n >= 64) return v;
    int sh = 64 - n;
    if (to->is_signed) {
        return (uint64_t)(((int64_t)(v << sh)) >> sh); /* sign-extend low n */
    }
    return (v << sh) >> sh;                             /* zero-extend low n */
}

double ty_int_to_dec(uint64_t v, OkType from) {
    if (from && from->kind == OK_UINT64) return (double)v; /* C converts with rounding */
    if (from && ty_is_integer(from) && !from->is_signed) {
        /* narrower unsigned values are zero-extended, positive */
        return (double)v;
    }
    return (double)(int64_t)v;
}

uint64_t ty_dec_to_int(double d, OkType to) {
    /* mirror the hardware: cvttsd2si yields the INT64_MIN sentinel for
     * NaN / out-of-range; the re-encode then wraps to the target width */
    if (!(d >= -9223372036854775808.0 && d < 9223372036854775808.0))
        return ty_reencode((uint64_t)INT64_MIN, to);
    return ty_reencode((uint64_t)(int64_t)d, to);
}

const char *ok_type_name(OkType t) {
    return t ? t->name : "?";
}
