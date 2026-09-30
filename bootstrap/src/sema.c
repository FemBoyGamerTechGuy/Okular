/* sema.c — semantic analysis for Okular 0.1.
 *
 * Scope model (spec §6.2):
 *   root scope  = main.ok's top level + one namespace symbol per src module
 *   module scope = a src file's top level (parent = root)
 *   column scope = a developer column's namespace (parent = its file scope)
 *   block scopes = function bodies / when / loop bodies
 *
 * Annotations written for IR:
 *   A_PATH/A_ASSIGN/A_VARDECL -> node->sym
 *   A_CALL                    -> node->finfo, node->rtype
 *   all expressions           -> node->rtype
 *   global A_VARDECL          -> sym->cval (constant initializer)
 */
#include "ok/sema.h"

typedef struct SemaCtx {
    DiagEngine *de;
    OkProject *proj;
    const OkOptions *opt;
    Scope *root;
    OkModule *cur_mod;
    Scope *cur_scope;
    FuncInfo *cur_func;      /* NULL inside main top level until entry made */
    bool in_loop;
} SemaCtx;

/* ---------------- helpers ---------------- */

static Diag *serr(SemaCtx *c, Node *n, const char *fmt, ...)
    __attribute__((format(printf, 3, 4)));
static Diag *serr(SemaCtx *c, Node *n, const char *fmt, ...) {
    va_list ap; va_start(ap, fmt);
    char buf[512]; vsnprintf(buf, sizeof buf, fmt, ap); va_end(ap);
    return diag_emit(c->de, DIAG_ERROR, c->cur_mod->src, n ? n->line : 0, n ? n->col : 0, "%s", buf);
}
static Diag *swarn(SemaCtx *c, Node *n, const char *fmt, ...)
    __attribute__((format(printf, 3, 4)));
static Diag *swarn(SemaCtx *c, Node *n, const char *fmt, ...) {
    va_list ap; va_start(ap, fmt);
    char buf[512]; vsnprintf(buf, sizeof buf, fmt, ap); va_end(ap);
    return diag_emit(c->de, DIAG_WARNING, c->cur_mod->src, n ? n->line : 0, n ? n->col : 0, "%s", buf);
}

/* name suggestion: closest scope name with edit distance <= 2 (brief §42) */
static int edit_distance(const char *a, const char *b) {
    size_t la = strlen(a), lb = strlen(b);
    if (la == 0) return (int)lb;
    if (lb == 0) return (int)la;
    int prev[64], cur[64];
    if (lb >= 64) return 99;
    for (size_t j = 0; j <= lb; j++) prev[j] = (int)j;
    for (size_t i = 1; i <= la; i++) {
        cur[0] = (int)i;
        for (size_t j = 1; j <= lb; j++) {
            int cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
            int m = prev[j - 1] + cost;
            if (cur[j - 1] + 1 < m) m = cur[j - 1] + 1;
            if (prev[j] + 1 < m) m = prev[j] + 1;
            cur[j] = m;
        }
        memcpy(prev, cur, sizeof prev);
    }
    return prev[lb];
}

const char *ok_suggest_name(Scope *s, const char *name) {
    for (Scope *sc = s; sc; sc = sc->parent)
        for (size_t i = 0; i < sc->n; i++)
            if (edit_distance(name, sc->syms[i]->name) <= 2)
                return sc->syms[i]->name;
    return NULL;
}

/* assignment compatibility (spec §4.4). Types are interned, so pointer
 * equality IS type equality — arrays must match exactly (same element type,
 * same count); integers widen safely per the 0.3 lattice (ty_assignable). */
static bool const_eval(SemaCtx *c, Node *e, ConstVal *out); /* fwd */

static bool assignable(OkType from, OkType to) {
    return ty_assignable(from, to);
}

/* Full assignment decision for a value expression: implicit conversion,
 * or the integer-literal rule — a literal (or foldable constant) may
 * initialize a narrower fixed-width type when its value fits (spec §4.2).
 * This is what makes `type.int8 x = 5` and `type.int8 y = -100` legal
 * while `type.int8 z = 200` and `type.uint8 u = -1` stay errors. */
static bool assignable_value(SemaCtx *c, Node *val, OkType from, OkType to) {
    if (assignable(from, to)) return true;
    if (!ty_is_integer(to) || !from) return false;
    /* direct non-negative literal */
    if (val->kind == A_INT && from == ty_number)
        return ty_uint_fits(val->ival, to);
    /* negated literal */
    if (val->kind == A_UN && val->uop == UN_NEG &&
        val->a->kind == A_INT && from == ty_number) {
        uint64_t raw = (uint64_t)(-(int64_t)val->a->ival);
        return ty_sint_fits((int64_t)raw, to);
    }
    /* foldable constant expression: signed interpretation */
    if (from == ty_number) {
        size_t mark = c->de->errors;
        ConstVal cv;
        if (const_eval(c, val, &cv) && c->de->errors == mark && cv.valid)
            return ty_sint_fits((int64_t)cv.i, to);
    }
    return false;
}

static const char *path_join_str(char **parts, size_t n) {
    static char buf[256];
    size_t off = 0;
    for (size_t i = 0; i < n && off < sizeof buf - 1; i++)
        off += snprintf(buf + off, sizeof buf - off, "%s%s", i ? "." : "", parts[i]);
    return buf;
}

/* mangled asm name: ok_<module>[_<col>...]_<name> */
static char *mangle(const char *mod, const char *colpath, const char *name) {
    size_t n = strlen(mod) + (colpath ? strlen(colpath) : 0) + strlen(name) + 16;
    char *out = ok_xmalloc(n);
    if (colpath && *colpath)
        snprintf(out, n, "ok_%s_%s_%s", mod, colpath, name);
    else
        snprintf(out, n, "ok_%s_%s", mod, name);
    for (char *s = out; *s; s++)
        if (*s == '.') *s = '_';
    return out;
}

/* ---------------- phase 1: collect ---------------- */

static void collect_devcol(SemaCtx *c, OkModule *m, Node *col, Scope *parent,
                            char *colpath_in);

static void collect_toplevel(SemaCtx *c, OkModule *m, Node *file, Scope *scope) {
    c->cur_mod = m;
    for (size_t i = 0; i < file->body.len; i++) {
        Node *n = file->body.items[i];
        switch (n->kind) {
        case A_DIRECTIVE: {
            if (n->feature < 0) break; /* unknown feature: parser errored */
            m->features[n->feature] = (n->fvalue != 0);
            break;
        }
        case A_LANGCOL: {
            const char *p = path_join_str(n->parts, n->nparts);
            if (strcmp(p, "source.files.use") != 0 && strcmp(p, "libs.use") != 0) {
                Diag *d = serr(c, n, "unknown language column `[%s]`.", p);
                diag_note(d, "the language columns in 0.1 are: [libs.use], [source.files.use].");
                diag_note(d, "developer columns are plain names: `physics = { ... }.end`.");
            }
            break;
        }
        case A_DEVCOL:
            collect_devcol(c, m, n, scope, NULL);
            break;
        case A_FUNC: {
            Symbol *ex = scope_insert(scope, n->name, SYM_FUNC, n->line, n->col);
            if (ex->kind != SYM_FUNC || (ex->decl && ex->decl != n)) {
                serr(c, n, "duplicate definition of `%s` in this scope.", n->name);
                Diag *d = serr(c, ex->decl ? ex->decl : n, "`%s` was first defined here.", n->name);
                (void)d;
                break;
            }
            if (n->nparams > 6) {
                Diag *d = serr(c, n, "functions with more than 6 parameters are not implemented in Okular 0.2.");
                diag_note(d, "the 0.2 internal ABI passes up to 6 arguments in registers (docs/architecture.md §3.5); the limit lifts with the stack-args milestone.");
            }
            if (ty_kind(n->otype) == OK_ARRAY) {
                Diag *d = serr(c, n, "functions cannot return arrays in Okular 0.2.");
                diag_note(d, "return an element, or pass a destination array when pointers arrive (spec §12).");
            }
            char *mg = mangle(m->name, NULL, n->name);
            FuncInfo *fi = funcinfo_new(n->name, mg, n->otype, n, m);
            fi->nparams = n->nparams;
            fi->param_types = ok_xmalloc((n->nparams ? n->nparams : 1) * sizeof(OkType));
            fi->param_names = ok_xmalloc((n->nparams ? n->nparams : 1) * sizeof(char *));
            for (size_t k = 0; k < n->nparams; k++) {
                fi->param_types[k] = n->params[k].type;
                fi->param_names[k] = ok_xstrdup(n->params[k].name);
            }
            ex->func = fi;
            n->finfo = fi;
            break;
        }
        case A_VARDECL: {
            Symbol *ex = scope_insert(scope, n->name, SYM_VAR, n->line, n->col);
            if (ex->kind != SYM_VAR || (ex->decl && ex->decl != n)) {
                serr(c, n, "duplicate definition of `%s` in this scope.", n->name);
                break;
            }
            ex->type = n->otype;
            ex->decl = n;
            ex->is_global = true;
            ex->mangled = mangle(m->name, NULL, n->name);
            n->sym = ex;
            break;
        }
        default:
            /* statements: checked (and restricted to main.ok) in phase 2 */
            break;
        }
    }
}

static void collect_devcol(SemaCtx *c, OkModule *m, Node *col, Scope *parent,
                            char *colpath_in) {
    /* namespace scope */
    Scope *ns = scope_new("column", parent);

    /* colpath for mangling */
    char colpath[256];
    if (colpath_in) snprintf(colpath, sizeof colpath, "%s.%s", colpath_in, col->name);
    else            snprintf(colpath, sizeof colpath, "%s", col->name);

    /* insert the namespace symbol into the PARENT scope */
    Symbol *ex = scope_insert(parent, col->name, SYM_NS, col->line, col->col);
    if (ex->kind != SYM_NS || (ex->decl && ex->decl != col)) {
        serr(c, col, "duplicate definition of `%s` in this scope.", col->name);
        return;
    }
    ex->ns = ns;
    ex->decl = col;

    for (size_t i = 0; i < col->body.len; i++) {
        Node *n = col->body.items[i];
        switch (n->kind) {
        case A_FUNC: {
            Symbol *fs = scope_insert(ns, n->name, SYM_FUNC, n->line, n->col);
            if (fs->kind != SYM_FUNC || (fs->decl && fs->decl != n)) {
                serr(c, n, "duplicate definition of `%s` in column `%s`.", n->name, col->name);
                break;
            }
            if (n->nparams > 6) {
                Diag *d = serr(c, n, "functions with more than 6 parameters are not implemented in Okular 0.2.");
                diag_note(d, "the 0.2 internal ABI passes up to 6 arguments in registers (docs/architecture.md §3.5).");
            }
            if (ty_kind(n->otype) == OK_ARRAY) {
                Diag *d = serr(c, n, "functions cannot return arrays in Okular 0.2.");
                diag_note(d, "return an element, or pass a destination array when pointers arrive (spec §12).");
            }
            char *mg = mangle(m->name, colpath, n->name);
            FuncInfo *fi = funcinfo_new(n->name, mg, n->otype, n, m);
            fi->nparams = n->nparams;
            fi->param_types = ok_xmalloc((n->nparams ? n->nparams : 1) * sizeof(OkType));
            fi->param_names = ok_xmalloc((n->nparams ? n->nparams : 1) * sizeof(char *));
            for (size_t k = 0; k < n->nparams; k++) {
                fi->param_types[k] = n->params[k].type;
                fi->param_names[k] = ok_xstrdup(n->params[k].name);
            }
            fs->func = fi;
            n->finfo = fi;
            break;
        }
        case A_VARDECL: {
            Symbol *vs = scope_insert(ns, n->name, SYM_VAR, n->line, n->col);
            if (vs->kind != SYM_VAR || (vs->decl && vs->decl != n)) {
                serr(c, n, "duplicate definition of `%s` in column `%s`.", n->name, col->name);
                break;
            }
            vs->type = n->otype;
            vs->decl = n;
            vs->is_global = true;
            vs->mangled = mangle(m->name, colpath, n->name);
            n->sym = vs;
            break;
        }
        case A_DEVCOL:
            collect_devcol(c, m, n, ns, colpath);
            break;
        default:
            break; /* parser rejects other members */
        }
    }
}

/* ---------------- constant evaluation (globals + -xw) ---------------- */

static bool const_eval(SemaCtx *c, Node *e, ConstVal *out) {
    memset(out, 0, sizeof *out);
    switch (e->kind) {
    case A_INT:  out->valid = true; out->type = ty_number; out->i = e->ival; return true;
    case A_DEC:  out->valid = true; out->type = ty_decimal; out->d = e->dval; return true;
    case A_BOOL: out->valid = true; out->type = ty_bool; out->b = e->bval; return true;
    case A_TEXT: out->valid = true; out->type = ty_text;
        out->t = ok_xstrndup(e->str, e->str_len); out->t_len = e->str_len; return true;
    case A_UN: {
        ConstVal v;
        if (!const_eval(c, e->a, &v)) return false;
        if (e->uop == UN_NEG) {
            if (v.type == ty_number) { out->valid = true; out->type = ty_number; out->i = (uint64_t)(-(int64_t)v.i); return true; }
            if (v.type == ty_decimal) { out->valid = true; out->type = ty_decimal; out->d = -v.d; return true; }
            if (v.type && ty_is_integer(v.type)) {
                out->valid = true; out->type = v.type;
                out->i = ty_reencode((uint64_t)(-(int64_t)v.i), v.type);
                return true;
            }
            return false;
        }
        if (v.type == ty_bool) { out->valid = true; out->type = ty_bool; out->b = !v.b; return true; }
        return false;
    }
    case A_CONV: {
        /* conversion of a constant folds at compile time (spec §4.4) */
        ConstVal v;
        if (!const_eval(c, e->a, &v)) return false;
        if (!v.valid) return false;
        OkType dst = e->otype;
        if (v.type == dst) { *out = v; return true; }
        if (!ty_convertible(v.type, dst)) return false;
        if (v.type == ty_decimal && ty_is_integer(dst)) {
            out->valid = true; out->type = dst; out->i = ty_dec_to_int(v.d, dst);
            return true;
        }
        if (ty_is_integer(v.type) && dst == ty_decimal) {
            out->valid = true; out->type = ty_decimal;
            out->d = ty_int_to_dec(v.i, v.type);
            return true;
        }
        if (ty_is_integer(v.type) && ty_is_integer(dst)) {
            out->valid = true; out->type = dst;
            out->i = ty_reencode(v.i, dst);
            return true;
        }
        if (v.type == ty_bool && (ty_is_integer(dst) || dst == ty_decimal)) {
            out->valid = true;
            if (dst == ty_decimal) { out->type = ty_decimal; out->d = v.b ? 1.0 : 0.0; }
            else { out->type = dst; out->i = v.b ? 1 : 0; }
            return true;
        }
        return false;
    }
    case A_BIN: {
        ConstVal l, r;
        if (!const_eval(c, e->a, &l) || !const_eval(c, e->b, &r)) return false;
        if (l.type != r.type) return false;
        switch (e->op) {
        case OP_ADD:
            if (l.type == ty_number) { out->valid = true; out->type = ty_number; out->i = l.i + r.i; return true; }
            if (l.type == ty_decimal) { out->valid = true; out->type = ty_decimal; out->d = l.d + r.d; return true; }
            if (l.type == ty_text) { /* literal concatenation folds (spec §9) */
                out->valid = true; out->type = ty_text;
                out->t = ok_xmalloc(l.t_len + r.t_len);
                memcpy(out->t, l.t, l.t_len);
                memcpy(out->t + l.t_len, r.t, r.t_len);
                out->t_len = l.t_len + r.t_len;
                free(l.t); free(r.t);
                return true;
            }
            return false;
        case OP_SUB:
            if (l.type == ty_number) { out->valid = true; out->type = ty_number; out->i = l.i - r.i; return true; }
            if (l.type == ty_decimal) { out->valid = true; out->type = ty_decimal; out->d = l.d - r.d; return true; }
            return false;
        case OP_MUL:
            if (l.type == ty_number) { out->valid = true; out->type = ty_number; out->i = l.i * r.i; return true; }
            if (l.type == ty_decimal) { out->valid = true; out->type = ty_decimal; out->d = l.d * r.d; return true; }
            return false;
        case OP_DIV:
            if (l.type == ty_number) {
                if (r.i == 0) {
                    serr(c, e, "division by zero in a constant expression.");
                    return false;
                }
                int64_t a = (int64_t)l.i, b = (int64_t)r.i;
                /* INT64_MIN / -1 wraps to INT64_MIN (two's complement, spec §4.2) */
                out->i = (a == INT64_MIN && b == -1) ? (uint64_t)INT64_MIN : (uint64_t)(a / b);
                out->valid = true; out->type = ty_number; return true;
            }
            if (l.type == ty_decimal) { out->valid = true; out->type = ty_decimal; out->d = l.d / r.d; return true; }
            return false;
        case OP_MOD:
            if (l.type == ty_number) {
                if (r.i == 0) {
                    serr(c, e, "remainder by zero in a constant expression.");
                    return false;
                }
                int64_t a = (int64_t)l.i, b = (int64_t)r.i;
                out->i = (a == INT64_MIN && b == -1) ? 0 : (uint64_t)(a % b);
                out->valid = true; out->type = ty_number; return true;
            }
            return false;
        case OP_AND: if (l.type == ty_bool) { out->valid = true; out->type = ty_bool; out->b = l.b && r.b; return true; } return false;
        case OP_OR:  if (l.type == ty_bool) { out->valid = true; out->type = ty_bool; out->b = l.b || r.b; return true; } return false;
        case OP_EQ: case OP_NEQ: case OP_LT: case OP_LE: case OP_GT: case OP_GE: {
            out->type = ty_bool;
            bool res = false;
            if (l.type == ty_number) {
                int64_t a = (int64_t)l.i, b = (int64_t)r.i;  /* number is signed */
                switch (e->op) {
                case OP_EQ: res = a == b; break;
                case OP_NEQ: res = a != b; break;
                case OP_LT: res = a < b; break;
                case OP_LE: res = a <= b; break;
                case OP_GT: res = a > b; break;
                case OP_GE: res = a >= b; break;
                default: return false;
                }
            } else if (l.type == ty_decimal) {
                switch (e->op) {
                case OP_EQ: res = l.d == r.d; break;
                case OP_NEQ: res = l.d != r.d; break;
                case OP_LT: res = l.d < r.d; break;
                case OP_LE: res = l.d <= r.d; break;
                case OP_GT: res = l.d > r.d; break;
                case OP_GE: res = l.d >= r.d; break;
                default: return false;
                }
            } else if (l.type == ty_bool) {
                if (e->op == OP_EQ) res = l.b == r.b;
                else if (e->op == OP_NEQ) res = l.b != r.b;
                else return false;
            } else return false;
            out->valid = true; out->b = res;
            return true;
        }
        }
        return false;
    }
    default:
        return false;
    }
}

/* ---------------- array literals (spec §8.4) ---------------- */

static OkType check_expr(SemaCtx *c, Node *e); /* fwd: elements are exprs */

/* local (runtime) literal: each element may be any expression assignable to
 * the element type; nested literals recurse. Reports, returns success. */
static bool check_array_lit_runtime(SemaCtx *c, Node *lit, OkType atype, const char *what) {
    bool ok = true;
    lit->rtype = atype;
    if (lit->args.len != atype->count) {
        Diag *d = serr(c, lit, "%s expects %zu element%s, but %zu were given.",
                       what, atype->count, atype->count == 1 ? "" : "s", lit->args.len);
        diag_note(d, "the element count is part of the type: %s.", ok_type_name(atype));
        ok = false;
    }
    size_t check_n = lit->args.len < atype->count ? lit->args.len : atype->count;
    for (size_t k = 0; k < check_n; k++) {
        Node *el = lit->args.items[k];
        if (el->kind == A_ARRAYLIT) {
            if (ty_kind(atype->elem) != OK_ARRAY) {
                Diag *d = serr(c, el, "element %zu of %s must be `%s`, not a nested array.",
                               k + 1, what, ok_type_name(atype->elem));
                (void)d;
                ok = false;
                continue;
            }
            if (!check_array_lit_runtime(c, el, atype->elem, what)) ok = false;
            continue;
        }
        OkType et = check_expr(c, el);
        if (!assignable_value(c, el, et, atype->elem)) {
            Diag *d = serr(c, el, "element %zu of %s must be `%s`, but a `%s` value was given.",
                           k + 1, what, ok_type_name(atype->elem), ok_type_name(et));
            diag_note(d, "safe widening is implicit; everything else converts explicitly (spec §4.4).");
            ok = false;
        } else if (et != atype->elem && atype->elem == ty_decimal && c->opt->warnings && el->kind != A_INT) {
            swarn(c, el, "element %zu of %s implicitly widens to `decimal`.",
                  k + 1, what);
        }
    }
    return ok;
}

/* global (constant) literal: elements must fold; builds the ConstVal the
 * backend emits into .data. Nested literals recurse. */
static bool check_array_lit_const(SemaCtx *c, Node *lit, OkType atype, const char *what,
                                  ConstVal *out) {
    bool ok = true;
    memset(out, 0, sizeof *out);
    out->type = atype;
    out->nelems = lit->args.len;
    out->elems = ok_xmalloc((lit->args.len ? lit->args.len : 1) * sizeof(ConstVal));
    if (lit->args.len != atype->count) {
        Diag *d = serr(c, lit, "%s expects %zu element%s, but %zu were given.",
                       what, atype->count, atype->count == 1 ? "" : "s", lit->args.len);
        diag_note(d, "the element count is part of the type: %s.", ok_type_name(atype));
        ok = false;
    }
    size_t check_n = lit->args.len < atype->count ? lit->args.len : atype->count;
    for (size_t k = 0; k < check_n; k++) {
        Node *el = lit->args.items[k];
        if (el->kind == A_ARRAYLIT) {
            if (ty_kind(atype->elem) != OK_ARRAY) {
                Diag *d = serr(c, el, "element %zu of %s must be `%s`, not a nested array.",
                               k + 1, what, ok_type_name(atype->elem));
                (void)d;
                ok = false;
                continue;
            }
            if (!check_array_lit_const(c, el, atype->elem, what, &out->elems[k])) ok = false;
            else out->elems[k].valid = true;
            continue;
        }
        size_t mark = c->de->errors;
        ConstVal ev;
        if (!const_eval(c, el, &ev)) {
            if (c->de->errors == mark) {
                Diag *d = serr(c, el, "element %zu of %s is not a compile-time constant.",
                               k + 1, what);
                diag_note(d, "global array elements must be literal or foldable values (spec §7).");
            }
            ok = false;
            continue;
        }
        if (!assignable_value(c, el, ev.type, atype->elem)) {
            Diag *d = serr(c, el, "element %zu of %s must be `%s`, but a `%s` value was given.",
                           k + 1, what, ok_type_name(atype->elem), ok_type_name(ev.type));
            if (ty_is_integer(atype->elem) && ev.type == ty_number) {
                char range[64];
                if (atype->elem->is_signed)
                    snprintf(range, sizeof range, "%lld..%lld",
                             (long long)ty_min_i64(atype->elem),
                             (long long)ty_max_i64(atype->elem));
                else
                    snprintf(range, sizeof range, "0..%llu",
                             (unsigned long long)((1ull << atype->elem->bits) - 1));
                diag_note(d, "the value does not fit `%s` (accepts %s).",
                          ok_type_name(atype->elem), range);
            }
            (void)d;
            ok = false;
            continue;
        }
        if (ty_is_integer(atype->elem)) {
            /* literal / constant into an integer element: re-encode the
             * register representation to the element's semantics */
            ev.type = atype->elem;
            ev.i = ty_reencode(ev.i, atype->elem);
        } else if (ev.type == ty_number && atype->elem == ty_decimal) {
            ev.type = ty_decimal;
            ev.d = (double)ev.i;  /* literal widening stays silent (spec §4.4) */
        }
        ev.valid = true;
        out->elems[k] = ev;
    }
    out->valid = ok;
    return ok;
}

/* constant global initializer into a typed slot: accepts implicit widening
 * and the fitting-literal rule, then re-encodes the representation so the
 * backend emits the right width (spec §4.2/§7). */
static bool const_into_type(SemaCtx *c, Node *init, ConstVal *cv, OkType to) {
    if (cv->type == to) return true;
    if (!assignable_value(c, init, cv->type, to)) return false;
    if (to == ty_decimal) {
        cv->type = ty_decimal;
        cv->d = (double)(int64_t)cv->i;  /* widen silently for .data */
        return true;
    }
    if (ty_is_integer(to)) {
        cv->type = to;
        cv->i = ty_reencode(cv->i, to);
        return true;
    }
    return false;
}

/* ---------------- phase 2: check ---------------- */

static OkType check_expr(SemaCtx *c, Node *e);
static void check_stmt_list(SemaCtx *c, Vec *body);
static void check_stmt(SemaCtx *c, Node *s);

/* Resolve a dotted path to a symbol; reports and returns NULL on failure. */
static Symbol *resolve_path(SemaCtx *c, Node *n, bool want_var) {
    const char *full = path_join_str(n->parts, n->nparts);
    Symbol *first = scope_lookup(c->cur_scope, n->parts[0]);
    if (!first) {
        Diag *d = serr(c, n, "unknown name `%s`.", full);
        const char *sug = ok_suggest_name(c->cur_scope, n->parts[0]);
        if (sug) diag_note(d, "did you mean `%s`?", sug);
        else diag_note(d, "names come from this file, its columns, main.ok, and used modules (`greeting.greet`).");
        return NULL;
    }
    if (n->nparts == 1) {
        if (want_var && first->kind != SYM_VAR) {
            serr(c, n, "`%s` is a %s, not a variable — it cannot be assigned or read as a value.",
                 full, first->kind == SYM_FUNC ? "function" : "namespace");
            return NULL;
        }
        if (first->kind == SYM_VAR) first->used = true;
        return first;
    }
    /* dotted: walk namespaces */
    Symbol *cur = first;
    for (size_t i = 1; i < n->nparts; i++) {
        if (cur->kind != SYM_NS) {
            serr(c, n, "`%s` is not a namespace — `.` cannot follow it in 0.1.",
                 path_join_str(n->parts, i));
            return NULL;
        }
        Symbol *next = scope_find_local(cur->ns, n->parts[i]);
        if (!next) {
            Diag *d = serr(c, n, "`%s` has no member `%s`.", path_join_str(n->parts, i), n->parts[i]);
            diag_note(d, "available: the public names of `%s`.", n->parts[0]);
            return NULL;
        }
        cur = next;
    }
    if (want_var && cur->kind != SYM_VAR) {
        serr(c, n, "`%s` is a %s, not a variable — it cannot be assigned or read as a value.",
             full, cur->kind == SYM_FUNC ? "function" : "namespace");
        return NULL;
    }
    if (cur->kind == SYM_VAR) cur->used = true;
    return cur;
}

/* require a type with a good message */
static void require_text_feature(SemaCtx *c, Node *n) {
    if (!c->cur_mod->features[OK_FEATURE_TEXT]) {
        Diag *d = serr(c, n, "the text subsystem is not active in this file.");
        diag_note(d, "add `type.text=1` at the top of the file to activate `write` and `print` (spec §5).");
    }
}

/* ---------------- conversion builtins (spec §4.4): `T.to_U(value)` ---- */

/* Recognize `<typename>.to_<typename>` call paths. Returns true and fills
 * `from`/`to` when the path is a conversion builtin. */
static bool conv_builtin_lookup(char **parts, size_t nparts, OkType *from, OkType *to) {
    if (nparts != 2) return false;
    if (strncmp(parts[1], "to_", 3) != 0) return false;
    OkType src, dst;
    if (!ty_from_scalar_name(parts[0], &src)) return false;
    if (!ty_from_scalar_name(parts[1] + 3, &dst)) return false;
    *from = src;
    *to = dst;
    return true;
}

static OkType check_conv_builtin(SemaCtx *c, Node *n, OkType from, OkType to) {
    /* copy the name first: path resolution during argument checking would
     * overwrite the shared static buffer (same trap as check_call) */
    char full[128];
    snprintf(full, sizeof full, "%s", path_join_str(n->parts, n->nparts));
    if (n->args.len != 1) {
        Diag *d = serr(c, n, "`%s` converts exactly one value, but %zu were given.",
                       full, n->args.len);
        diag_note(d, "form: `%s(value)`.", full);
        return to;
    }
    Node *arg = n->args.items[0];
    OkType at = check_expr(c, arg);
    if (!ty_convertible(at, to)) {
        if (at == ty_text || to == ty_text) {
            Diag *d = serr(c, arg, "text conversions such as `%s` are planned but not implemented yet.",
                           full);
            diag_note(d, "they arrive with the text-processing milestone (spec §4.4).");
        } else if (to == ty_bool) {
            Diag *d = serr(c, arg, "there is no conversion to `bool` — compare explicitly instead.");
            diag_note(d, "for example `x != 0` produces the `bool` you probably meant.");
        } else {
            serr(c, arg, "`%s` cannot convert a `%s` value.", full, ok_type_name(at));
        }
    }
    /* rewrite the call node as a conversion expression (IR reads otype) */
    n->kind = A_CONV;
    n->a = arg;
    n->otype = to;
    n->rtype = to;
    return to;
}

static OkType check_call(SemaCtx *c, Node *n) {
    /* conversion builtins (`int32.to_uint8(x)`) are recognized before
     * scope resolution — the `<type>.to_<type>` path belongs to the
     * language, not to any namespace (spec §4.4) */
    {
        OkType cfrom, cto;
        if (conv_builtin_lookup(n->parts, n->nparts, &cfrom, &cto)) {
            /* a user symbol with the same path loses to the builtin */
            Symbol *clash = scope_lookup(c->cur_scope, n->parts[0]);
            if (clash && clash->kind == SYM_NS && scope_find_local(clash->ns, n->parts[1])) {
                Diag *d = serr(c, n, "`%s` is a built-in conversion; `%s.%s` must be renamed.",
                               path_join_str(n->parts, n->nparts), n->parts[0], n->parts[1]);
                (void)d;
            }
            return check_conv_builtin(c, n, cfrom, cto);
        }
    }
    /* path_join_str returns a shared static buffer: copy the call name
     * before checking arguments, whose own path resolution would
     * silently overwrite it (found while testing array diagnostics) */
    char full[256];
    snprintf(full, sizeof full, "%s", path_join_str(n->parts, n->nparts));
    Symbol *target = resolve_path(c, n, false);
    if (!target) return ty_void;
    if (target->kind != SYM_FUNC) {
        serr(c, n, "`%s` is not a function — it cannot be called.", full);
        return ty_void;
    }
    FuncInfo *fi = target->func;
    n->finfo = fi;

    if (n->args.len != fi->nparams) {
        Diag *d = serr(c, n, "`%s` expects %zu argument%s, but %zu were given.",
                       full, fi->nparams, fi->nparams == 1 ? "" : "s", n->args.len);
        char sig[256];
        size_t off = 0;
        off += snprintf(sig + off, sizeof sig - off, "signature: %s(", full);
        for (size_t k = 0; k < fi->nparams && off < sizeof sig - 1; k++)
            off += snprintf(sig + off, sizeof sig - off, "%s%s.%s", k ? ", " : "",
                            ok_type_name(fi->param_types[k]), fi->param_names[k]);
        snprintf(sig + off, sizeof sig - off, ") -> %s", ok_type_name(fi->ret));
        diag_note(d, "%s", sig);
        /* still check the args that were supplied */
    }
    size_t check_n = n->args.len < fi->nparams ? n->args.len : fi->nparams;
    for (size_t i = 0; i < n->args.len; i++) {
        Node *arg = n->args.items[i];
        OkType at = check_expr(c, arg);
        if (i < check_n) {
            OkType want = fi->param_types[i];
            if (!assignable_value(c, arg, at, want)) {
                Diag *d = serr(c, arg, "argument %zu of `%s` must be `%s`, but a `%s` value was given.",
                               i + 1, full, ok_type_name(want), ok_type_name(at));
                diag_note(d, "conversions are explicit builtins like `int32.to_uint8(x)` (spec §4.4).");
            } else if (at != want && want == ty_decimal && c->opt->warnings && arg->kind != A_INT) {
                swarn(c, arg, "argument %zu of `%s` implicitly widens to `decimal`.",
                      i + 1, full);
            }
        }
    }
    n->rtype = fi->ret;
    return fi->ret;
}

static OkType check_write(SemaCtx *c, Node *n) {
    require_text_feature(c, n);
    if (n->args.len != 1) {
        serr(c, n, "`write` takes exactly one value (`write(x)`), but %zu were given.", n->args.len);
    }
    for (size_t i = 0; i < n->args.len; i++) {
        Node *arg = n->args.items[i];
        OkType at = check_expr(c, arg);
        if (ty_kind(at) == OK_ARRAY) {
            Diag *d = serr(c, arg, "`write` prints one value at a time, not a whole array.");
            diag_note(d, "loop over the array and `write(xs[i])` for each element (spec §11).");
        }
    }
    n->rtype = ty_void;
    return ty_void;
}

/* contextual literal typing (spec §4.2): an integer literal (or negated
 * literal) whose value fits the OTHER operand's integer type participates
 * as that type — `int32big * 2` stays `int32`, `uint64max - 1` stays
 * `uint64`. Literals that do not fit keep `number` semantics. */
static OkType literal_as(Node *e, OkType other) {
    if (!other || !ty_is_integer(other)) return NULL;
    if (e->rtype != ty_number) return NULL;
    if (e->kind == A_INT && ty_uint_fits(e->ival, other)) return other;
    if (e->kind == A_UN && e->uop == UN_NEG && e->a->kind == A_INT) {
        int64_t v = -(int64_t)e->a->ival;
        if (ty_sint_fits(v, other)) return other;
    }
    return NULL;
}

static OkType check_bin(SemaCtx *c, Node *e) {
    OkType lt = check_expr(c, e->a);
    OkType rt = check_expr(c, e->b);

    /* operand type after literal adaptation + widening (spec §4.4);
     * stashed on the node for IR to reuse — comparisons store it too,
     * their rtype is `bool` and would otherwise lose the operand type */
    OkType lt_eff = literal_as(e->a, rt);
    if (!lt_eff) lt_eff = lt;
    OkType rt_eff = literal_as(e->b, lt);
    if (!rt_eff) rt_eff = rt;
    OkType ct = ty_common(lt_eff, rt_eff);
    e->otype = ct;

    switch (e->op) {
    case OP_AND: case OP_OR: {
        if (lt != ty_bool || rt != ty_bool) {
            serr(c, e, "`and`/`or` combine `bool` values, but `%s` and `%s` were given.",
                 ok_type_name(lt), ok_type_name(rt));
        }
        e->rtype = ty_bool;
        return ty_bool;
    }
    case OP_EQ: case OP_NEQ: {
        if (ty_kind(lt) == OK_ARRAY || ty_kind(rt) == OK_ARRAY) {
            Diag *d = serr(c, e, "arrays are not comparable with `%s` in 0.2.",
                           e->op == OP_EQ ? "==" : "!=");
            diag_note(d, "compare elements individually (for example inside a loop).");
            e->rtype = ty_bool;
            return ty_bool;
        }
        if (lt == ty_text && rt == ty_text) { e->rtype = ty_bool; return ty_bool; }
        if (lt == ty_bool && rt == ty_bool) { e->rtype = ty_bool; return ty_bool; }
        if (ct) {
            if (lt != rt && c->opt->warnings && !(e->a->kind == A_INT) && !(e->b->kind == A_INT))
                swarn(c, e, "comparison mixes `%s` and `%s` — the narrower operand widens.",
                      ok_type_name(lt), ok_type_name(rt));
            e->rtype = ty_bool;
            return ty_bool;
        }
        serr(c, e, "`%s` and `%s` cannot be compared for equality.",
             ok_type_name(lt), ok_type_name(rt));
        e->rtype = ty_bool;
        return ty_bool;
    }
    case OP_LT: case OP_LE: case OP_GT: case OP_GE: {
        if (ct && ct != ty_decimal) {
            if (lt != rt && c->opt->warnings && !(e->a->kind == A_INT) && !(e->b->kind == A_INT))
                swarn(c, e, "comparison mixes `%s` and `%s` — the narrower operand widens.",
                      ok_type_name(lt), ok_type_name(rt));
            e->rtype = ty_bool;
            return ty_bool;
        }
        if (ct == ty_decimal) {
            if (lt != rt && c->opt->warnings && !(e->a->kind == A_INT) && !(e->b->kind == A_INT))
                swarn(c, e, "comparison mixes an integer and `decimal` — the integer side widens.");
            e->rtype = ty_bool;
            return ty_bool;
        }
        if (lt == ty_text && rt == ty_text) {
            serr(c, e, "text is not ordered — only `==` and `!=` are defined for `text` in 0.1.");
            e->rtype = ty_bool;
            return ty_bool;
        }
        serr(c, e, "`%s` and `%s` cannot be ordered.", ok_type_name(lt), ok_type_name(rt));
        e->rtype = ty_bool;
        return ty_bool;
    }
    case OP_ADD: {
        if (lt == ty_text && rt == ty_text) { e->rtype = ty_text; return ty_text; }
        goto arith;
    }
    case OP_SUB: case OP_MUL: case OP_DIV: {
        if (lt == ty_text || rt == ty_text) {
            serr(c, e, "`+` concatenates `text` with `text`; `%s` and `%s` do not combine.",
                 ok_type_name(lt), ok_type_name(rt));
            e->rtype = lt == ty_text ? ty_text : ty_number;
            return e->rtype;
        }
        goto arith;
    }
    case OP_MOD: {
        if (ct && ct != ty_decimal && ty_is_integer(ct)) {
            e->rtype = ct;
            return ct;
        }
        if (ct == ty_decimal || lt == ty_decimal || rt == ty_decimal) {
            serr(c, e, "remainder (`%%`) is defined for integer types only in 0.3; a decimal remainder builtin is planned.");
        } else {
            serr(c, e, "`%%` needs integer operands, but `%s` and `%s` were given.",
                 ok_type_name(lt), ok_type_name(rt));
        }
        e->rtype = ty_number;
        return ty_number;
    }
    }
arith: ;
    if (ct) {
        if (ct == ty_decimal && lt != ty_decimal && c->opt->warnings) {
            /* literal number in a decimal context is silent (spec §4.4) */
            if (!(e->a->kind == A_INT) && !(e->b->kind == A_INT))
                swarn(c, e, "arithmetic mixes an integer and `decimal` — the integer operand widens to `decimal`.");
        } else if (ct != ty_decimal && lt != rt && c->opt->warnings &&
                   !(e->a->kind == A_INT) && !(e->b->kind == A_INT)) {
            swarn(c, e, "arithmetic mixes `%s` and `%s` — the narrower operand widens to `%s`.",
                  ok_type_name(lt), ok_type_name(rt), ok_type_name(ct));
        }
        e->rtype = ct;
        return ct;
    }
    if (lt == ty_bool || rt == ty_bool) {
        serr(c, e, "`bool` values do not take arithmetic (use `and`/`or`/`not`).");
    } else {
        Diag *d = serr(c, e, "`%s` and `%s` do not combine arithmetically.",
                       ok_type_name(lt), ok_type_name(rt));
        if (ty_is_integer(lt) && ty_is_integer(rt))
            diag_note(d, "mixed signedness or widths that do not widen safely need an explicit conversion (for example `int32.to_uint8(x)`).");
    }
    e->rtype = ty_number;
    return ty_number;
}

static OkType check_expr(SemaCtx *c, Node *e) {
    e->checked = true;
    switch (e->kind) {
    case A_INT:  e->rtype = ty_number; return ty_number;
    case A_DEC:  e->rtype = ty_decimal; return ty_decimal;
    case A_BOOL: e->rtype = ty_bool; return ty_bool;
    case A_TEXT: e->rtype = ty_text; return ty_text;
    case A_PATH: {
        Symbol *s = resolve_path(c, e, true);
        if (!s) { e->rtype = ty_number; return ty_number; }
        e->sym = s;
        e->rtype = s->type;
        return s->type;
    }
    case A_CALL:  return check_call(c, e);
    case A_CONV:
        /* sema rewrote a conversion builtin into this node; rechecking
         * (e.g. from an enclosing expression after recovery) re-validates
         * the operand only */
        check_expr(c, e->a);
        e->rtype = e->otype;
        return e->otype;
    case A_WRITE: return check_write(c, e);
    case A_BIN:   return check_bin(c, e);
    case A_ARRAYLIT: {
        Diag *d = serr(c, e, "an array literal belongs to a declaration: `type.array<type.number, 3> xs = { ... }`.");
        diag_note(d, "assignment copies whole arrays from other arrays; literals are for declarations (spec §8.4).");
        e->rtype = NULL;
        return NULL;
    }
    case A_INDEX: {
        OkType bt = check_expr(c, e->a);
        if (!bt || ty_kind(bt) != OK_ARRAY) {
            Diag *d = serr(c, e, "this value is a `%s` — only arrays can be indexed.", ok_type_name(bt));
            diag_note(d, "array indexing is `name[index]`; the index must be an integer type (spec §9).");
            check_expr(c, e->b); /* still check the index */
            e->rtype = ty_number;
            return ty_number;
        }
        OkType it = check_expr(c, e->b);
        if (!ty_is_integer(it)) {
            Diag *d = serr(c, e->b, "the array index must be an integer type, but `%s` was given.", ok_type_name(it));
            diag_note(d, "out-of-bounds access (including negative indices) is a runtime trap (spec §8.4).");
        }
        e->rtype = bt->elem;
        return bt->elem;
    }
    case A_UN: {
        OkType t = check_expr(c, e->a);
        if (e->uop == UN_NEG) {
            if (!ty_is_integer(t) && t != ty_decimal)
                serr(c, e, "unary `-` needs an integer or `decimal`, but `%s` was given.", ok_type_name(t));
            e->rtype = t;
            return t;
        }
        if (t != ty_bool)
            serr(c, e, "`not` needs a `bool`, but `%s` was given.", ok_type_name(t));
        e->rtype = ty_bool;
        return ty_bool;
    }
    default:
        serr(c, e, "this expression form is not valid here.");
        e->rtype = ty_void;
        return ty_void;
    }
}

/* does a statement list always flow out of the function (return/break/continue
 * or when/else where both branches do)? conservative (spec §8.2). */
static bool list_exits(Vec *body) {
    for (size_t i = 0; i < body->len; i++) {
        Node *s = body->items[i];
        if (s->kind == A_RETURN || s->kind == A_BREAK || s->kind == A_CONTINUE)
            return true;
        if (s->kind == A_WHEN && s->body_else.len > 0 &&
            list_exits(&s->body) && list_exits(&s->body_else))
            return true;
    }
    return false;
}
static bool list_returns(Vec *body) {
    for (size_t i = 0; i < body->len; i++) {
        Node *s = body->items[i];
        if (s->kind == A_RETURN && s->a) return true;
        if (s->kind == A_WHEN && s->body_else.len > 0 &&
            list_returns(&s->body) && list_returns(&s->body_else))
            return true;
    }
    return false;
}

static void check_func_body(SemaCtx *c, Node *fn, FuncInfo *fi) {
    Scope *fs = scope_new("the function", c->cur_scope);
    c->cur_scope = fs;
    c->cur_func = fi;
    c->in_loop = false;

    /* parameters live in the function scope */
    fi->param_syms = ok_xmalloc((fn->nparams ? fn->nparams : 1) * sizeof(Symbol *));
    for (size_t i = 0; i < fn->nparams; i++) {
        Symbol *ps = scope_insert(fs, fn->params[i].name, SYM_VAR, fn->line, fn->col);
        ps->type = fn->params[i].type;
        ps->decl = fn;
        ps->used = true; /* params count as used */
        fi->param_syms[i] = ps;
    }

    check_stmt_list(c, &fn->body);

    /* valued functions must return on every path (spec §8.2) */
    if (fi->ret != ty_void && !list_returns(&fn->body)) {
        Diag *d = serr(c, fn, "function `%s` promises a `%s` result, but some paths fall off the end without `return`.",
                       fi->name, ok_type_name(fi->ret));
        diag_note(d, "Okular checks every exit path conservatively: loops never count as guaranteed returns.");
    }

    /* unused locals (warning) */
    if (c->opt->warnings) {
        for (size_t i = 0; i < fs->n; i++) {
            Symbol *s = fs->syms[i];
            if (s->kind == SYM_VAR && !s->used && s->decl && s->decl->kind == A_VARDECL) {
                swarn(c, s->decl, "variable `%s` is never used.", s->name);
            }
        }
    }

    c->cur_scope = fs->parent;
    c->cur_func = NULL;
}

static void check_stmt(SemaCtx *c, Node *s) {
    switch (s->kind) {
    case A_VARDECL: {
        if (ty_kind(s->otype) == OK_ARRAY) {
            if (s->a->kind == A_ARRAYLIT) {
                check_array_lit_runtime(c, s->a, s->otype, s->name);
            } else {
                OkType it = check_expr(c, s->a);
                if (it != s->otype) {
                    Diag *d = serr(c, s, "variable `%s` is `%s`, but the initializer is `%s`.",
                                   s->name, ok_type_name(s->otype), ok_type_name(it));
                    diag_note(d, "array copies require the exact same array type (element type and count).");
                }
            }
            Symbol *ex = scope_insert(c->cur_scope, s->name, SYM_VAR, s->line, s->col);
            if (ex->decl && ex->decl != s) {
                serr(c, s, "duplicate definition of `%s` in this scope.", s->name);
                break;
            }
            ex->type = s->otype;
            ex->decl = s;
            s->sym = ex;
            break;
        }
        if (s->a->kind == A_ARRAYLIT) {
            Diag *d = serr(c, s, "variable `%s` is `%s`, but the initializer is an array literal.",
                           s->name, ok_type_name(s->otype));
            diag_note(d, "array literals initialize array variables: `type.array<type.%s, N> name = { ... }`.",
                      ok_type_name(s->otype));
            break;
        }
        OkType it = check_expr(c, s->a);
        if (!assignable_value(c, s->a, it, s->otype)) {
            Diag *d = serr(c, s, "variable `%s` is `%s`, but the initializer is `%s`.",
                           s->name, ok_type_name(s->otype), ok_type_name(it));
            diag_note(d, "safe widening is implicit; narrowing and signedness changes use explicit conversions like `int32.to_uint8(x)` (spec §4.4).");
        } else if (it != s->otype && s->otype == ty_decimal && c->opt->warnings && s->a->kind != A_INT) {
            swarn(c, s, "initializer implicitly widens to `decimal` for `%s`.", s->name);
        }
        Symbol *ex = scope_insert(c->cur_scope, s->name, SYM_VAR, s->line, s->col);
        if (ex->decl && ex->decl != s) {
            serr(c, s, "duplicate definition of `%s` in this scope.", s->name);
            break;
        }
        if (c->opt->extra_warnings && ex->scope != c->cur_scope) {
            /* shadowing an outer name (inserted into an ancestor before) */
        }
        ex->type = s->otype;
        ex->decl = s;
        s->sym = ex;
        break;
    }
    case A_ASSIGN: {
        Symbol *target = resolve_path(c, s, true);
        if (!target) break;
        s->sym = target;
        OkType vt = check_expr(c, s->a);
        if (ty_kind(target->type) == OK_ARRAY || ty_kind(vt) == OK_ARRAY) {
            if (vt != target->type) {
                Diag *d = serr(c, s, "cannot assign a `%s` value to `%s`, which is `%s`.",
                               ok_type_name(vt), path_join_str(s->parts, s->nparts),
                               ok_type_name(target->type));
                diag_note(d, "array assignment copies the contents; the types must match exactly (spec §8.4).");
            }
            break;
        }
        if (!assignable_value(c, s->a, vt, target->type)) {
            serr(c, s, "cannot assign a `%s` value to `%s`, which is `%s`.",
                 ok_type_name(vt), path_join_str(s->parts, s->nparts), ok_type_name(target->type));
        } else if (vt != target->type && target->type == ty_decimal && c->opt->warnings && s->a->kind != A_INT) {
            swarn(c, s, "assignment implicitly widens to `decimal`.");
        }
        break;
    }
    case A_INDEXASSIGN: {
        OkType bt = check_expr(c, s->a);   /* base: A_PATH or nested A_INDEX */
        if (!bt || ty_kind(bt) != OK_ARRAY) {
            Diag *d = serr(c, s, "this value is a `%s` — only array elements can be indexed for assignment.",
                           ok_type_name(bt));
            diag_note(d, "store into arrays with `name[index] = value` (spec §8.4).");
            check_expr(c, s->b);
            check_expr(c, s->c);
            break;
        }
        OkType it = check_expr(c, s->b);
        if (!ty_is_integer(it)) {
            Diag *d = serr(c, s->b, "the array index must be an integer type, but `%s` was given.", ok_type_name(it));
            diag_note(d, "out-of-bounds access is a runtime trap (spec §8.4).");
        }
        OkType elem = bt->elem;
        OkType vt = check_expr(c, s->c);
        if (ty_kind(elem) == OK_ARRAY) {
            if (vt != elem) {
                Diag *d = serr(c, s->c, "this element is `%s`, but a `%s` value was given.",
                               ok_type_name(elem), ok_type_name(vt));
                diag_note(d, "assigning a whole inner array copies it; the types must match exactly.");
            }
            break;
        }
        if (!assignable_value(c, s->c, vt, elem)) {
            Diag *d = serr(c, s->c, "the array elements are `%s`, but a `%s` value was given.",
                           ok_type_name(elem), ok_type_name(vt));
            diag_note(d, "safe widening is implicit; everything else converts explicitly (spec §4.4).");
        } else if (vt != elem && elem == ty_decimal && c->opt->warnings && s->c->kind != A_INT) {
            swarn(c, s, "element assignment implicitly widens to `decimal`.");
        }
        break;
    }
    case A_EXPRSTMT: {
        OkType t = check_expr(c, s->a);
        if (s->a->kind != A_CALL && s->a->kind != A_WRITE) {
            serr(c, s->a, "an expression statement must be a call like `physics.fall(3)` or `write(x)`.");
        }
        (void)t;
        break;
    }
    case A_WHEN: {
        OkType ct = check_expr(c, s->a);
        if (ct != ty_bool) {
            Diag *d = serr(c, s->a, "the `when` condition must be `bool`, but `%s` was given.", ok_type_name(ct));
            diag_note(d, "comparisons (`==`, `<`, ...) produce `bool`.");
        }
        Scope *sc = scope_new("the when block", c->cur_scope);
        c->cur_scope = sc;
        check_stmt_list(c, &s->body);
        c->cur_scope = sc->parent;
        if (s->body_else.len) {
            Scope *sc2 = scope_new("the else block", c->cur_scope);
            c->cur_scope = sc2;
            check_stmt_list(c, &s->body_else);
            c->cur_scope = sc2->parent;
        }
        break;
    }
    case A_LOOP_COUNT: {
        OkType ft = check_expr(c, s->a);
        OkType bt = check_expr(c, s->b);
        if (ft != ty_number) serr(c, s->a, "the loop start must be `number`, but `%s` was given.", ok_type_name(ft));
        if (bt != ty_number) serr(c, s->b, "the loop bound must be `number`, but `%s` was given.", ok_type_name(bt));

        Scope *sc = scope_new("the loop", c->cur_scope);
        c->cur_scope = sc;
        Symbol *lv = scope_insert(sc, s->name, SYM_VAR, s->line, s->col);
        lv->type = ty_number;
        lv->decl = s;
        lv->used = true;
        s->sym = lv; /* IR needs the loop variable's slot symbol */
        bool saved = c->in_loop;
        c->in_loop = true;
        check_stmt_list(c, &s->body);
        c->in_loop = saved;
        c->cur_scope = sc->parent;
        break;
    }
    case A_LOOP_COND: {
        OkType ct = check_expr(c, s->a);
        if (ct != ty_bool) serr(c, s->a, "the loop condition must be `bool`, but `%s` was given.", ok_type_name(ct));
        Scope *sc = scope_new("the loop", c->cur_scope);
        c->cur_scope = sc;
        bool saved = c->in_loop;
        c->in_loop = true;
        check_stmt_list(c, &s->body);
        c->in_loop = saved;
        c->cur_scope = sc->parent;
        break;
    }
    case A_BREAK:
        if (!c->in_loop) serr(c, s, "`break` is only meaningful inside a loop.");
        break;
    case A_CONTINUE:
        if (!c->in_loop) serr(c, s, "`continue` is only meaningful inside a loop.");
        break;
    case A_PRINT:
        require_text_feature(c, s);
        break;
    case A_WRITE:
        check_write(c, s);
        break;
    case A_DIRECTIVE:
    case A_LANGCOL:
        /* top-level constructs; validated during collect */
        break;
    case A_RETURN: {
        if (!c->cur_func) { serr(c, s, "`return` is only valid inside a function."); break; }
        OkType rt = c->cur_func->ret;
        if (s->a) {
            OkType vt = check_expr(c, s->a);
            if (rt == ty_void) {
                Diag *d = serr(c, s, "this function returns nothing, so `return` must not carry a value.");
                diag_found(d, "returned a `%s` value.", ok_type_name(vt));
            } else if (!assignable_value(c, s->a, vt, rt)) {
                serr(c, s, "this function must return `%s`, but `return` gives `%s`.",
                     ok_type_name(rt), ok_type_name(vt));
            } else if (vt != rt && rt == ty_decimal && c->opt->warnings && s->a->kind != A_INT) {
                swarn(c, s, "return value implicitly widens to `decimal`.");
            }
        } else {
            if (rt != ty_void && !c->cur_func->is_entry) {
                serr(c, s, "this function promises a `%s` result — `return` needs a value.", ok_type_name(rt));
            }
        }
        break;
    }
    default:
        serr(c, s, "this statement is not allowed here.");
    }
}

static void check_stmt_list(SemaCtx *c, Vec *body) {
    for (size_t i = 0; i < body->len; i++) {
        Node *s = body->items[i];
        check_stmt(c, s);
        /* unreachable code after an exiting statement (spec §14, -w) */
        if (c->opt->warnings && i + 1 < body->len) {
            Vec one; one.items = &body->items[i]; one.len = 1; one.cap = 1;
            if (list_exits(&one)) {
                Node *next = body->items[i + 1];
                swarn(c, next, "unreachable code — the statement above always exits this block.");
            }
        }
    }
}

/* check one column's members (recursively) with the column's namespace scope */
static void check_column(SemaCtx *c, Node *col, Scope *ns) {
    for (size_t k = 0; k < col->body.len; k++) {
        Node *mem = col->body.items[k];
        if (mem->kind == A_FUNC) {
            if (mem->finfo) {
                c->cur_scope = ns;
                check_func_body(c, mem, mem->finfo);
            }
        } else if (mem->kind == A_VARDECL) {
            if (ty_kind(mem->otype) == OK_ARRAY) {
                char what[192];
                snprintf(what, sizeof what, "array `%s.%s`", col->name, mem->name);
                if (mem->a->kind != A_ARRAYLIT) {
                    Diag *d = serr(c, mem, "the initializer of `%s.%s` must be an array literal `{ ... }`.",
                                   col->name, mem->name);
                    diag_note(d, "global initializers must be compile-time constants (spec §7).");
                    c->cur_scope = ns;
                    check_expr(c, mem->a);
                } else {
                    ConstVal cv;
                    check_array_lit_const(c, mem->a, mem->otype, what, &cv);
                    if (mem->sym) mem->sym->cval = cv;
                }
                continue;
            }
            if (mem->a->kind == A_ARRAYLIT) {
                Diag *d = serr(c, mem, "`%s.%s` is `%s`, but the initializer is an array literal.",
                               col->name, mem->name, ok_type_name(mem->otype));
                (void)d;
                continue;
            }
            ConstVal cv;
            size_t mark = c->de->errors;
            bool okc = const_eval(c, mem->a, &cv);
            if (!okc) {
                c->cur_scope = ns;
                check_expr(c, mem->a); /* validate (+ rewrite conversion builtins) */
                if (mem->a->kind == A_CONV && c->de->errors == mark) {
                    mark = c->de->errors;
                    okc = const_eval(c, mem->a, &cv); /* retry as a folded conversion */
                }
            }
            if (!okc) {
                if (c->de->errors == mark) {
                    Diag *d = serr(c, mem, "the initializer of `%s.%s` is not a compile-time constant.",
                                   col->name, mem->name);
                    diag_note(d, "global initializers must be literal or foldable values in 0.1 (spec §7); use main.ok top-level statements for computed setup.");
                }
            } else {
                if (!const_into_type(c, mem->a, &cv, mem->otype)) {
                    serr(c, mem, "`%s.%s` is `%s`, but the initializer is `%s`.",
                         col->name, mem->name, ok_type_name(mem->otype), ok_type_name(cv.type));
                }
                if (mem->sym) mem->sym->cval = cv;
            }
        } else if (mem->kind == A_DEVCOL) {
            Symbol *nested = scope_find_local(ns, mem->name);
            if (nested && nested->ns) check_column(c, mem, nested->ns);
        }
    }
}

/* check one module's declarations and bodies */
static void check_module(SemaCtx *c, OkModule *m, Scope *scope) {
    c->cur_mod = m;
    c->cur_scope = scope;

    for (size_t i = 0; i < m->ast->body.len; i++) {
        Node *n = m->ast->body.items[i];
        switch (n->kind) {
        case A_FUNC: {
            if (n->finfo) {
                c->cur_scope = scope;
                check_func_body(c, n, n->finfo);
            }
            break;
        }
        case A_VARDECL: {
            /* global: initializer must be a compile-time constant (spec §7) */
            if (ty_kind(n->otype) == OK_ARRAY) {
                char what[160];
                snprintf(what, sizeof what, "global array `%s`", n->name);
                if (n->a->kind != A_ARRAYLIT) {
                    Diag *d = serr(c, n, "the initializer of global array `%s` must be an array literal `{ ... }`.", n->name);
                    diag_note(d, "global initializers must be compile-time constants (spec §7).");
                    c->cur_scope = scope;
                    check_expr(c, n->a);
                } else {
                    ConstVal cv;
                    check_array_lit_const(c, n->a, n->otype, what, &cv);
                    if (n->sym) n->sym->cval = cv;
                }
                break;
            }
            if (n->a->kind == A_ARRAYLIT) {
                Diag *d = serr(c, n, "variable `%s` is `%s`, but the initializer is an array literal.",
                               n->name, ok_type_name(n->otype));
                (void)d;
                break;
            }
            ConstVal cv;
            size_t mark = c->de->errors;
            bool okc = const_eval(c, n->a, &cv);
            if (!okc) {
                c->cur_scope = scope;
                check_expr(c, n->a); /* validate (+ rewrite conversion builtins) */
                /* a conversion builtin is now an A_CONV node: retry folding */
                if (n->a->kind == A_CONV && c->de->errors == mark) {
                    mark = c->de->errors;
                    okc = const_eval(c, n->a, &cv);
                }
            }
            if (!okc) {
                if (c->de->errors == mark) {
                    Diag *d = serr(c, n, "the initializer of global `%s` is not a compile-time constant.",
                                   n->name);
                    diag_note(d, "global initializers must be literal or foldable values in 0.1 (spec §7); use main.ok top-level statements for computed setup.");
                }
            } else {
                if (!const_into_type(c, n->a, &cv, n->otype)) {
                    serr(c, n, "variable `%s` is `%s`, but the initializer is `%s`.",
                         n->name, ok_type_name(n->otype), ok_type_name(cv.type));
                }
                if (n->sym) n->sym->cval = cv;
            }
            break;
        }
        case A_DEVCOL: {
            Symbol *colsym = scope_find_local(scope, n->name);
            if (colsym && colsym->ns) check_column(c, n, colsym->ns);
            break;
        }
        case A_DIRECTIVE:
        case A_LANGCOL:
            /* collected/validated in phase 1; no body to check */
            break;
        default:
            /* statements: only legal in main.ok (spec §7) */
            if (strcmp(m->name, "main") != 0) {
                Diag *d = serr(c, n, "top-level statements are only allowed in `main.ok`.");
                diag_note(d, "source files expose declarations; their code runs when called (spec §6.2).");
                break;
            }
            /* main top level runs as the entry function: return = exit code */
            if (!m->entry) {
                m->entry = funcinfo_new("__ok_entry", "__ok_entry", ty_number, NULL, m);
                m->entry->is_entry = true;
            }
            c->cur_func = m->entry;
            c->cur_scope = scope;
            check_stmt(c, n);
            c->cur_func = NULL;
            break;
        }
    }
}

/* ---------------- driver ---------------- */

bool sema_run(OkProject *p, DiagEngine *de, const OkOptions *opt) {
    SemaCtx c;
    c.de = de; c.proj = p; c.opt = opt;
    c.root = scope_new("main.ok", NULL);
    c.cur_mod = NULL; c.cur_scope = NULL; c.cur_func = NULL; c.in_loop = false;

    size_t errmark = de->errors;

    /* phase 1: collect symbols, module scopes */
    for (size_t i = 0; i < p->modules.len; i++) {
        OkModule *m = p->modules.items[i];
        if (m->state != MOD_LOADED) continue;
        if (strcmp(m->name, "main") == 0) {
            collect_toplevel(&c, m, m->ast, c.root);
        } else {
            Scope *mscope = scope_new(m->name, c.root);
            collect_toplevel(&c, m, m->ast, mscope);
            /* bind the module namespace into root (spec §6.2) */
            Symbol *bind = scope_insert(c.root, m->name, SYM_NS, 0, 0);
            if (bind->ns && bind->ns != mscope) {
                diag_error_noloc(de, "module name `%s` collides with another module or a main.ok column.", m->name);
            }
            bind->ns = mscope;
        }
    }

    /* phase 2: check bodies */
    for (size_t i = 0; i < p->modules.len; i++) {
        OkModule *m = p->modules.items[i];
        if (m->state != MOD_LOADED) continue;
        Scope *mscope = (strcmp(m->name, "main") == 0)
            ? c.root
            : scope_find_local(c.root, m->name)->ns;
        bool saved = de->force_warning;
        if (!m->required && !opt->strict)
            de->force_warning = true; /* optional policy (brief §36); NOT in strict */
        size_t mark = de->len;
        check_module(&c, m, mscope);
        if (de->errors > mark) {
            m->broken = true;
        } else if (!m->required) {
            /* downgraded errors (was-error diagnostics) mean the optional
             * module failed to compile and will be skipped (brief §36) */
            for (size_t k = mark; k < de->len; k++)
                if (de->items[k].downgraded) { m->broken = true; break; }
        }
        de->force_warning = saved;
    }

    return de->errors == errmark;
}
