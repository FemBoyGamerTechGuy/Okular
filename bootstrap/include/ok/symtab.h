/* symtab.h — symbols and scopes (brief §32). */
#ifndef OK_SYMTAB_H
#define OK_SYMTAB_H

#include "ok.h"
#include "ok/util.h"

struct Node;
struct OkModule;

typedef enum { SYM_FUNC, SYM_VAR, SYM_NS, SYM_TYPE } SymKind;

typedef struct FuncInfo {
    char *name;             /* simple name */
    char *mangled;          /* assembly symbol (ok_<module>[_<col>]_<name>) */
    OkType ret;
    OkType *param_types;
    char **param_names;
    struct Symbol **param_syms; /* filled by sema (slot pre-assignment) */
    size_t nparams;
    struct Node *decl;      /* A_FUNC node (annotated back-pointer) */
    struct OkModule *module;
    bool is_entry;          /* synthesized __ok_entry for main.ok top level */
} FuncInfo;

/* constant value for global initializers (spec §7/§8: constants only).
 * Arrays carry their element constants recursively (spec §8.4). */
typedef struct ConstVal {
    bool valid;
    OkType type;
    uint64_t i;
    double d;
    bool b;
    char *t;                /* owned bytes */
    size_t t_len;
    struct ConstVal *elems; /* array elements (owned) */
    size_t nelems;
} ConstVal;

typedef struct Symbol {
    char *name;
    SymKind kind;
    OkType type;            /* SYM_VAR / SYM_TYPE (the struct descriptor) */
    char *mangled;          /* globals: assembly symbol */
    FuncInfo *func;         /* SYM_FUNC */
    struct Scope *ns;       /* SYM_NS: the namespace scope */
    struct Scope *scope;    /* owning scope */
    struct Node *decl;      /* declaration node */
    bool is_global;
    bool used;              /* locals: usage tracking for -w */
    size_t line, col;       /* declaration site */
    ConstVal cval;          /* globals: initializer constant */
} Symbol;

typedef struct Scope {
    const char *label;      /* "the file", "column `physics`", "the block" */
    struct Scope *parent;
    Symbol **syms;
    size_t n, cap;
} Scope;

Scope *scope_new(const char *label, Scope *parent);

/* Inserts; returns existing symbol if duplicate (caller reports). */
Symbol *scope_insert(Scope *s, const char *name, SymKind kind, size_t line, size_t col);

Symbol *scope_find_local(Scope *s, const char *name);
Symbol *scope_lookup(Scope *s, const char *name);       /* walk parents */
Symbol *scope_lookup_nslocal(Scope *s, const char *name); /* walk parents, NS transparent */

FuncInfo *funcinfo_new(const char *name, const char *mangled, OkType ret,
                       struct Node *decl, struct OkModule *mod);

#endif /* OK_SYMTAB_H */
