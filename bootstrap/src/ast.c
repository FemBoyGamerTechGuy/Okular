/* ast.c — node construction + AST dump (used by --dump-ast and tests). */
#include "ok/ast.h"

Node *node_new(Arena *ar, NodeKind kind, size_t line, size_t col) {
    Node *n = arena_alloc(ar, sizeof *n);
    memset(n, 0, sizeof *n);
    n->kind = kind;
    n->line = line;
    n->col = col;
    return n;
}

const char *binop_name(BinOp op) {
    switch (op) {
    case OP_ADD: return "+";  case OP_SUB: return "-";
    case OP_MUL: return "*";  case OP_DIV: return "/";
    case OP_MOD: return "%";
    case OP_EQ:  return "=="; case OP_NEQ: return "!=";
    case OP_LT:  return "<";  case OP_LE: return "<=";
    case OP_GT:  return ">";  case OP_GE: return ">=";
    case OP_AND: return "and"; case OP_OR: return "or";
    }
    return "?";
}

/* ---------------- dump ---------------- */

static void dump_path(char **parts, size_t n) {
    for (size_t i = 0; i < n; i++)
        printf("%s%s", i ? "." : "", parts[i]);
}

static void dump_expr(Node *e, int ind);

static void dump_stmt_list(Vec *body, int ind);

static void pad(int n) { for (int i = 0; i < n; i++) putchar(' '); }

static void dump_stmt(Node *s, int ind) {
    pad(ind);
    switch (s->kind) {
    case A_VARDECL:
        printf("vardecl %s : %s\n", s->name, ok_type_name(s->otype));
        dump_expr(s->a, ind + 2);
        break;
    case A_ASSIGN:
        printf("assign ");
        dump_path(s->parts, s->nparts);
        printf("\n");
        dump_expr(s->a, ind + 2);
        break;
    case A_EXPRSTMT:
        printf("exprstmt\n");
        dump_expr(s->a, ind + 2);
        break;
    case A_INDEXASSIGN:
        printf("index-assign\n");
        dump_expr(s->a, ind + 2);
        dump_expr(s->b, ind + 2);
        dump_expr(s->c, ind + 2);
        break;
    case A_DEREFASSIGN:
        printf("deref-assign\n");
        dump_expr(s->a, ind + 2);
        dump_expr(s->c, ind + 2);
        break;
    case A_FIELDASSIGN:
        printf("field-assign .%s\n", s->name);
        dump_expr(s->a, ind + 2);
        dump_expr(s->c, ind + 2);
        break;
    case A_RELEASE:
        printf("release\n");
        dump_expr(s->a, ind + 2);
        break;
    case A_WHEN:
        printf("when\n");
        dump_expr(s->a, ind + 2);
        pad(ind + 2); printf("then:\n");
        dump_stmt_list(&s->body, ind + 4);
        if (s->body_else.len) {
            pad(ind + 2); printf("else:\n");
            dump_stmt_list(&s->body_else, ind + 4);
        }
        break;
    case A_LOOP_COUNT:
        printf("loop-count var=%s %s\n", s->name, s->inclusive ? "to" : "until");
        dump_expr(s->a, ind + 2);   /* from */
        dump_expr(s->b, ind + 2);   /* bound */
        dump_stmt_list(&s->body, ind + 2);
        break;
    case A_LOOP_COND:
        printf("loop-cond\n");
        dump_expr(s->a, ind + 2);
        dump_stmt_list(&s->body, ind + 2);
        break;
    case A_BREAK:     printf("break\n"); break;
    case A_CONTINUE:  printf("continue\n"); break;
    case A_PRINT:     printf("print\n"); break;
    case A_WRITE:
        printf("write\n");
        for (size_t i = 0; i < s->args.len; i++)
            dump_expr((Node *)s->args.items[i], ind + 2);
        break;
    case A_DIRECTIVE:
        printf("directive\n");
        break;
    case A_LANGCOL:
        printf("langcol\n");
        break;
    case A_RETURN:
        printf("return\n");
        if (s->a) dump_expr(s->a, ind + 2);
        break;
    default:
        printf("?stmt(%d)\n", (int)s->kind);
    }
}

static void dump_stmt_list(Vec *body, int ind) {
    for (size_t i = 0; i < body->len; i++)
        dump_stmt((Node *)body->items[i], ind);
}

static void dump_expr(Node *e, int ind) {
    pad(ind);
    if (!e) { printf("(nil)\n"); return; }
    switch (e->kind) {
    case A_INT:  printf("int %llu\n", (unsigned long long)e->ival); break;
    case A_DEC:  printf("dec %g\n", e->dval); break;
    case A_BOOL: printf("bool %s\n", e->bval ? "true" : "false"); break;
    case A_TEXT: printf("text \"%.*s\" (%zu bytes)\n", (int)e->str_len, e->str, e->str_len); break;
    case A_PATH:
        printf("path ");
        dump_path(e->parts, e->nparts);
        printf("\n");
        break;
    case A_CALL:
        printf("call ");
        dump_path(e->parts, e->nparts);
        printf(" (%zu args)\n", e->args.len);
        for (size_t i = 0; i < e->args.len; i++)
            dump_expr((Node *)e->args.items[i], ind + 2);
        break;
    case A_WRITE:
        printf("write (%zu args)\n", e->args.len);
        for (size_t i = 0; i < e->args.len; i++)
            dump_expr((Node *)e->args.items[i], ind + 2);
        break;
    case A_BIN:
        printf("binop %s\n", binop_name(e->op));
        dump_expr(e->a, ind + 2);
        dump_expr(e->b, ind + 2);
        break;
    case A_UN:
        printf("unop %s\n",
               e->uop == UN_NEG ? "-" : e->uop == UN_NOT ? "not"
               : e->uop == UN_ADDR ? "&" : "*");
        dump_expr(e->a, ind + 2);
        break;
    case A_NULL:
        printf("null\n");
        break;
    case A_ALLOC:
        printf("alloc -> %s\n", ok_type_name(e->otype));
        dump_expr(e->a, ind + 2);
        break;
    case A_MEMBER:
        printf("member .%s\n", e->name);
        dump_expr(e->a, ind + 2);
        break;
    case A_ARRAYLIT:
        printf("arraylit (%zu elements)\n", e->args.len);
        for (size_t i = 0; i < e->args.len; i++)
            dump_expr((Node *)e->args.items[i], ind + 2);
        break;
    case A_INDEX:
        printf("index\n");
        dump_expr(e->a, ind + 2);
        dump_expr(e->b, ind + 2);
        break;
    case A_CONV:
        printf("conv -> %s\n", ok_type_name(e->otype));
        dump_expr(e->a, ind + 2);
        break;
    default:
        printf("?expr(%d)\n", (int)e->kind);
    }
}

static void dump_top(Node *n, int ind) {
    pad(ind);
    switch (n->kind) {
    case A_DIRECTIVE:
        printf("directive %s=%d\n", ok_feature_names[n->feature], n->fvalue);
        break;
    case A_LANGCOL:
        printf("langcol [");
        dump_path(n->parts, n->nparts);
        printf("]\n");
        for (size_t i = 0; i < n->items.len; i++) {
            pad(ind + 2);
            printf("\"%s\"\n", (char *)n->items.items[i]);
        }
        break;
    case A_DEVCOL:
        printf("devcol %s = {\n", n->name);
        for (size_t i = 0; i < n->body.len; i++)
            dump_top((Node *)n->body.items[i], ind + 2);
        pad(ind); printf("}.end\n");
        break;
    case A_STRUCTDECL:
        printf("struct %s = {\n", n->name);
        for (size_t i = 0; i < n->nparams; i++) {
            pad(ind + 2);
            printf("%s %s\n", ok_type_name(n->params[i].type), n->params[i].name);
        }
        pad(ind); printf("}.end\n");
        break;
    case A_UNIONDECL:
        printf("union %s = {\n", n->name);
        for (size_t i = 0; i < n->nparams; i++) {
            pad(ind + 2);
            printf("%s %s\n", ok_type_name(n->params[i].type), n->params[i].name);
        }
        pad(ind); printf("}.end\n");
        break;
    case A_CONSTDECL:
        printf("const %s = ", n->name);
        dump_expr(n->a, 0);
        break;
    case A_FUNC:
        printf("func %s(", n->name);
        for (size_t i = 0; i < n->nparams; i++)
            printf("%s%s.%s", i ? ", " : "", ok_type_name(n->params[i].type), n->params[i].name);
        printf(") -> %s\n", ok_type_name(n->otype));
        dump_stmt_list(&n->body, ind + 2);
        break;
    case A_VARDECL:
        printf("global vardecl %s : %s\n", n->name, ok_type_name(n->otype));
        dump_expr(n->a, ind + 2);
        break;
    default:
        /* top-level statement (only legal in main.ok; sema enforces) */
        dump_stmt(n, ind);
    }
}

void ast_dump(Node *file_node, const char *file_display_name) {
    printf("== AST: %s ==\n", file_display_name);
    for (size_t i = 0; i < file_node->body.len; i++)
        dump_top((Node *)file_node->body.items[i], 0);
}
