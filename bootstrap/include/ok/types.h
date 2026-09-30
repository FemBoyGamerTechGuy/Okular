/* types.h — the Okular type system (spec §4).
 *
 * Types are interned descriptors, not enum values: `OkType` is a pointer,
 * and two types are the same type exactly when their pointers are equal.
 * Scalars are singletons; array types are interned per (element, count).
 *
 * This is the M2 refactor that makes arrays possible and the later pointer
 * and struct milestones natural (brief §7: "a serious Okular type system").
 */
#ifndef OK_TYPES_H
#define OK_TYPES_H

#include "ok/ok.h"

typedef enum {
    OK_VOID = 0,   /* internal: valueless function results */
    OK_NUMBER,     /* 64-bit signed integer                */
    OK_DECIMAL,    /* IEEE-754 binary64                    */
    OK_TEXT,       /* immutable UTF-8 text (ptr, len)      */
    OK_BOOL,       /* true / false                         */
    OK_ARRAY,      /* fixed-length array of elem           */
} TypeKind;

typedef struct Type {
    TypeKind kind;
    struct Type *elem;   /* OK_ARRAY: element type   */
    size_t count;        /* OK_ARRAY: element count  */
    char *name;          /* rendered name, owned     */
} Type;

/* OkType is now a pointer to an interned descriptor. */
typedef struct Type *OkType;

/* scalar singletons (defined in types.c) */
extern OkType ty_void, ty_number, ty_decimal, ty_text, ty_bool;

static inline TypeKind ty_kind(OkType t) { return t ? t->kind : OK_VOID; }

/* interned array type; count must be 1..OK_MAX_ARRAY_LEN */
OkType ty_array(OkType elem, size_t count);

/* "number" (etc.) from a name; false for unknown names or "array" */
bool ty_from_scalar_name(const char *s, OkType *out);

/* bytes of storage one value occupies (text = 16, array = elem bytes * n) */
size_t ty_bytes(OkType t);

/* words of 8 bytes (legacy helper used by slot layout) */
static inline int ok_type_words(OkType t) { return (int)(ty_bytes(t) / 8); }

/* rendered name ("number", "array<number, 5>"); stable, owned by the type */
const char *ok_type_name(OkType t);

#endif /* OK_TYPES_H */
