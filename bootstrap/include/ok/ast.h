/* ast.h — abstract syntax tree (brief §31).
 *
 * One arena-owned node struct with a kind tag and generous fields; simple,
 * leak-free by construction, and deliberately not tied to C implementation
 * details (names are unresolved dotted paths until sema).
 */
#ifndef OK_AST_H
#define OK_AST_H

#include "ok.h"
#include "ok/util.h"

typedef enum {
    /* expressions */
    A_INT, A_DEC, A_TEXT, A_BOOL,
    A_PATH,          /* dotted name path; resolved by sema */
    A_CALL,          /* path(args...) */
    A_WRITE,         /* write(args[0]) builtin call */
    A_BIN,           /* binary operator */
    A_UN,            /* unary operator (not / -) */
    A_ARRAYLIT,      /* { e1, e2, ... } array literal (declaration initializers) */
    A_INDEX,         /* base[index] (base in a, index in b) */
    A_CONV,          /* explicit conversion builtin T.to_U(x) (a = value, otype = target) */
    A_NULL,          /* the `null` literal (rtype ty_null) */
    A_ALLOC,         /* alloc<T>(count) (a = count, otype = ptr<T>) */
    A_MEMBER,        /* base.field — struct field access on a non-path base (spec §8.3) */
    A_TEXTOP,        /* text.length / text.byte_at / text.slice builtin (0.9, spec §4.5); fvalue = TextOp */
    A_FSOP,          /* fs.read / fs.save / fs.exists builtin (0.10, spec §6.4); fvalue = FsOp */
    A_ENVOP,         /* env.arg_count / env.arg builtin (0.12, spec §6.5); fvalue = EnvOp */
    /* statements */
    A_VARDECL,       /* type.<T> name = init (init may be A_ARRAYLIT) */
    A_ASSIGN,        /* path = value */
    A_INDEXASSIGN,   /* base[index] = value (base a, index b, value c) */
    A_DEREFASSIGN,   /* *ptr = value (ptr in a, value in c) — 0.4, spec §12 */
    A_RELEASE,       /* release(ptr) — statement, a = pointer expression */
    A_FIELDASSIGN,   /* base.field = value (a = base, name = field, c = value) — 0.5 */
    A_EXPRSTMT,      /* expression statement (calls / write only, checked in sema) */
    A_WHEN,          /* when (cond) { } else { } */
    A_LOOP_COUNT,    /* loop (i from a to/until b) { } */
    A_LOOP_COND,     /* loop (cond) { } */
    A_BREAK, A_CONTINUE, A_PRINT,
    A_RETURN,        /* return [expr] */
    /* top level */
    A_DIRECTIVE,     /* type.<feature>=<value> */
    A_LANGCOL,       /* [libs.use] = { ... }.end */
    A_DEVCOL,        /* name = { members }.end  (namespace) */
    A_STRUCTDECL,    /* struct.Name = { fields }.end — params[] are the fields (0.5) */
    A_UNIONDECL,     /* union.Name = { members }.end — params[] are the members (0.7, spec §8.5) */
    A_CONSTDECL,     /* const.name = expr — folded at compile time (0.8, spec §8.1) */
    A_FUNC,          /* function.<name>(params) -> ret { body } */
    A_FILE,          /* one parsed .ok file */
    /* sema-created (never in a parsed tree): the machine AST protocol's
     * kind numbers are append-only — selfhost/parser's N_* table mirrors
     * them, so new kinds MUST be added at the end, never inserted */
    A_SYSOP,         /* sys.* system-call builtin (0.13, spec §6.6); fvalue = SysOp */
} NodeKind;

typedef enum {
    OP_ADD, OP_SUB, OP_MUL, OP_DIV, OP_MOD,
    OP_EQ, OP_NEQ, OP_LT, OP_LE, OP_GT, OP_GE,
    OP_AND, OP_OR,
    /* bitwise (0.11, spec §9) — appended after OP_OR so the existing
     * `op <= OP_MOD` (arith) and `OP_EQ..OP_GE` (comparison) ranges hold */
    OP_BAND, OP_BOR, OP_XOR, OP_SHL, OP_SHR,
} BinOp;

typedef enum { UN_NEG, UN_NOT, UN_ADDR, UN_DEREF, UN_BNOT } UnOp;

/* text builtin sub-operations (A_TEXTOP, 0.9 spec §4.5) */
typedef enum { TOP_LEN, TOP_BYTE, TOP_SLICE, TOP_FROMBYTES } TextOp;

/* file builtin sub-operations (A_FSOP, 0.10 spec §6.4) */
typedef enum { FSOP_READ, FSOP_WRITE, FSOP_EXISTS } FsOp;

/* environment builtin sub-operations (A_ENVOP, 0.12 spec §6.5) */
typedef enum { ENVOP_ARGC, ENVOP_ARG } EnvOp;

/* system builtin sub-operations (A_SYSOP, 0.13 spec §6.6): the typed raw
 * syscall surface — the floor the Okular-written runtime is built on */
typedef enum {
    SYSOP_WRITE,     /* sys.write(fd, buf)            -> number  */
    SYSOP_READ,      /* sys.read(fd, buf, len)        -> number  */
    SYSOP_OPEN,      /* sys.open(path, flags, mode)   -> number  */
    SYSOP_CLOSE,     /* sys.close(fd)                 -> number  */
    SYSOP_SIZE,      /* sys.size(fd)                  -> number  */
    SYSOP_MMAP,      /* sys.mmap(len)                 -> ptr<byte> */
    SYSOP_EXIT,      /* sys.exit(code)                -> (never)  */
    SYSOP_CHMOD,     /* sys.chmod(path, mode)         -> number  */
    SYSOP_MKDIR,     /* sys.mkdir(path, mode)         -> number  (0.14) */
} SysOp;

typedef struct Node Node;

typedef struct {
    char *name;      /* owned */
    OkType type;
} Param;

struct Node {
    NodeKind kind;
    size_t line, col;

    /* literals */
    uint64_t ival;
    double dval;
    bool bval;
    char *str;           /* text literal (owned) */
    size_t str_len;
    char *name;          /* vardecl / function / devcol / loop-var name (owned) */
    char *spell;         /* raw source spelling of INT/DEC/TEXT literals (owned):
                          * the machine AST protocol serializes spellings and
                          * re-derives values, so unsigned 64-bit literals and
                          * escape processing stay identical by construction */

    /* dotted paths: parts[0].parts[1]... (owned strings) */
    char **parts;
    size_t nparts;

    /* children */
    Node *a, *b, *c;     /* generic: cond / lhs / init / from ...
                            A_INDEXASSIGN: a=base, b=index, c=value */
    Vec body;            /* Node* statement list (func/when/loop bodies, devcol members) */
    Vec body_else;       /* Node* else-body of when */
    Vec args;            /* Node* call arguments */
    Vec items;           /* char* language-column string items */
    Vec items_spell;     /* char* language-column RAW spellings (parallel to items;
                          * serialization only — the machine AST protocol carries
                          * raw spellings and unescapes on the consumer side) */

    OkType otype;        /* vardecl type / function return type / A_CONV target type */
    Param *params;       /* function parameters (owned array) */
    size_t nparams;

    BinOp op;            /* A_BIN */
    UnOp uop;            /* A_UN */
    bool inclusive;      /* loop `to` (true) vs `until` (false) */
    bool autoderef;      /* A_MEMBER/A_FIELDASSIGN: base is ptr<struct>, deref first */
    size_t offset;       /* A_MEMBER/A_FIELDASSIGN: field byte offset */
    int feature;         /* A_DIRECTIVE: index into ok_feature_names */
    int fvalue;          /* A_DIRECTIVE: value */

    /* sema annotations (filled by sema.c; IR reads them) */
    struct Symbol *sym;      /* resolved variable symbol (A_PATH/A_ASSIGN/A_VARDECL) */
    struct FuncInfo *finfo;  /* resolved function (A_CALL, A_FUNC) */
    OkType rtype;            /* checked expression result type */
    bool checked;            /* sema visited */
};

/* fresh zeroed node from the parser arena */
Node *node_new(Arena *ar, NodeKind kind, size_t line, size_t col);

/* --dump-ast rendering */
void ast_dump(Node *file_node, const char *file_display_name);

const char *binop_name(BinOp op);

#endif /* OK_AST_H */
