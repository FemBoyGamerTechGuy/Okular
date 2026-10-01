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
static void build_structlit(Ctx *c, Node *lit, Symbol *into, size_t base_off, OkType st);
static void build_unionlit(Ctx *c, Node *lit, Symbol *into, size_t base_off, OkType ut);

/* build operand and convert to `want` when a conversion exists (implicit
 * widening, or the literal rule sema already approved — both lower to the
 * same I_CONV; explicit A_CONV nodes come through build_expr) */
static void build_operand_conv(Ctx *c, Node *operand, OkType want) {
    build_expr(c, operand);
    OkType have = operand->rtype;
    if (!have || have == want) return;
    if (!ty_convertible(have, want)) return; /* recovery path; sema reported */
    IrInst inst = { .kind = I_CONV, .type = have, .type2 = want,
                    .line = operand->line, .col = operand->col };
    emit(c->f, inst);
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

/* push the address of sym's storage (+ byte offset) — arrays are addressed */
static void build_addr(Ctx *c, Symbol *sym, size_t offset) {
    IrInst inst = { .line = sym->line, .col = sym->col, .i = offset };
    if (sym->is_global) {
        inst.kind = I_ADDR_GLOBAL;
        inst.sym = sym;
        inst.type = sym->type;
    } else {
        inst.kind = I_ADDR_LOCAL;
        inst.slot = slot_for(c->f, sym);
        inst.type = sym->type;
    }
    emit(c->f, inst);
}

/* initialize an array variable's storage from an A_ARRAYLIT (spec §8.4):
 * element k lands at storage + k * elem-bytes; nested literals recurse */
static void build_arraylit(Ctx *c, Node *lit, Symbol *into, size_t base_off, OkType atype) {
    for (size_t k = 0; k < lit->args.len && k < atype->count; k++) {
        Node *el = lit->args.items[k];
        size_t off = base_off + k * ty_bytes(atype->elem);
        if (el->kind == A_ARRAYLIT) {
            if (ty_kind(atype->elem) == OK_STRUCT) {
                build_structlit(c, el, into, off, atype->elem);
                continue;
            }
            if (ty_kind(atype->elem) == OK_UNION) {
                build_unionlit(c, el, into, off, atype->elem);
                continue;
            }
            build_arraylit(c, el, into, off, atype->elem);
            continue;
        }
        if (ty_kind(atype->elem) == OK_ARRAY || ty_is_record(atype->elem)) {
            /* whole array/struct value: copy its contents into the slot */
            build_addr(c, into, off);
            build_expr(c, el);
            IrInst cp = { .kind = I_COPY, .type = atype->elem, .i = ty_bytes(atype->elem),
                          .line = el->line, .col = el->col };
            emit(c->f, cp);
            continue;
        }
        build_addr(c, into, off);
        build_operand_conv(c, el, atype->elem);
        IrInst st = { .kind = I_STORE_AT, .type = atype->elem,
                      .line = el->line, .col = el->col };
        emit(c->f, st);
    }
}

/* initialize a union variable's storage from an A_ARRAYLIT (spec §8.5):
 * sema checked exactly one value and stashed the CHOSEN member index in
 * lit->offset; every member lives at offset 0, so the store lands at the
 * union's base (the rest of the storage keeps whatever it held — the
 * documented union contract) */
static void build_unionlit(Ctx *c, Node *lit, Symbol *into, size_t base_off, OkType ut) {
    if (lit->args.len != 1) return; /* sema reported the arity error */
    size_t k = lit->offset < ut->nsfields ? lit->offset : 0;
    StructField *f = &ut->sfields[k];
    Node *el = lit->args.items[0];
    if (el->kind == A_ARRAYLIT) {
        if (ty_kind(f->type) == OK_ARRAY) { build_arraylit(c, el, into, base_off, f->type); return; }
        if (ty_kind(f->type) == OK_STRUCT) { build_structlit(c, el, into, base_off, f->type); return; }
        if (ty_kind(f->type) == OK_UNION) { build_unionlit(c, el, into, base_off, f->type); return; }
        return; /* sema reported the mismatch */
    }
    if (ty_kind(f->type) == OK_ARRAY || ty_is_record(f->type)) {
        /* whole aggregate value: copy its contents into the member slot */
        build_addr(c, into, base_off);
        build_expr(c, el);
        IrInst cp = { .kind = I_COPY, .type = f->type, .i = ty_bytes(f->type),
                      .line = el->line, .col = el->col };
        emit(c->f, cp);
        return;
    }
    build_addr(c, into, base_off);
    build_operand_conv(c, el, f->type);
    IrInst st = { .kind = I_STORE_AT, .type = f->type,
                  .line = el->line, .col = el->col };
    emit(c->f, st);
}

/* initialize a struct variable's storage from an A_ARRAYLIT (spec §8.3):
 * field k lands at its declared offset; nested literals recurse */
static void build_structlit(Ctx *c, Node *lit, Symbol *into, size_t base_off, OkType st) {
    if (ty_kind(st) == OK_UNION) { build_unionlit(c, lit, into, base_off, st); return; }
    for (size_t k = 0; k < lit->args.len && k < st->nsfields; k++) {
        Node *el = lit->args.items[k];
        StructField *f = &st->sfields[k];
        size_t off = base_off + f->offset;
        if (el->kind == A_ARRAYLIT) {
            if (ty_kind(f->type) == OK_STRUCT) {
                build_structlit(c, el, into, off, f->type);
                continue;
            }
            if (ty_kind(f->type) == OK_UNION) {
                build_unionlit(c, el, into, off, f->type);
                continue;
            }
            if (ty_kind(f->type) == OK_ARRAY) {
                build_arraylit(c, el, into, off, f->type);
                continue;
            }
            /* sema reported the mismatch */
            continue;
        }
        if (ty_kind(f->type) == OK_ARRAY || ty_is_record(f->type)) {
            build_addr(c, into, off);
            build_expr(c, el);
            IrInst cp = { .kind = I_COPY, .type = f->type, .i = ty_bytes(f->type),
                          .line = el->line, .col = el->col };
            emit(c->f, cp);
            continue;
        }
        build_addr(c, into, off);
        build_operand_conv(c, el, f->type);
        IrInst st2 = { .kind = I_STORE_AT, .type = f->type,
                       .line = el->line, .col = el->col };
        emit(c->f, st2);
    }
}

static void build_expr(Ctx *c, Node *e) {
    switch (e->kind) {
    case A_INT: {
        IrInst inst = { .kind = I_CONST_INT, .type = ty_number, .i = e->ival,
                        .line = e->line, .col = e->col };
        emit(c->f, inst);
        break;
    }
    case A_DEC: {
        IrInst inst = { .kind = I_CONST_DEC, .type = ty_decimal, .d = e->dval,
                        .line = e->line, .col = e->col };
        emit(c->f, inst);
        break;
    }
    case A_BOOL: {
        IrInst inst = { .kind = I_CONST_BOOL, .type = ty_bool, .b = e->bval,
                        .line = e->line, .col = e->col };
        emit(c->f, inst);
        break;
    }
    case A_TEXT: {
        int idx = intern_text(c->im, e->str, e->str_len);
        IrInst inst = { .kind = I_CONST_TEXT, .type = ty_text, .text_idx = idx,
                        .line = e->line, .col = e->col };
        emit(c->f, inst);
        break;
    }
    case A_PATH: {
        Symbol *s = e->sym;
        if (!s) { OK_ICE("A_PATH without a resolved symbol at %zu:%zu", e->line, e->col); }
        if (ty_kind(s->type) == OK_ARRAY) {
            /* arrays evaluate to their storage address (value semantics are
             * preserved by explicit copies; spec §8.4) */
            build_addr(c, s, 0);
            break;
        }
        if (e->a) {
            /* sema rewrote a struct-field path (`var.f1.f2`, possibly
             * through pointers) into an A_MEMBER chain — lower it */
            build_expr(c, e->a);
            break;
        }
        if (ty_is_record(s->type)) {
            /* structs and unions evaluate to their storage address (spec §8.3/§8.5) */
            build_addr(c, s, 0);
            break;
        }
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
    case A_ARRAYLIT: {
        /* literals are folded into their declaration target by build_stmt;
         * reaching here means sema let a literal escape (bug or recovery) */
        OK_ICE("A_ARRAYLIT in expression position at %zu:%zu", e->line, e->col);
        break;
    }
    case A_INDEX: {
        /* base[index]: base evaluates to an address, index to an integer;
         * I_INDEX bounds-checks and scales (spec §9). The index's 64-bit
         * register representation is already the correct unsigned key —
         * negative values are huge unsigned numbers and trap (spec §8.4).
         * Pointer bases scale without bounds checks (spec §12). */
        OkType base_ty = e->a->rtype;
        if (!base_ty || (ty_kind(base_ty) != OK_ARRAY && !ty_is_ptr(base_ty))) {
            OK_ICE("A_INDEX with non-array non-pointer base at %zu:%zu", e->line, e->col);
        }
        build_expr(c, e->a);            /* base address / pointer value */
        if (ty_is_ptr(base_ty)) {
            IrInst chk = { .kind = I_PTRCHK, .type = base_ty->elem,
                          .line = e->line, .col = e->col };
            emit(c->f, chk);
            build_expr(c, e->b);
            IrInst sc = { .kind = I_PTR_SCALE, .type = base_ty,
                         .line = e->line, .col = e->col };
            emit(c->f, sc);
        } else {
            build_expr(c, e->b);        /* index: bits are the compare key */
            IrInst ix = { .kind = I_INDEX, .type = base_ty,
                          .line = e->line, .col = e->col };
            emit(c->f, ix);
        }
        if (ty_kind(base_ty->elem) != OK_ARRAY && !ty_is_record(base_ty->elem)) {
            IrInst ld = { .kind = I_LOAD_AT, .type = base_ty->elem,
                          .line = e->line, .col = e->col };
            emit(c->f, ld);
        }
        /* array/record elements stay as addresses (value semantics) */
        break;
    }
    case A_NULL: {
        IrInst inst = { .kind = I_CONST_INT, .type = ty_null, .i = 0,
                        .line = e->line, .col = e->col };
        emit(c->f, inst);
        break;
    }
    case A_ALLOC: {
        /* alloc<T>(count): count converts to number, bytes = count*size(T) */
        build_operand_conv(c, e->a, ty_number);
        IrInst inst = { .kind = I_ALLOC, .type = e->otype->elem,
                        .line = e->line, .col = e->col };
        emit(c->f, inst);
        break;
    }
    case A_MEMBER: {
        /* base.field — the base is a record value (its address) or, with
         * autoderef, a ptr<record>; offset then load if the member is a
         * scalar (record/array members stay as addresses — value semantics) */
        build_expr(c, e->a);
        if (e->autoderef) {
            IrInst chk = { .kind = I_PTRCHK, .type = e->a->rtype,
                          .line = e->line, .col = e->col };
            emit(c->f, chk);
        }
        IrInst off = { .kind = I_ADDOFF, .i = e->offset,
                       .line = e->line, .col = e->col };
        emit(c->f, off);
        if (ty_kind(e->rtype) != OK_ARRAY && !ty_is_record(e->rtype)) {
            IrInst ld = { .kind = I_LOAD_AT, .type = e->rtype,
                          .line = e->line, .col = e->col };
            emit(c->f, ld);
        }
        break;
    }
    case A_CONV: {
        /* explicit conversion builtin `T.to_U(x)` (spec §4.4) */
        build_expr(c, e->a);
        OkType have = e->a->rtype;
        if (have && have != e->otype && ty_convertible(have, e->otype)) {
            IrInst inst = { .kind = I_CONV, .type = have, .type2 = e->otype,
                            .line = e->line, .col = e->col };
            emit(c->f, inst);
        }
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
        /* operand type after literal adaptation + widening: sema stashed
         * the common type on the node (e->otype); recompute as fallback
         * for recovery paths (spec §4.4). Pointer arithmetic lowers here
         * too: p±n scales by size(T); p-q is the element difference (§12) */
        OkType ot = e->otype;
        if (!ot) ot = ty_common(e->a->rtype, e->b->rtype);
        if (!ot) ot = (e->a->rtype ? e->a->rtype : ty_number); /* recovery */
        if (ty_is_ptr(ot)) {
            bool ap = ty_is_ptr(e->a->rtype), bp = ty_is_ptr(e->b->rtype);
            if (ap && bp && e->op == OP_SUB) {
                build_operand_conv(c, e->a, ot);
                build_operand_conv(c, e->b, ot);
                IrInst pd = { .kind = I_PTR_DIFF, .type = ot,
                              .line = e->line, .col = e->col };
                emit(c->f, pd);
                break;
            }
            if (ap && !bp) {
                /* p ± n: pointer first so the backend sees rax=ptr, rcx=n */
                build_operand_conv(c, e->a, ot);
                build_operand_conv(c, e->b, ty_number);
            } else if (bp && !ap && e->op == OP_ADD) {
                /* n + p commutes: push the pointer first */
                build_operand_conv(c, e->b, ot);
                build_operand_conv(c, e->a, ty_number);
            } else {
                build_operand_conv(c, e->a, ot);
                build_operand_conv(c, e->b, ot);
            }
            IrInst inst = { .kind = I_BINOP, .op = e->op, .type = ot,
                            .line = e->line, .col = e->col };
            emit(c->f, inst);
            break;
        }
        build_operand_conv(c, e->a, ot);
        build_operand_conv(c, e->b, ot);
        IrInst inst = { .kind = I_BINOP, .op = e->op, .type = ot,
                        .line = e->line, .col = e->col };
        emit(c->f, inst);
        break;
    }
    case A_UN: {
        if (e->uop == UN_ADDR) {
            /* &x — address-of (spec §12): variables, array elements,
             * pointer-indexed elements, and dereferences */
            if (e->a->kind == A_PATH && e->a->sym) {
                build_addr(c, e->a->sym, 0);
                break;
            }
            if (e->a->kind == A_INDEX) {
                OkType base_ty = e->a->a->rtype;
                if (ty_is_ptr(base_ty)) {
                    /* &p[i]: null-check, scale, keep the address */
                    build_expr(c, e->a->a);
                    IrInst chk = { .kind = I_PTRCHK, .type = base_ty->elem,
                                  .line = e->line, .col = e->col };
                    emit(c->f, chk);
                    build_expr(c, e->a->b);
                    IrInst sc = { .kind = I_PTR_SCALE, .type = base_ty,
                                 .line = e->line, .col = e->col };
                    emit(c->f, sc);
                } else {
                    /* &xs[i]: bounds-checked element address (no LOAD_AT) */
                    build_expr(c, e->a->a);
                    build_expr(c, e->a->b);
                    IrInst ix = { .kind = I_INDEX, .type = base_ty,
                                  .line = e->line, .col = e->col };
                    emit(c->f, ix);
                }
                break;
            }
            if (e->a->kind == A_UN && e->a->uop == UN_DEREF) {
                build_expr(c, e->a->a); /* &*p is p */
                break;
            }
            OK_ICE("A_UN ADDR with non-addressable operand at %zu:%zu", e->line, e->col);
        }
        if (e->uop == UN_DEREF) {
            /* *p — dereference (spec §12): null-check then load; a pointer
             * to an array yields the array (its address) unchanged */
            OkType pt = e->a->rtype;
            if (!ty_is_ptr(pt))
                OK_ICE("A_UN DEREF of non-pointer at %zu:%zu", e->line, e->col);
            build_expr(c, e->a);
            IrInst chk = { .kind = I_PTRCHK, .type = pt->elem,
                          .line = e->line, .col = e->col };
            emit(c->f, chk);
            if (ty_kind(pt->elem) != OK_ARRAY) {
                IrInst ld = { .kind = I_LOAD_AT, .type = pt->elem,
                              .line = e->line, .col = e->col };
                emit(c->f, ld);
            }
            break;
        }
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
        /* local declaration: literal elements are stored in place; an
         * array/struct-typed initializer copies; scalars store as before */
        Symbol *sym = s->sym;
        if (ty_kind(sym->type) == OK_ARRAY && s->a->kind == A_ARRAYLIT) {
            build_arraylit(c, s->a, sym, 0, sym->type);
            break;
        }
        if (ty_is_record(sym->type) && s->a->kind == A_ARRAYLIT) {
            build_structlit(c, s->a, sym, 0, sym->type);
            break;
        }
        if (ty_kind(sym->type) == OK_ARRAY || ty_is_record(sym->type)) {
            build_addr(c, sym, 0);          /* dst */
            build_expr(c, s->a);            /* src address */
            IrInst cp = { .kind = I_COPY, .type = sym->type, .i = ty_bytes(sym->type),
                          .line = s->line, .col = s->col };
            emit(f, cp);
            break;
        }
        build_operand_conv(c, s->a, sym->type);
        build_store(c, sym);
        break;
    }
    case A_ASSIGN: {
        Symbol *sym = s->sym;
        if (ty_kind(sym->type) == OK_ARRAY || ty_is_record(sym->type)) {
            build_addr(c, sym, 0);          /* dst */
            build_expr(c, s->a);            /* src address */
            IrInst cp = { .kind = I_COPY, .type = sym->type, .i = ty_bytes(sym->type),
                          .line = s->line, .col = s->col };
            emit(f, cp);
            break;
        }
        build_operand_conv(c, s->a, sym->type);
        build_store(c, sym);
        break;
    }
    case A_INDEXASSIGN: {
        /* base[index] = value (m[i][j] nests: s->a is the inner index);
         * base may be an array (checked) or a pointer (unchecked, §12) */
        OkType base_ty = s->a->rtype;
        if (!base_ty || (ty_kind(base_ty) != OK_ARRAY && !ty_is_ptr(base_ty))) {
            OK_ICE("A_INDEXASSIGN with non-array non-pointer base at %zu:%zu", s->line, s->col);
        }
        OkType elem = base_ty->elem;
        build_expr(c, s->a);                 /* base address / pointer value */
        if (ty_is_ptr(base_ty)) {
            IrInst chk = { .kind = I_PTRCHK, .type = elem,
                          .line = s->line, .col = s->col };
            emit(f, chk);
            build_expr(c, s->b);
            IrInst sc = { .kind = I_PTR_SCALE, .type = base_ty,
                         .line = s->line, .col = s->col };
            emit(f, sc);
        } else {
            build_expr(c, s->b);
            IrInst ix = { .kind = I_INDEX, .type = base_ty,
                          .line = s->line, .col = s->col };
            emit(f, ix);
        }
        if (ty_kind(elem) == OK_ARRAY) {
            /* element is itself an array: value is its address, copy it */
            build_expr(c, s->c);
            IrInst cp = { .kind = I_COPY, .type = elem, .i = ty_bytes(elem),
                          .line = s->line, .col = s->col };
            emit(f, cp);
        } else {
            build_operand_conv(c, s->c, elem);
            IrInst st = { .kind = I_STORE_AT, .type = elem,
                          .line = s->line, .col = s->col };
            emit(f, st);
        }
        break;
    }
    case A_DEREFASSIGN: {
        /* *p = value (spec §12): null-check, then store (or copy an array) */
        OkType pt = s->a->rtype;
        if (!ty_is_ptr(pt))
            OK_ICE("A_DEREFASSIGN with non-pointer at %zu:%zu", s->line, s->col);
        OkType elem = pt->elem;
        build_expr(c, s->a);                 /* pointer value */
        IrInst chk = { .kind = I_PTRCHK, .type = elem,
                      .line = s->line, .col = s->col };
        emit(f, chk);
        if (ty_kind(elem) == OK_ARRAY) {
            /* *p = arr: dst address already on the stack; copy src into it */
            build_expr(c, s->c);
            IrInst cp = { .kind = I_COPY, .type = elem, .i = ty_bytes(elem),
                          .line = s->line, .col = s->col };
            emit(f, cp);
        } else {
            build_operand_conv(c, s->c, elem);
            IrInst st = { .kind = I_STORE_AT, .type = elem,
                          .line = s->line, .col = s->col };
            emit(f, st);
        }
        break;
    }
    case A_FIELDASSIGN: {
        /* base.field = value (spec §8.3): address (+ deref), offset, store */
        build_expr(c, s->a);
        if (s->autoderef) {
            IrInst chk = { .kind = I_PTRCHK, .type = s->a->rtype,
                          .line = s->line, .col = s->col };
            emit(f, chk);
        }
        IrInst off = { .kind = I_ADDOFF, .i = s->offset,
                       .line = s->line, .col = s->col };
        emit(f, off);
        /* field type rides on the checked member: rebuild it from the
         * (checked) value's expected type stored at lowering time — sema
         * stored the field type in s->otype for IR */
        OkType ft = s->otype;
        if (ty_kind(ft) == OK_ARRAY || ty_is_record(ft)) {
            build_expr(c, s->c);
            IrInst cp = { .kind = I_COPY, .type = ft, .i = ty_bytes(ft),
                          .line = s->line, .col = s->col };
            emit(f, cp);
        } else {
            build_operand_conv(c, s->c, ft);
            IrInst st = { .kind = I_STORE_AT, .type = ft,
                          .line = s->line, .col = s->col };
            emit(f, st);
        }
        break;
    }
    case A_RELEASE: {
        /* release(p): null is a no-op inside rt_release (spec §12) */
        build_expr(c, s->a);
        IrInst rel = { .kind = I_RELEASE, .type = s->a->rtype,
                       .line = s->line, .col = s->col };
        emit(f, rel);
        break;
    }
    case A_EXPRSTMT: {
        Node *e = s->a;
        if (e->kind == A_WRITE) {
            Node *arg = e->args.len ? (Node *)e->args.items[0] : NULL;
            if (arg) build_expr(c, arg);
            IrInst w = { .kind = I_WRITE, .type = arg ? arg->rtype : ty_void,
                         .line = s->line, .col = s->col };
            emit(f, w);
        } else {
            build_expr(c, e);
            if (e->kind == A_CALL && ((FuncInfo *)e->finfo)->ret != ty_void) {
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
        IrInst w = { .kind = I_WRITE, .type = arg ? arg->rtype : ty_void,
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
        bs->type = ty_number;

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
        IrInst l1 = { .kind = I_LOAD_LOCAL, .slot = slot_for(f, ivar), .type = ty_number };
        emit(f, l1);
        IrInst l2 = { .kind = I_LOAD_LOCAL, .slot = slot_for(f, bs), .type = ty_number };
        emit(f, l2);
        IrInst cmp = { .kind = I_BINOP, .op = s->inclusive ? OP_LE : OP_LT,
                       .type = ty_number, .line = s->line, .col = s->col };
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
        IrInst li = { .kind = I_LOAD_LOCAL, .slot = slot_for(f, ivar), .type = ty_number };
        emit(f, li);
        IrInst one = { .kind = I_CONST_INT, .type = ty_number, .i = 1 };
        emit(f, one);
        IrInst inc = { .kind = I_BINOP, .op = OP_ADD, .type = ty_number };
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
            IrInst z = { .kind = I_CONST_INT, .type = ty_number, .i = 0 };
            emit(f, z);
        }
        IrInst r = { .kind = I_RETURN, .type = s->a ? s->a->rtype : ty_void,
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
            case A_VARDECL: case A_DEVCOL: case A_STRUCTDECL: case A_UNIONDECL:
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
        case I_CONST_INT:  v.known = true; v.type = ty_number; v.i = in.i; break;
        case I_CONST_DEC:  v.known = true; v.type = ty_decimal; v.d = in.d; break;
        case I_CONST_BOOL: v.known = true; v.type = ty_bool; v.b = in.b; break;
        case I_CONST_TEXT: v.known = true; v.type = ty_text; v.text = in.text_idx; break;
        default: break;
        }

        if (in.kind == I_CONV && sp >= 1 && stack[sp - 1].known) {
            FoldVal a = stack[sp - 1];
            OkType src = in.type, dst = in.type2;
            if (a.type == src && ty_convertible(src, dst)) {
                FoldVal res = { .known = true };
                if (src == dst) {
                    res = a;
                } else if (src == ty_decimal && ty_is_integer(dst)) {
                    res.type = dst; res.i = ty_dec_to_int(a.d, dst);
                } else if (src == ty_decimal && dst == ty_decimal) {
                    res = a;
                } else if (ty_is_integer(src) && dst == ty_decimal) {
                    res.type = ty_decimal; res.d = ty_int_to_dec(a.i, src);
                } else if (ty_is_integer(src) && ty_is_integer(dst)) {
                    res.type = dst; res.i = ty_reencode(a.i, dst);
                } else if (src == ty_bool && ty_is_integer(dst)) {
                    res.type = dst; res.i = a.b ? 1 : 0;
                } else if (src == ty_bool && dst == ty_decimal) {
                    res.type = ty_decimal; res.d = a.b ? 1.0 : 0.0;
                } else {
                    res.known = false;
                }
                if (res.known) {
                    sp--;
                    stack[sp++] = res;
                    /* the source constant was already emitted in a previous
                     * iteration; drop it so the folded value replaces it
                     * exactly (the abstract stack guarantees the producing
                     * instruction is the immediately previous one) */
                    if (on > 0) on--;
                    IrInst ci;
                    memset(&ci, 0, sizeof ci);
                    ci.line = in.line; ci.col = in.col;
                    if (res.type == ty_decimal) { ci.kind = I_CONST_DEC; ci.d = res.d; ci.type = ty_decimal; }
                    else { ci.kind = I_CONST_INT; ci.i = res.i; ci.type = res.type; }
                    out[on++] = ci;
                    continue;
                }
            }
        }

        if (in.kind == I_BINOP && sp >= 2 && stack[sp - 1].known && stack[sp - 2].known) {
            FoldVal r = stack[sp - 1], l = stack[sp - 2];
            FoldVal res = { .known = true };
            bool ok = true;
            bool is_cmp = (in.op >= OP_EQ && in.op <= OP_GE);
            if (in.type == ty_decimal && l.type == ty_decimal && r.type == ty_decimal) {
                res.type = ty_decimal;
                switch (in.op) {
                case OP_ADD: res.d = l.d + r.d; break;
                case OP_SUB: res.d = l.d - r.d; break;
                case OP_MUL: res.d = l.d * r.d; break;
                case OP_DIV: res.d = l.d / r.d; break;
                default: ok = false; break;
                }
            } else if (ty_is_integer(in.type) && l.type == in.type && r.type == in.type) {
                /* integer arithmetic with the operands already converted to
                 * the common type: fold with the type's signedness, then
                 * re-encode to the type's width (wrap semantics, spec §4.2) */
                res.type = is_cmp ? ty_bool : in.type;
                uint64_t a = l.i, b = r.i;
                if (in.type->is_signed) {
                    int64_t sa = (int64_t)a, sb = (int64_t)b;
                    switch (in.op) {
                    case OP_ADD: res.i = a + b; break;
                    case OP_SUB: res.i = a - b; break;
                    case OP_MUL: res.i = a * b; break;
                    case OP_DIV:
                        if (b == 0) { ok = false; break; }        /* runtime trap */
                        if (sa == INT64_MIN && sb == -1) res.i = (uint64_t)INT64_MIN;
                        else res.i = (uint64_t)(sa / sb);
                        break;
                    case OP_MOD:
                        if (b == 0) { ok = false; break; }
                        if (sa == INT64_MIN && sb == -1) res.i = 0;
                        else res.i = (uint64_t)(sa % sb);
                        break;
                    default:
                        switch (in.op) {
                        case OP_EQ: res.b = sa == sb; break;
                        case OP_NEQ: res.b = sa != sb; break;
                        case OP_LT: res.b = sa < sb; break;
                        case OP_LE: res.b = sa <= sb; break;
                        case OP_GT: res.b = sa > sb; break;
                        case OP_GE: res.b = sa >= sb; break;
                        default: ok = false;
                        }
                        break;
                    }
                } else {
                    switch (in.op) {
                    case OP_ADD: res.i = a + b; break;
                    case OP_SUB: res.i = a - b; break;
                    case OP_MUL: res.i = a * b; break;
                    case OP_DIV: if (b == 0) { ok = false; break; } res.i = a / b; break;
                    case OP_MOD: if (b == 0) { ok = false; break; } res.i = a % b; break;
                    default:
                        switch (in.op) {
                        case OP_EQ: res.b = a == b; break;
                        case OP_NEQ: res.b = a != b; break;
                        case OP_LT: res.b = a < b; break;   /* unsigned (spec §4.2) */
                        case OP_LE: res.b = a <= b; break;
                        case OP_GT: res.b = a > b; break;
                        case OP_GE: res.b = a >= b; break;
                        default: ok = false;
                        }
                        break;
                    }
                }
                if (ok && !is_cmp && in.type->bits < 64)
                    res.i = ty_reencode(res.i, in.type);
            } else if (in.type == ty_bool && l.type == ty_bool && r.type == ty_bool) {
                res.type = ty_bool;
                if (in.op == OP_AND) res.b = l.b && r.b;
                else if (in.op == OP_OR) res.b = l.b || r.b;
                else if (in.op == OP_EQ) res.b = l.b == r.b;
                else if (in.op == OP_NEQ) res.b = l.b != r.b;
                else ok = false;
            } else if (l.type == ty_text && r.type == ty_text && in.op == OP_EQ) {
                res.type = ty_bool;
                res.b = l.text == r.text;
            } else if (l.type == ty_text && r.type == ty_text && in.op == OP_NEQ) {
                res.type = ty_bool;
                res.b = l.text != r.text;
            } else ok = false;

            if (ok) {
                sp -= 2;
                stack[sp++] = res;
                /* drop the two source constants from the output: folding
                 * must replace them, not stack the result on top (leaving
                 * them inserts junk BETWEEN operands of enclosing
                 * expressions — the M2 `x / -1` bug, fixed in M3) */
                if (on >= 2) on -= 2;
                IrInst ci;
                memset(&ci, 0, sizeof ci);
                ci.line = in.line; ci.col = in.col;
                if (res.type == ty_decimal) { ci.kind = I_CONST_DEC; ci.d = res.d; ci.type = ty_decimal; }
                else if (res.type == ty_bool) { ci.kind = I_CONST_BOOL; ci.b = res.b; ci.type = ty_bool; }
                else if (res.type == ty_text) { ci.kind = I_CONST_TEXT; ci.text_idx = res.text; ci.type = ty_text; }
                else { ci.kind = I_CONST_INT; ci.i = res.i; ci.type = res.type; }
                out[on++] = ci;
                continue;
            }
        }

        if (in.kind == I_UNOP && sp >= 1 && stack[sp - 1].known) {
            FoldVal a = stack[sp - 1];
            if (in.uop == UN_NEG && a.type == ty_decimal) {
                sp--;
                FoldVal res = { .known = true, .type = ty_decimal, .d = -a.d };
                stack[sp++] = res;
                if (on > 0) on--; /* replace the source constant exactly */
                IrInst ci = { .kind = I_CONST_DEC, .type = ty_decimal, .d = res.d, .line = in.line, .col = in.col };
                out[on++] = ci;
                continue;
            }
            if (in.uop == UN_NEG && ty_is_integer(a.type)) {
                /* wrap semantics: -v re-encoded to the operand's width */
                sp--;
                uint64_t neg = (uint64_t)(-(int64_t)a.i);
                FoldVal res = { .known = true, .type = a.type, .i = ty_reencode(neg, a.type) };
                stack[sp++] = res;
                if (on > 0) on--; /* replace the source constant exactly */
                IrInst ci = { .kind = I_CONST_INT, .type = a.type, .i = res.i, .line = in.line, .col = in.col };
                out[on++] = ci;
                continue;
            }
            if (in.uop == UN_NOT && a.type == ty_bool) {
                sp--;
                FoldVal res = { .known = true, .type = ty_bool, .b = !a.b };
                stack[sp++] = res;
                if (on > 0) on--; /* replace the source constant exactly */
                IrInst ci = { .kind = I_CONST_BOOL, .type = ty_bool, .b = res.b, .line = in.line, .col = in.col };
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
        case I_CONV:
            if (sp > 0) {
                FoldVal a = stack[sp - 1];
                if (a.known) {
                    /* folded above (or unknown source): typed conservatively */
                    if (a.type != in.type2) stack[sp - 1].known = false;
                }
                stack[sp - 1].type = in.type2;
            }
            break;
        case I_BINOP:
            if (sp >= 2) sp -= 2;
            stack[sp++] = (FoldVal){ .known = false,
                .type = (in.op >= OP_EQ && in.op <= OP_GE) || in.op == OP_AND || in.op == OP_OR
                        ? ty_bool : in.type };
            break;
        case I_UNOP:
            if (sp >= 1) sp--;
            stack[sp++] = (FoldVal){ .known = false,
                .type = in.uop == UN_NOT ? ty_bool : in.type };
            break;
        case I_STORE_LOCAL: case I_STORE_GLOBAL: case I_POP:
        case I_JMPF: case I_WRITE:
            if (sp > 0) sp--;
            break;
        case I_ADDR_LOCAL: case I_ADDR_GLOBAL:
            stack[sp++] = (FoldVal){ .known = false, .type = in.type };
            break;
        case I_INDEX:
            if (sp >= 2) sp -= 2;
            stack[sp++] = (FoldVal){ .known = false,
                .type = in.type ? in.type->elem : NULL };
            break;
        case I_LOAD_AT:
            if (sp > 0) sp--;
            stack[sp++] = (FoldVal){ .known = false, .type = in.type };
            break;
        case I_STORE_AT: case I_COPY:
            if (sp >= 2) sp -= 2;
            break;
        case I_ALLOC:
            if (sp > 0) sp--;   /* count */
            stack[sp++] = (FoldVal){ .known = false, .type = in.type };
            break;
        case I_RELEASE:
            if (sp > 0) sp--;
            break;
        case I_PTRCHK:
            if (sp > 0) stack[sp - 1].known = false; /* trap edge */
            break;
        case I_PTR_SCALE:
            if (sp >= 2) sp -= 2;
            stack[sp++] = (FoldVal){ .known = false, .type = in.type };
            break;
        case I_PTR_DIFF:
            if (sp >= 2) sp -= 2;
            stack[sp++] = (FoldVal){ .known = false, .type = ty_number };
            break;
        case I_ADDOFF:
            if (sp > 0) stack[sp - 1].known = false;
            break;
        case I_CALL:
            if ((size_t)in.nargs <= sp) sp -= (size_t)in.nargs;
            if (in.type != ty_void) stack[sp++] = (FoldVal){ .known = false, .type = in.type };
            break;
        case I_RETURN:
            if (in.type != ty_void && sp > 0) sp--;
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
    case I_CONV: return "CONV";
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
    case I_ADDR_LOCAL: return "ADDR_LOCAL";
    case I_ADDR_GLOBAL: return "ADDR_GLOBAL";
    case I_INDEX: return "INDEX";
    case I_LOAD_AT: return "LOAD_AT";
    case I_STORE_AT: return "STORE_AT";
    case I_COPY: return "COPY";
    case I_ALLOC: return "ALLOC";
    case I_RELEASE: return "RELEASE";
    case I_PTRCHK: return "PTRCHK";
    case I_PTR_SCALE: return "PTR_SCALE";
    case I_PTR_DIFF: return "PTR_DIFF";
    case I_ADDOFF: return "ADDOFF";
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
            case I_CONV: printf(" [%s -> %s]", ok_type_name(in->type), ok_type_name(in->type2)); break;
            case I_CALL: printf(" %s nargs=%d", ((FuncInfo *)in->sym)->mangled, in->nargs); break;
            case I_LOAD_GLOBAL: case I_STORE_GLOBAL: printf(" %s", ((Symbol *)in->sym)->mangled); break;
            case I_ADDR_GLOBAL: printf(" %s+%llu", ((Symbol *)in->sym)->mangled,
                                       (unsigned long long)in->i); break;
            case I_ADDR_LOCAL: printf(" slot=%d+%llu", in->slot, (unsigned long long)in->i); break;
            case I_INDEX: case I_LOAD_AT: case I_STORE_AT:
                printf(" [%s]", ok_type_name(in->type)); break;
            case I_COPY: printf(" %llu bytes", (unsigned long long)in->i); break;
            case I_ALLOC: printf(" [%s]", ok_type_name(in->type)); break;
            case I_RELEASE: printf(" [%s]", ok_type_name(in->type)); break;
            case I_PTRCHK: printf(" [%s]", ok_type_name(in->type)); break;
            case I_PTR_SCALE: case I_PTR_DIFF:
                printf(" [%s]", ok_type_name(in->type)); break;
            case I_ADDOFF: printf(" +%llu", (unsigned long long)in->i); break;
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
