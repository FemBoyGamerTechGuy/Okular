/* ir.c — IR construction + constant folding. */
#include "ok/ir.h"

/* ---------------- IrFunc plumbing ---------------- */

static IrFunc *irfunc_new(FuncInfo *fi) {
    IrFunc *f = ok_xmalloc(sizeof *f);
    memset(f, 0, sizeof *f);
    f->fi = fi;
    return f;
}

static void emit(IrFunc *f, IrInst inst) {
    if (f->n == f->cap) {
        f->cap = f->cap ? f->cap * 2 : 64;
        f->insts = ok_xrealloc(f->insts, f->cap * sizeof(IrInst));
    }
    f->insts[f->n++] = inst;
}

static int new_label(IrFunc *f) { return f->nlabels++; }

static int slot_for(IrFunc *f, Symbol *sym) {
    for (size_t i = 0; i < f->nslots; i++)
        if (f->slots[i].sym == sym) return (int)i;
    if (f->nslots == f->slots_cap) {
        f->slots_cap = f->slots_cap ? f->slots_cap * 2 : 8;
        f->slots = ok_xrealloc(f->slots, f->slots_cap * sizeof(IrSlot));
    }
    f->slots[f->nslots].sym = sym;
    f->slots[f->nslots].type = sym->type;
    return (int)f->nslots++;
}

static int intern_text(IrModule *im, const char *bytes, size_t len) {
    for (size_t i = 0; i < im->ntexts; i++)
        if (im->texts[i].len == len && memcmp(im->texts[i].bytes, bytes, len) == 0)
            return (int)i;
    if (im->ntexts == im->texts_cap) {
        im->texts_cap = im->texts_cap ? im->texts_cap * 2 : 8;
        im->texts = ok_xrealloc(im->texts, im->texts_cap * sizeof(IrText));
    }
    im->texts[im->ntexts].bytes = ok_xstrndup(bytes, len);
    im->texts[im->ntexts].len = len;
    return (int)im->ntexts++;
}

/* ---------------- expression lowering ---------------- */

typedef struct {
    IrFunc *f;
    IrModule *im;
} Ctx;

static void build_expr(Ctx *c, Node *e);

/* build operand and widen number->decimal if the parent needs decimal */
static void build_operand_conv(Ctx *c, Node *operand, OkType want) {
    build_expr(c, operand);
    if (want == OK_DECIMAL && operand->rtype == OK_NUMBER) {
        IrInst inst = { .kind = I_CONV_NUM_DEC, .type = OK_DECIMAL,
                        .line = operand->line, .col = operand->col };
        emit(c->f, inst);
    }
}

static void build_store(Ctx *c, Symbol *sym) {
    IrInst inst = { .line = sym->line, .col = sym->col };
    if (sym->is_global) {
        inst.kind = I_STORE_GLOBAL;
        inst.sym = sym;
        inst.type = sym->type;
    } else {
        inst.kind = I_STORE_LOCAL;
        inst.slot = slot_for(c->f, sym);
        inst.type = sym->type;
    }
    emit(c->f, inst);
}

static void build_expr(Ctx *c, Node *e) {
    switch (e->kind) {
    case A_INT: {
        IrInst inst = { .kind = I_CONST_INT, .type = OK_NUMBER, .i = e->ival,
                        .line = e->line, .col = e->col };
        emit(c->f, inst);
        break;
    }
    case A_DEC: {
        IrInst inst = { .kind = I_CONST_DEC, .type = OK_DECIMAL, .d = e->dval,
                        .line = e->line, .col = e->col };
        emit(c->f, inst);
        break;
    }
    case A_BOOL: {
        IrInst inst = { .kind = I_CONST_BOOL, .type = OK_BOOL, .b = e->bval,
                        .line = e->line, .col = e->col };
        emit(c->f, inst);
        break;
    }
    case A_TEXT: {
        int idx = intern_text(c->im, e->str, e->str_len);
        IrInst inst = { .kind = I_CONST_TEXT, .type = OK_TEXT, .text_idx = idx,
                        .line = e->line, .col = e->col };
        emit(c->f, inst);
        break;
    }
    case A_PATH: {
        Symbol *s = e->sym;
        if (!s) { OK_ICE("A_PATH without a resolved symbol at %zu:%zu", e->line, e->col); }
        IrInst inst = { .line = e->line, .col = e->col };
        if (s->is_global) {
            inst.kind = I_LOAD_GLOBAL;
            inst.sym = s;
            inst.type = s->type;
        } else {
            inst.kind = I_LOAD_LOCAL;
            inst.slot = slot_for(c->f, s);
            inst.type = s->type;
        }
        emit(c->f, inst);
        break;
    }
    case A_CALL: {
        FuncInfo *fi = e->finfo;
        if (!fi) { OK_ICE("A_CALL without a resolved function at %zu:%zu", e->line, e->col); }
        /* arguments: evaluate right-to-left so the machine stack layout
         * matches the Okular ABI (docs/architecture.md §3.5) */
        for (size_t k = e->args.len; k-- > 0; ) {
            Node *arg = e->args.items[k];
            OkType want = (k < fi->nparams) ? fi->param_types[k] : arg->rtype;
            build_operand_conv(c, arg, want);
        }
        IrInst inst = { .kind = I_CALL, .sym = fi, .nargs = (int)e->args.len,
                        .type = fi->ret, .line = e->line, .col = e->col };
        emit(c->f, inst);
        break;
    }
    case A_WRITE: {
        /* write is a statement; reach here only via bad ASTs (sema errored) */
        for (size_t k = 0; k < e->args.len; k++)
            build_expr(c, (Node *)e->args.items[k]);
        break;
    }
    case A_BIN: {
        /* operand type after widening: decimal if either side is decimal */
        OkType want_l = (e->b->rtype == OK_DECIMAL) ? OK_DECIMAL : e->a->rtype;
        OkType want_r = (e->a->rtype == OK_DECIMAL) ? OK_DECIMAL : e->b->rtype;
        build_operand_conv(c, e->a, want_l);
        build_operand_conv(c, e->b, want_r);
        OkType ot = (want_l == OK_DECIMAL || want_r == OK_DECIMAL) ? OK_DECIMAL : want_l;
        IrInst inst = { .kind = I_BINOP, .op = e->op, .type = ot,
                        .line = e->line, .col = e->col };
        emit(c->f, inst);
        break;
    }
    case A_UN: {
        build_expr(c, e->a);
        IrInst inst = { .kind = I_UNOP, .uop = e->uop, .type = e->a->rtype,
                        .line = e->line, .col = e->col };
        emit(c->f, inst);
        break;
    }
    default:
        OK_ICE("unexpected node kind %d in expression lowering at %zu:%zu",
               (int)e->kind, e->line, e->col);
    }
}

/* ---------------- statement lowering ---------------- */

typedef struct LoopCtx {
    struct LoopCtx *prev;
    int lbl_break;
    int lbl_continue;
} LoopCtx;

typedef struct StmtCtx {
    Ctx *c;
    LoopCtx *loop;
    FuncInfo *fi;
} StmtCtx;

static void build_stmt(StmtCtx *sc, Node *s);

static void build_stmt_list(StmtCtx *sc, Vec *body) {
    for (size_t i = 0; i < body->len; i++)
        build_stmt(sc, (Node *)body->items[i]);
}

static void build_stmt(StmtCtx *sc, Node *s) {
    Ctx *c = sc->c;
    IrFunc *f = c->f;
    switch (s->kind) {
    case A_VARDECL: {
        /* local declaration: evaluate init, convert, store */
        Symbol *sym = s->sym;
        build_operand_conv(c, s->a, sym->type);
        build_store(c, sym);
        break;
    }
    case A_ASSIGN: {
        Symbol *sym = s->sym;
        build_operand_conv(c, s->a, sym->type);
        build_store(c, sym);
        break;
    }
    case A_EXPRSTMT: {
        Node *e = s->a;
        if (e->kind == A_WRITE) {
            Node *arg = e->args.len ? (Node *)e->args.items[0] : NULL;
            if (arg) build_expr(c, arg);
            IrInst w = { .kind = I_WRITE, .type = arg ? arg->rtype : OK_VOID,
                         .line = s->line, .col = s->col };
            emit(f, w);
        } else {
            build_expr(c, e);
            if (e->kind == A_CALL && ((FuncInfo *)e->finfo)->ret != OK_VOID) {
                IrInst p = { .kind = I_POP, .type = ((FuncInfo *)e->finfo)->ret,
                             .line = s->line, .col = s->col };
                emit(f, p);
            }
        }
        break;
    }
    case A_WRITE: {
        Node *arg = s->args.len ? (Node *)s->args.items[0] : NULL;
        if (arg) build_expr(c, arg);
        IrInst w = { .kind = I_WRITE, .type = arg ? arg->rtype : OK_VOID,
                     .line = s->line, .col = s->col };
        emit(f, w);
        break;
    }
    case A_WHEN: {
        int l_else = new_label(f);
        int l_end = new_label(f);
        build_expr(c, s->a);
        IrInst jf = { .kind = I_JMPF, .label = l_else, .line = s->line, .col = s->col };
        emit(f, jf);
        build_stmt_list(sc, &s->body);
        if (s->body_else.len) {
            IrInst j = { .kind = I_JMP, .label = l_end, .line = s->line, .col = s->col };
            emit(f, j);
            IrInst le = { .kind = I_LABEL, .label = l_else };
            emit(f, le);
            build_stmt_list(sc, &s->body_else);
            IrInst lend = { .kind = I_LABEL, .label = l_end };
            emit(f, lend);
        } else {
            IrInst le = { .kind = I_LABEL, .label = l_else };
            emit(f, le);
        }
        break;
    }
    case A_LOOP_COUNT: {
        /* loop (i from A to B) — inclusive; `until` exclusive (spec §10).
         * The loop variable symbol was created by sema and attached to the
         * node; the bound is a hidden slot evaluated once (spec §10). */
        Symbol *ivar = s->sym;
        if (!ivar) OK_ICE("counted loop without a symbol at %zu:%zu", s->line, s->col);

        Symbol *bs = ok_xmalloc(sizeof *bs);
        memset(bs, 0, sizeof *bs);
        bs->name = ok_xmalloc(strlen(ivar->name) + 8);
        sprintf(bs->name, "%s$bound", ivar->name);
        bs->kind = SYM_VAR;
        bs->type = OK_NUMBER;

        /* init: i = from */
        build_expr(c, s->a);
        build_store(c, ivar);
        /* bound = to/until-expr (evaluated once) */
        build_expr(c, s->b);
        build_store(c, bs);

        int l_check = new_label(f);
        int l_cont = new_label(f);
        int l_exit = new_label(f);

        IrInst lab = { .kind = I_LABEL, .label = l_check };
        emit(f, lab);
        /* i <= bound (to)  /  i < bound (until) */
        IrInst l1 = { .kind = I_LOAD_LOCAL, .slot = slot_for(f, ivar), .type = OK_NUMBER };
        emit(f, l1);
        IrInst l2 = { .kind = I_LOAD_LOCAL, .slot = slot_for(f, bs), .type = OK_NUMBER };
        emit(f, l2);
        IrInst cmp = { .kind = I_BINOP, .op = s->inclusive ? OP_LE : OP_LT,
                       .type = OK_NUMBER, .line = s->line, .col = s->col };
        emit(f, cmp);
        IrInst jf2 = { .kind = I_JMPF, .label = l_exit };
        emit(f, jf2);

        LoopCtx lc = { .prev = sc->loop, .lbl_break = l_exit, .lbl_continue = l_cont };
        sc->loop = &lc;
        build_stmt_list(sc, &s->body);
        sc->loop = lc.prev;

        IrInst lcont = { .kind = I_LABEL, .label = l_cont };
        emit(f, lcont);
        /* i = i + 1 */
        IrInst li = { .kind = I_LOAD_LOCAL, .slot = slot_for(f, ivar), .type = OK_NUMBER };
        emit(f, li);
        IrInst one = { .kind = I_CONST_INT, .type = OK_NUMBER, .i = 1 };
        emit(f, one);
        IrInst inc = { .kind = I_BINOP, .op = OP_ADD, .type = OK_NUMBER };
        emit(f, inc);
        build_store(c, ivar);
        IrInst back = { .kind = I_JMP, .label = l_check };
        emit(f, back);
        IrInst lexit = { .kind = I_LABEL, .label = l_exit };
        emit(f, lexit);
        break;
    }
    case A_LOOP_COND: {
        int l_start = new_label(f);
        int l_cont = new_label(f);
        int l_exit = new_label(f);
        IrInst lab = { .kind = I_LABEL, .label = l_start };
        emit(f, lab);
        build_expr(c, s->a);
        IrInst jf = { .kind = I_JMPF, .label = l_exit };
        emit(f, jf);
        LoopCtx lc = { .prev = sc->loop, .lbl_break = l_exit, .lbl_continue = l_cont };
        sc->loop = &lc;
        build_stmt_list(sc, &s->body);
        sc->loop = lc.prev;
        IrInst lc2 = { .kind = I_LABEL, .label = l_cont };
        emit(f, lc2);
        IrInst back = { .kind = I_JMP, .label = l_start };
        emit(f, back);
        IrInst lex = { .kind = I_LABEL, .label = l_exit };
        emit(f, lex);
        break;
    }
    case A_BREAK: {
        if (!sc->loop) OK_ICE("`break` outside a loop reached IR (sema bug) at %zu:%zu", s->line, s->col);
        IrInst j = { .kind = I_JMP, .label = sc->loop->lbl_break, .line = s->line, .col = s->col };
        emit(f, j);
        break;
    }
    case A_CONTINUE: {
        if (!sc->loop) OK_ICE("`continue` outside a loop reached IR (sema bug) at %zu:%zu", s->line, s->col);
        IrInst j = { .kind = I_JMP, .label = sc->loop->lbl_continue, .line = s->line, .col = s->col };
        emit(f, j);
        break;
    }
    case A_PRINT: {
        IrInst p = { .kind = I_PRINT, .line = s->line, .col = s->col };
        emit(f, p);
        break;
    }
    case A_RETURN: {
        if (s->a) {
            build_operand_conv(c, s->a, sc->fi->ret);
        } else if (sc->fi->is_entry) {
            /* top-level bare return exits with code 0 (spec §7) */
            IrInst z = { .kind = I_CONST_INT, .type = OK_NUMBER, .i = 0 };
            emit(f, z);
        }
        IrInst r = { .kind = I_RETURN, .type = s->a ? s->a->rtype : OK_VOID,
                     .line = s->line, .col = s->col };
        emit(f, r);
        break;
    }
    default:
        OK_ICE("unexpected node kind %d in statement lowering at %zu:%zu",
               (int)s->kind, s->line, s->col);
    }
}

/* ---------------- module ---------------- */

static void build_function(IrModule *im, Node *fn, FuncInfo *fi) {
    IrFunc *f = irfunc_new(fi);
    Ctx c = { f, im };
    /* parameters get the first slots */
    for (size_t i = 0; i < fi->nparams; i++)
        slot_for(f, fi->param_syms[i]);
    StmtCtx sc = { &c, NULL, fi };
    build_stmt_list(&sc, &fn->body);
    ir_fold(f);
    vec_push(&im->funcs, f);
}

static void build_column(IrModule *im, Node *col) {
    for (size_t i = 0; i < col->body.len; i++) {
        Node *mem = col->body.items[i];
        if (mem->kind == A_FUNC && mem->finfo) build_function(im, mem, mem->finfo);
        else if (mem->kind == A_VARDECL && mem->sym) vec_push(&im->globals, mem->sym);
        else if (mem->kind == A_DEVCOL) build_column(im, mem);
    }
}

IrModule *ir_build_module(OkModule *m) {
    if (m->state != MOD_LOADED) return NULL;
    IrModule *im = ok_xmalloc(sizeof *im);
    memset(im, 0, sizeof *im);
    im->mod = m;
    vec_init(&im->funcs);
    vec_init(&im->globals);

    for (size_t i = 0; i < m->ast->body.len; i++) {
        Node *n = m->ast->body.items[i];
        switch (n->kind) {
        case A_FUNC:
            if (n->finfo) build_function(im, n, n->finfo);
            break;
        case A_VARDECL:
            if (n->sym) vec_push(&im->globals, n->sym);
            break;
        case A_DEVCOL:
            build_column(im, n);
            break;
        default:
            /* statements at top level (main.ok): entry function */
            break;
        }
    }

    /* entry function from main.ok top-level statements */
    if (m->entry && strcmp(m->name, "main") == 0) {
        IrFunc *f = irfunc_new(m->entry);
        Ctx c = { f, im };
        StmtCtx sc = { &c, NULL, m->entry };
        for (size_t i = 0; i < m->ast->body.len; i++) {
            Node *n = m->ast->body.items[i];
            switch (n->kind) {
            case A_DIRECTIVE: case A_LANGCOL: case A_FUNC:
            case A_VARDECL: case A_DEVCOL:
                break;
            default:
                build_stmt(&sc, n);
                break;
            }
        }
        ir_fold(f);
        vec_push(&im->funcs, f);
    }

    if (im->funcs.len == 0 && im->globals.len == 0) {
        ir_module_free(im);
        return NULL;
    }
    return im;
}

/* ---------------- constant folding (spec §15: the first opt pass) ---------------- */

typedef struct FoldVal {
    bool known;
    OkType type;
    uint64_t i;
    double d;
    bool b;
    int text;
} FoldVal;

void ir_fold(IrFunc *f) {
    FoldVal *stack = ok_xmalloc((f->n + 8) * sizeof(FoldVal));
    size_t sp = 0;
    IrInst *out = ok_xmalloc((f->n ? f->n : 1) * sizeof(IrInst));
    size_t on = 0;

    for (size_t pc = 0; pc < f->n; pc++) {
        IrInst in = f->insts[pc];
        FoldVal v = { .known = false };
        switch (in.kind) {
        case I_CONST_INT:  v.known = true; v.type = OK_NUMBER; v.i = in.i; break;
        case I_CONST_DEC:  v.known = true; v.type = OK_DECIMAL; v.d = in.d; break;
        case I_CONST_BOOL: v.known = true; v.type = OK_BOOL; v.b = in.b; break;
        case I_CONST_TEXT: v.known = true; v.type = OK_TEXT; v.text = in.text_idx; break;
        default: break;
        }

        if (in.kind == I_BINOP && sp >= 2 && stack[sp - 1].known && stack[sp - 2].known) {
            FoldVal r = stack[sp - 1], l = stack[sp - 2];
            FoldVal res = { .known = true };
            bool ok = true;
            if (l.type == OK_NUMBER && r.type == OK_NUMBER) {
                res.type = OK_NUMBER;
                switch (in.op) {
                case OP_ADD: res.i = l.i + r.i; break;
                case OP_SUB: res.i = l.i - r.i; break;
                case OP_MUL: res.i = l.i * r.i; break;
                case OP_DIV: if (r.i == 0) { ok = false; break; } res.i = l.i / r.i; break;
                case OP_MOD: if (r.i == 0) { ok = false; break; } res.i = l.i % r.i; break;
                default:
                    res.type = OK_BOOL;
                    switch (in.op) {
                    case OP_EQ: res.b = l.i == r.i; break;
                    case OP_NEQ: res.b = l.i != r.i; break;
                    case OP_LT: res.b = l.i < r.i; break;
                    case OP_LE: res.b = l.i <= r.i; break;
                    case OP_GT: res.b = l.i > r.i; break;
                    case OP_GE: res.b = l.i >= r.i; break;
                    default: ok = false;
                    }
                }
            } else if (l.type == OK_DECIMAL && r.type == OK_DECIMAL) {
                res.type = OK_DECIMAL;
                switch (in.op) {
                case OP_ADD: res.d = l.d + r.d; break;
                case OP_SUB: res.d = l.d - r.d; break;
                case OP_MUL: res.d = l.d * r.d; break;
                case OP_DIV: res.d = l.d / r.d; break;
                default: ok = false;
                }
            } else if (l.type == OK_BOOL && r.type == OK_BOOL) {
                res.type = OK_BOOL;
                if (in.op == OP_AND) res.b = l.b && r.b;
                else if (in.op == OP_OR) res.b = l.b || r.b;
                else if (in.op == OP_EQ) res.b = l.b == r.b;
                else if (in.op == OP_NEQ) res.b = l.b != r.b;
                else ok = false;
            } else if (l.type == OK_TEXT && r.type == OK_TEXT && in.op == OP_EQ) {
                res.type = OK_BOOL;
                res.b = l.text == r.text;
            } else if (l.type == OK_TEXT && r.type == OK_TEXT && in.op == OP_NEQ) {
                res.type = OK_BOOL;
                res.b = l.text != r.text;
            } else ok = false;

            if (ok) {
                sp -= 2;
                stack[sp++] = res;
                IrInst ci;
                memset(&ci, 0, sizeof ci);
                ci.line = in.line; ci.col = in.col;
                if (res.type == OK_NUMBER) { ci.kind = I_CONST_INT; ci.i = res.i; ci.type = OK_NUMBER; }
                else if (res.type == OK_DECIMAL) { ci.kind = I_CONST_DEC; ci.d = res.d; ci.type = OK_DECIMAL; }
                else if (res.type == OK_BOOL) { ci.kind = I_CONST_BOOL; ci.b = res.b; ci.type = OK_BOOL; }
                else { ci.kind = I_CONST_TEXT; ci.text_idx = res.text; ci.type = OK_TEXT; }
                out[on++] = ci;
                continue;
            }
        }

        if (in.kind == I_UNOP && sp >= 1 && stack[sp - 1].known) {
            FoldVal a = stack[sp - 1];
            if (in.uop == UN_NEG && a.type == OK_NUMBER) {
                sp--;
                FoldVal res = { .known = true, .type = OK_NUMBER, .i = (uint64_t)(-(int64_t)a.i) };
                stack[sp++] = res;
                IrInst ci = { .kind = I_CONST_INT, .type = OK_NUMBER, .i = res.i, .line = in.line, .col = in.col };
                out[on++] = ci;
                continue;
            }
            if (in.uop == UN_NEG && a.type == OK_DECIMAL) {
                sp--;
                FoldVal res = { .known = true, .type = OK_DECIMAL, .d = -a.d };
                stack[sp++] = res;
                IrInst ci = { .kind = I_CONST_DEC, .type = OK_DECIMAL, .d = res.d, .line = in.line, .col = in.col };
                out[on++] = ci;
                continue;
            }
            if (in.uop == UN_NOT && a.type == OK_BOOL) {
                sp--;
                FoldVal res = { .known = true, .type = OK_BOOL, .b = !a.b };
                stack[sp++] = res;
                IrInst ci = { .kind = I_CONST_BOOL, .type = OK_BOOL, .b = res.b, .line = in.line, .col = in.col };
                out[on++] = ci;
                continue;
            }
        }

        /* pass the instruction through and update the abstract stack */
        out[on++] = in;
        switch (in.kind) {
        case I_LOAD_LOCAL: case I_LOAD_GLOBAL:
            v.known = false; v.type = in.type;
            stack[sp++] = v;
            break;
        case I_CONV_NUM_DEC:
            if (sp > 0) {
                FoldVal a = stack[sp - 1];
                if (a.known && a.type == OK_NUMBER) {
                    sp--;
                    stack[sp++] = (FoldVal){ .known = true, .type = OK_DECIMAL, .d = (double)a.i };
                } else stack[sp - 1].type = OK_DECIMAL;
            }
            break;
        case I_BINOP:
            if (sp >= 2) sp -= 2;
            stack[sp++] = (FoldVal){ .known = false,
                .type = (in.op >= OP_EQ && in.op <= OP_GE) || in.op == OP_AND || in.op == OP_OR
                        ? OK_BOOL : in.type };
            break;
        case I_UNOP:
            if (sp >= 1) sp--;
            stack[sp++] = (FoldVal){ .known = false,
                .type = in.uop == UN_NOT ? OK_BOOL : in.type };
            break;
        case I_STORE_LOCAL: case I_STORE_GLOBAL: case I_POP:
        case I_JMPF: case I_WRITE:
            if (sp > 0) sp--;
            break;
        case I_CALL:
            if ((size_t)in.nargs <= sp) sp -= (size_t)in.nargs;
            if (in.type != OK_VOID) stack[sp++] = (FoldVal){ .known = false, .type = in.type };
            break;
        case I_RETURN:
            if (in.type != OK_VOID && sp > 0) sp--;
            break;
        case I_LABEL: case I_JMP: case I_PRINT:
            /* control joins: forget everything known */
            sp = 0;
            break;
        default:
            if (v.known) stack[sp++] = v;
            break;
        }
    }

    free(stack);
    free(f->insts);
    f->insts = out;
    f->n = on;
    f->cap = on;
}

/* ---------------- dump ---------------- */

static const char *ir_kind_name(IrKind k) {
    switch (k) {
    case I_CONST_INT: return "CONST_INT";
    case I_CONST_DEC: return "CONST_DEC";
    case I_CONST_BOOL: return "CONST_BOOL";
    case I_CONST_TEXT: return "CONST_TEXT";
    case I_LOAD_LOCAL: return "LOAD_LOCAL";
    case I_STORE_LOCAL: return "STORE_LOCAL";
    case I_LOAD_GLOBAL: return "LOAD_GLOBAL";
    case I_STORE_GLOBAL: return "STORE_GLOBAL";
    case I_CONV_NUM_DEC: return "CONV_NUM_DEC";
    case I_BINOP: return "BINOP";
    case I_UNOP: return "UNOP";
    case I_LABEL: return "LABEL";
    case I_JMP: return "JMP";
    case I_JMPF: return "JMPF";
    case I_CALL: return "CALL";
    case I_WRITE: return "WRITE";
    case I_PRINT: return "PRINT";
    case I_RETURN: return "RETURN";
    case I_POP: return "POP";
    }
    return "?";
}

void ir_dump(IrModule *im) {
    printf("== IR: %s ==\n", im->mod->name);
    printf("texts: %zu\n", im->ntexts);
    for (size_t i = 0; i < im->ntexts; i++)
        printf("  T%zu = \"%.*s\" (%zu)\n", i, (int)im->texts[i].len, im->texts[i].bytes, im->texts[i].len);
    printf("globals: %zu\n", im->globals.len);
    for (size_t i = 0; i < im->globals.len; i++) {
        Symbol *s = im->globals.items[i];
        printf("  %s %s : %s\n", s->mangled, s->name, ok_type_name(s->type));
    }
    for (size_t i = 0; i < im->funcs.len; i++) {
        IrFunc *f = im->funcs.items[i];
        printf("func %s -> %s (%zu slots, %zu insts)\n",
               f->fi->mangled, ok_type_name(f->fi->ret), f->nslots, f->n);
        for (size_t k = 0; k < f->n; k++) {
            IrInst *in = &f->insts[k];
            printf("  %4zu %-13s", k, ir_kind_name(in->kind));
            switch (in->kind) {
            case I_CONST_INT: printf(" %llu", (unsigned long long)in->i); break;
            case I_CONST_DEC: printf(" %g", in->d); break;
            case I_CONST_BOOL: printf(" %s", in->b ? "true" : "false"); break;
            case I_CONST_TEXT: printf(" T%d", in->text_idx); break;
            case I_LOAD_LOCAL: case I_STORE_LOCAL: printf(" slot=%d", in->slot); break;
            case I_LABEL: case I_JMP: case I_JMPF: printf(" L%d", in->label); break;
            case I_BINOP: printf(" %s [%s]", binop_name(in->op), ok_type_name(in->type)); break;
            case I_UNOP: printf(" %s", in->uop == UN_NEG ? "neg" : "not"); break;
            case I_CALL: printf(" %s nargs=%d", ((FuncInfo *)in->sym)->mangled, in->nargs); break;
            case I_LOAD_GLOBAL: case I_STORE_GLOBAL: printf(" %s", ((Symbol *)in->sym)->mangled); break;
            default: break;
            }
            printf("\n");
        }
    }
}

void ir_module_free(IrModule *im) {
    if (!im) return;
    for (size_t i = 0; i < im->funcs.len; i++) {
        IrFunc *f = im->funcs.items[i];
        free(f->insts);
        free(f->slots);
        free(f);
    }
    vec_free(&im->funcs);
    vec_free(&im->globals);
    for (size_t i = 0; i < im->ntexts; i++) free(im->texts[i].bytes);
    free(im->texts);
    free(im);
}
