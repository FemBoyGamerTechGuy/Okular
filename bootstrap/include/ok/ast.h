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
    /* statements */
    A_VARDECL,       /* type.<T> name = init */
    A_ASSIGN,        /* path = value */
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
    A_FUNC,          /* function.<name>(params) -> ret { body } */
    A_FILE,          /* one parsed .ok file */
} NodeKind;

typedef enum {
    OP_ADD, OP_SUB, OP_MUL, OP_DIV, OP_MOD,
    OP_EQ, OP_NEQ, OP_LT, OP_LE, OP_GT, OP_GE,
    OP_AND, OP_OR,
} BinOp;

typedef enum { UN_NEG, UN_NOT } UnOp;

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

    /* dotted paths: parts[0].parts[1]... (owned strings) */
    char **parts;
    size_t nparts;

    /* children */
    Node *a, *b, *c;     /* generic: cond / lhs / init / from ... */
    Vec body;            /* Node* statement list (func/when/loop bodies, devcol members) */
    Vec body_else;       /* Node* else-body of when */
    Vec args;            /* Node* call arguments */
    Vec items;           /* char* language-column string items */

    OkType otype;        /* vardecl type / function return type */
    Param *params;       /* function parameters (owned array) */
    size_t nparams;

    BinOp op;            /* A_BIN */
    UnOp uop;            /* A_UN */
    bool inclusive;      /* loop `to` (true) vs `until` (false) */
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
