/* types.h — the Okular type system (spec §4).
 *
 * Types are interned descriptors, not enum values: `OkType` is a pointer,
 * and two types are the same type exactly when their pointers are equal.
 * Scalars are singletons; array types are interned per (element, count).
 *
 * 0.3 adds the fixed-width integer family (spec §4.2): int8/16/32,
 * uint8/16/32/64 and the `byte` alias. `int64` is `number`'s systems
 * name (same descriptor), `f64` is `decimal`'s — the defaults keep their
 * approachable names while systems code can be width-explicit.
 */
#ifndef OK_TYPES_H
#define OK_TYPES_H

#include "ok/ok.h"

typedef enum {
    OK_VOID = 0,   /* internal: valueless function results */
    OK_NUMBER,     /* 64-bit signed integer (systems name: int64) */
    OK_DECIMAL,    /* IEEE-754 binary64 (systems name: f64)      */
    OK_TEXT,       /* immutable UTF-8 text (ptr, len)      */
    OK_BOOL,       /* true / false, 1 byte                 */
    OK_ARRAY,      /* fixed-length array of elem           */
    /* fixed-width integers (spec §4.2); int64 == number above */
    OK_INT8, OK_INT16, OK_INT32,
    OK_UINT8, OK_UINT16, OK_UINT32, OK_UINT64,
    OK_PTR,        /* pointer to elem (spec §12)           */
    OK_NULL,       /* the type of the `null` literal        */
    OK_STRUCT,     /* named record type (spec §8.3, 0.5)    */
    OK_NAMED,      /* parser placeholder: unresolved struct name */
} TypeKind;

/* OkType is a pointer to an interned descriptor. */
typedef struct Type *OkType;

typedef struct Type {
    TypeKind kind;
    struct Type *elem;   /* OK_ARRAY/OK_PTR: element/pointee type */
    size_t count;        /* OK_ARRAY: element count; OK_STRUCT: total bytes */
    char *name;          /* rendered name, owned     */
    int bits;            /* integer types: 8/16/32/64 (0 otherwise) */
    bool is_signed;      /* integer types: signedness                */
    struct StructField *sfields; /* OK_STRUCT: fields in declaration order */
    size_t nsfields;            /* OK_STRUCT: field count                  */
} Type;

/* one field of a struct (spec §8.3): natural alignment, declared order */
typedef struct StructField {
    char *name;      /* owned */
    OkType type;
    size_t offset;   /* byte offset within the struct */
} StructField;

/* scalar singletons (defined in types.c) */
extern OkType ty_void, ty_number, ty_decimal, ty_text, ty_bool;
extern OkType ty_int8, ty_int16, ty_int32;
extern OkType ty_uint8, ty_uint16, ty_uint32, ty_uint64;
extern OkType ty_null;   /* the literal `null`; assignable to any ptr<T> */

static inline TypeKind ty_kind(OkType t) { return t ? t->kind : OK_VOID; }

/* interned array type; count must be 1..OK_MAX_ARRAY_LEN */
OkType ty_array(OkType elem, size_t count);

/* interned pointer type ptr<T> (spec §12); elem must not be void/null */
OkType ty_ptr(OkType elem);

/* fresh parser placeholder for a named struct type (spec §8.3): starts as
 * OK_NAMED; sema fills it IN PLACE when the declaration is laid out, so
 * every reference (including interned arrays of it) resolves together */
OkType ty_named_placeholder(const char *name);

static inline bool ty_is_ptr(OkType t) { return t && t->kind == OK_PTR; }
static inline bool ty_is_struct(OkType t) { return t && t->kind == OK_STRUCT; }

/* struct field lookup by name; NULL when absent */
StructField *ty_field(OkType t, const char *name);

/* natural alignment of a type (1/2/4/8) */
size_t ty_align(OkType t);

/* "number" (etc.) from a name; false for unknown names or "array".
 * Accepts the fixed-width family and the aliases int64/byte/f64. */
bool ty_from_scalar_name(const char *s, OkType *out);

/* bytes of storage one value occupies
 * (bool = 1, int8/uint8 = 1, int16/uint16 = 2, int32/uint32 = 4,
 *  number/int64/uint64/decimal = 8, text = 16, array = elem bytes * n) */
size_t ty_bytes(OkType t);

/* words of 8 bytes (legacy helper used by slot layout) */
static inline int ok_type_words(OkType t) { return (int)((ty_bytes(t) + 7) / 8); }

/* ---- integer classification (spec §4.2) ---- */
static inline bool ty_is_fixed_int(OkType t) {
    return t && t->bits > 0 && t->kind != OK_NUMBER;
}
static inline bool ty_is_integer(OkType t) {
    /* number is the 64-bit signed integer; int64 is its alias */
    return t && (t->kind == OK_NUMBER || t->bits > 0);
}
static inline bool ty_is_signed(OkType t) { return t && t->is_signed; }
static inline int ty_bits(OkType t) { return t ? t->bits : 0; }

/* min/max of an integer type as int64 (uint64 max reported as -1 sentinel) */
int64_t ty_min_i64(OkType t);
int64_t ty_max_i64(OkType t);
/* does a non-negative literal value fit the type? (number always fits) */
bool ty_uint_fits(uint64_t v, OkType t);
/* does a signed constant value fit the type? (number always fits) */
bool ty_sint_fits(int64_t v, OkType t);

/* implicit conversion (assignment compatibility, spec §4.4): exact match,
 * safe widening (signed->wider signed, unsigned->wider unsigned,
 * unsigned->strictly-wider signed, any integer->decimal). */
bool ty_assignable(OkType from, OkType to);

/* common type for mixed integer/decimal arithmetic (spec §4.4): the
 * wider operand's type when one converts implicitly, decimal if either
 * side is decimal, NULL when the pair must convert explicitly. */
OkType ty_common(OkType a, OkType b);

/* explicit conversion (the `T.to_U(x)` builtins, spec §4.4): any integer
 * to any integer (wrap semantics), integer<->decimal, bool->number-ish.
 * text conversions are planned, not implemented. */
bool ty_convertible(OkType from, OkType to);

/* re-encode a 64-bit register representation from one integer type's
 * semantics to another's (truncating wrap; spec §4.2). Identity when
 * from == to. Value conventions per `bits`/`is_signed`. */
uint64_t ty_reencode(uint64_t v, OkType to);

/* ---- constant conversion helpers (used by sema and ir folding) ---- */
/* integer rep -> double (unsigned 64 converted exactly-when-possible) */
double ty_int_to_dec(uint64_t v, OkType from);
/* double -> integer rep of `to` (truncate toward zero, wrap on overflow;
 * NaN/out-of-range become the INT64_MIN sentinel, then wrap) */
uint64_t ty_dec_to_int(double d, OkType to);

/* rendered name ("number", "array<number, 5>"); stable, owned by the type */
const char *ok_type_name(OkType t);

#endif /* OK_TYPES_H */
