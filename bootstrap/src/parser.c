/* parser.c — recursive descent parser for Okular 0.1 (spec §16).
 *
 * Recovery model (brief §43): statements synchronize at newline, `}`,
 * `.end`, and EOF. The parser always returns a full A_FILE tree; errors are
 * collected so one compilation can report many independent problems.
 *
 * Grammar notes:
 *  - `type.X = v`  -> feature directive   (spec §5)
 *    `type.X n = v` -> variable declaration (spec §8.1)
 *    distinguished by one token of lookahead after `type.<name>`.
 *  - params and return types use bare type names (`number.a`, `-> number`),
 *    statement declarations use the `type.` prefix — both forms are pinned
 *    by the engineering brief's own examples.
 */
#include "ok/parser.h"

typedef struct {
    TokList *toks;
    SourceFile *f;
    DiagEngine *de;
    Arena *ar;
    size_t pos;
} Parser;

/* struct-name registry (0.5, spec §8.3): one shared placeholder type per
 * name, pre-scanned so forward references parse; PROCESS-GLOBAL because
 * struct types form one flat namespace across the project's files; sema
 * fills the placeholders in place during collection */
typedef struct NamedTypeEntry {
    char *name;
    OkType placeholder;
    struct NamedTypeEntry *next;
} NamedTypeEntry;

static NamedTypeEntry *named_types[64];

static OkType parser_named_type(Parser *p, const char *name) {
    (void)p;
    size_t h = 0;
    for (const char *c = name; *c; c++) h = h * 31u + (size_t)*c;
    h &= 63;
    for (NamedTypeEntry *e = named_types[h]; e; e = e->next)
        if (strcmp(e->name, name) == 0) return e->placeholder;
    NamedTypeEntry *e = ok_xmalloc(sizeof *e);
    e->name = ok_xstrdup(name);
    e->placeholder = ty_named_placeholder(name);
    e->next = named_types[h];
    named_types[h] = e;
    return e->placeholder;
}

/* public wrapper: the machine-AST deserializer maps `T n:Name` records to
 * the same shared placeholder the C parser would have produced */
OkType parser_named_type_public(const char *name) {
    return parser_named_type(NULL, name);
}

/* every registered struct/union name (the --selfhost-parse bridge passes
 * them to the Okular parser so cross-file references resolve, spec §8.3) */
void parser_named_type_names(Vec *out) {
    for (size_t b = 0; b < 64; b++)
        for (NamedTypeEntry *e = named_types[b]; e; e = e->next)
            vec_push(out, ok_xstrdup(e->name));
}

/* pre-scan a token stream for `struct . NAME = {` so every reference to
 * NAME — including ones parsed before the declaration, and in other files
 * — shares one placeholder (spec §8.3: forward references are legal).
 * Exported for the two-phase project loader. */
void parser_register_struct_names(TokList *toks) {
    for (size_t i = 0; i + 4 < toks->len; i++) {
        Tok *t = &toks->items[i];
        /* `struct . NAME = {` or `union . NAME = {`: record names share one
         * flat pre-scanned registry (spec §8.3/§8.5) */
        if (t->kind != T_KW_STRUCT && t->kind != T_KW_UNION) continue;
        if (toks->items[i + 1].kind != T_DOT) continue;
        if (toks->items[i + 2].kind != T_IDENT) continue;
        if (toks->items[i + 3].kind != T_EQ) continue;
        if (toks->items[i + 4].kind != T_LBRACE) continue;
        Parser dummy;
        parser_named_type(&dummy, toks->items[i + 2].text);
    }
}


/* keyword spellings (0.13, spec §6.6): keywords are legal path members —
 * `sys.write`, `mod.print` — except `end`, which is the column
 * terminator `.end` and must stay reserved. Keywords carry no text
 * payload on any lexer path, so the spelling comes from the kind. */
static const char *tok_keyword_name(TokKind k) {
    switch (k) {
    case T_KW_TYPE: return "type";       case T_KW_FUNCTION: return "function";
    case T_KW_STRUCT: return "struct";   case T_KW_WHEN: return "when";
    case T_KW_ELSE: return "else";       case T_KW_LOOP: return "loop";
    case T_KW_FROM: return "from";       case T_KW_TO: return "to";
    case T_KW_UNTIL: return "until";     case T_KW_BREAK: return "break";
    case T_KW_CONTINUE: return "continue"; case T_KW_RETURN: return "return";
    case T_KW_PRINT: return "print";     case T_KW_WRITE: return "write";
    case T_KW_TRUE: return "true";       case T_KW_FALSE: return "false";
    case T_KW_AND: return "and";         case T_KW_OR: return "or";
    case T_KW_NOT: return "not";         case T_KW_ALLOC: return "alloc";
    case T_KW_RELEASE: return "release"; case T_KW_NULL: return "null";
    case T_KW_UNION: return "union";     case T_KW_CONST: return "const";
    default: return NULL;
    }
}

/* may this token continue a dotted path? identifiers and (nearly all)
 * keywords; `end` is excluded (spec §3.1 terminator) */
static bool is_path_part(TokKind k) {
    return k == T_IDENT || tok_keyword_name(k) != NULL;
}

/* the path-member spelling: the token's text, or the keyword's name */
static char *path_part_text(Tok *t) {
    if (t->kind == T_IDENT) return ok_xstrdup(t->text ? t->text : "");
    return ok_xstrdup(tok_keyword_name(t->kind));
}

/* ---- token helpers ---- */

static Tok *cur(Parser *p) { return &p->toks->items[p->pos]; }
static Tok *at(Parser *p, size_t k) {
    size_t i = p->pos + k;
    if (i >= p->toks->len) i = p->toks->len - 1; /* EOF token */
    return &p->toks->items[i];
}
static bool is(Parser *p, TokKind k) { return cur(p)->kind == k; }
static bool isk(Parser *p, size_t k, TokKind kk) { return at(p, k)->kind == kk; }

static void advance(Parser *p) {
    if (cur(p)->kind != T_EOF) p->pos++;
}

static void skip_nl(Parser *p) {
    while (is(p, T_NL)) advance(p);
}

static Diag *perr(Parser *p, Tok *t, const char *fmt, ...)
    __attribute__((format(printf, 3, 4)));
static Diag *perr(Parser *p, Tok *t, const char *fmt, ...) {
    va_list ap; va_start(ap, fmt);
    char buf[512]; vsnprintf(buf, sizeof buf, fmt, ap); va_end(ap);
    return diag_emit(p->de, DIAG_ERROR, p->f, t->line, t->col, "%s", buf);
}

/* expect a kind; on mismatch emit a precise diagnostic and return NULL */
static Tok *expect(Parser *p, TokKind k, const char *what) {
    /* `>>` splitting (0.11): nested type arguments close with adjacent
     * `>` (`ptr<ptr<number>>`, `alloc<type.array<..., 3>>(...)`). The lexer
     * emits one T_SHR; when a type-argument close needs `>`, split the token
     * in place — one `>` is consumed, the other stays current (as a plain
     * T_GT) for the enclosing close to consume next. */
    if (k == T_GT && is(p, T_SHR)) {
        Tok *t = cur(p);
        t->kind = T_GT;
        t->off += 1; t->col += 1; t->len = 1;
        return t; /* deliberately NOT advancing */
    }
    if (is(p, k)) {
        Tok *t = cur(p);
        advance(p);
        return t;
    }
    Diag *d = perr(p, cur(p), "expected %s, but found %s.",
                   what, tok_kind_name(cur(p)->kind));
    diag_found(d, "%s", tok_kind_name(cur(p)->kind));
    return NULL;
}

/* `.end` terminator of a column (spec §3.1) */
static bool expect_end(Parser *p) {
    Tok *dot = expect(p, T_DOT, "`.` to begin the column terminator `.end`");
    if (!dot) return false;
    if (!expect(p, T_KW_END, "`end` to complete the column terminator `.end`"))
        return false;
    return true;
}

/* sync: skip tokens until a statement boundary (brief §43) */
static void sync_stmt(Parser *p) {
    int guard = 0;
    while (!is(p, T_EOF) && !is(p, T_NL) && !is(p, T_RBRACE)) {
        advance(p);
        if (++guard > 4096) break; /* pathological; EOF handles the rest */
    }
    if (is(p, T_NL)) advance(p);
}

/* skip a whole `{ ... }.end` region after a reported error (e.g. struct) */
static void skip_column_region(Parser *p) {
    int depth = 0;
    while (!is(p, T_EOF)) {
        if (is(p, T_LBRACE)) depth++;
        else if (is(p, T_RBRACE)) {
            depth--;
            if (depth == 0) {
                advance(p);
                if (is(p, T_DOT)) advance(p);
                if (is(p, T_KW_END)) advance(p);
                return;
            }
        } else if (is(p, T_NL) && depth == 0) {
            return; /* not a block form; fall back to line sync */
        }
        advance(p);
    }
}

/* ---- paths ---- */

/* IDENT (T_DOT IDENT)*  -> parts array */
/* ---- types ---- */

static Node *parse_expr(Parser *p); /* fwd: array literals contain exprs */

/* `type.<T>` / `type.array<T, N>` used by variable declarations (spec §8).
 * Returns false (with a diagnostic) on unknown types or malformed arrays. */
/* does the parser's struct registry contain this name? */
static bool parser_named_type_lookup_exists(Parser *p, const char *name);

static bool parse_type_prefix(Parser *p, OkType *out) {
    if (!expect(p, T_KW_TYPE, "`type`")) return false;
    if (!expect(p, T_DOT, "`.` after `type` (as in `type.number`)")) return false;
    Tok *name = cur(p);
    if (!is(p, T_IDENT)) {
        perr(p, name, "expected a type name after `type.` (number, decimal, text, bool, ptr<...>, array<...>), but found %s.",
             tok_kind_name(name->kind));
        return false;
    }
    advance(p);
    if (strcmp(name->text, "array") == 0) {
        /* type.array<type.number, 5> (spec §8.4) */
        if (!expect(p, T_LT, "`<` after `array` (as in `type.array<type.number, 5>`)"))
            return false;
        OkType elem;
        if (!parse_type_prefix(p, &elem)) return false;
        if (elem && elem == ty_auto) {
            perr(p, name, "array elements cannot use `type.auto` — write the element type explicitly.");
            return false;
        }
        if (!expect(p, T_COMMA, "`,` between the element type and the length")) return false;
        Tok *cnt = cur(p);
        if (!is(p, T_INT)) {
            perr(p, cnt, "the array length must be a whole number of elements, but found %s.",
                 tok_kind_name(cnt->kind));
            return false;
        }
        advance(p);
        if (!expect(p, T_GT, "`>` to close the array type")) return false;
        if (cnt->ival == 0 || cnt->ival > 65536) {
            Diag *d = perr(p, cnt, "the array length must be between 1 and 65536 in this compiler, but %llu was given.",
                           (unsigned long long)cnt->ival);
            diag_note(d, "the limit is a documented bootstrap restriction (spec §8.4); it lifts with the memory milestone.");
            return false;
        }
        OkType arr = ty_array(elem, (size_t)cnt->ival);
        if (!arr) {
            perr(p, cnt, "this array type is too large (more than 1 MiB of storage).");
            return false;
        }
        *out = arr;
        return true;
    }
    if (strcmp(name->text, "ptr") == 0) {
        /* type.ptr<type.number> (spec §12) */
        if (!expect(p, T_LT, "`<` after `ptr` (as in `type.ptr<type.number>`"))
            return false;
        OkType elem;
        if (!parse_type_prefix(p, &elem)) return false;
        if (elem && elem == ty_auto) {
            perr(p, name, "a pointer cannot use `type.auto` — write the pointee type explicitly.");
            return false;
        }
        if (!expect(p, T_GT, "`>` to close the pointer type")) return false;
        if (!elem || ty_kind(elem) == OK_VOID || ty_kind(elem) == OK_NULL) {
            perr(p, name, "a pointer needs a value type to point at (as in `type.ptr<type.number>`).");
            return false;
        }
        OkType pt = ty_ptr(elem);
        if (!pt) { perr(p, name, "this pointer type is too deep to intern."); return false; }
        *out = pt;
        return true;
    }
    if (!ty_from_scalar_name(name->text, out)) {
        /* named struct type? (spec §8.3) */
        if (parser_named_type_lookup_exists(p, name->text)) {
            *out = parser_named_type(p, name->text);
            return true;
        }
        Diag *d = perr(p, name, "unknown type `%s`.", name->text);
        diag_note(d, "the 0.7 types are: number, decimal, text, bool, int8, int16, int32, int64, uint8, uint16, uint32, uint64, byte, ptr<type>, array<type, count>, and names declared with `struct.Name = { ... }.end` or `union.Name = { ... }.end`.");
        diag_note(d, "`byte` is an alias of uint8; `int64` of number; `f64` of decimal.");
        return false;
    }
    return true;
}

/* does the parser's struct registry contain this name? */
static bool parser_named_type_lookup_exists(Parser *p, const char *name) {
    (void)p;
    size_t h = 0;
    for (const char *c = name; *c; c++) h = h * 31u + (size_t)*c;
    h &= 63;
    for (NamedTypeEntry *e = named_types[h]; e; e = e->next)
        if (strcmp(e->name, name) == 0) return true;
    return false;
}

/* bare type name for function params / return types (`number.a`, `-> number`);
 * also accepts the full `type.`-prefixed form, which arrays require:
 *   type.array<type.number, 3>.xs      (spec §8.4) */
static bool parse_bare_type(Parser *p, OkType *out) {
    if (is(p, T_KW_TYPE))
        return parse_type_prefix(p, out);
    Tok *name = cur(p);
    if (!is(p, T_IDENT)) {
        perr(p, name, "expected a type name (number, decimal, text, bool), but found %s.",
             tok_kind_name(name->kind));
        return false;
    }
    advance(p);
    /* bare pointer form: ptr<number>.p (the full form type.ptr<type.number>.p
     * also works through the T_KW_TYPE branch above) */
    if (strcmp(name->text, "ptr") == 0 && is(p, T_LT)) {
        advance(p); /* < */
        OkType elem;
        if (!parse_bare_type(p, &elem)) return false;
        if (!expect(p, T_GT, "`>` to close the pointer type")) return false;
        if (!elem || ty_kind(elem) == OK_VOID || ty_kind(elem) == OK_NULL) {
            perr(p, name, "a pointer needs a value type to point at (as in `ptr<number>`).");
            return false;
        }
        *out = ty_ptr(elem);
        return *out != NULL;
    }
    if (!ty_from_scalar_name(name->text, out)) {
        /* named struct type? (spec §8.3) */
        if (parser_named_type_lookup_exists(p, name->text)) {
            *out = parser_named_type(p, name->text);
            return true;
        }
        Diag *d = perr(p, name, "unknown type `%s`.", name->text);
        diag_note(d, "the 0.7 types are: number, decimal, text, bool, int8, int16, int32, int64, uint8, uint16, uint32, uint64, byte, ptr<type>, array<type, count>, and names declared with `struct.Name = { ... }.end` or `union.Name = { ... }.end`.");
        diag_note(d, "array parameters use the full form: `type.array<type.number, 3>.xs`.");
        return false;
    }
    return true;
}

/* { e1, e2, ... } array literal (declaration initializers only, spec §8.4) */
static Node *parse_arraylit(Parser *p) {
    Tok *t = cur(p);
    Node *n = node_new(p->ar, A_ARRAYLIT, t->line, t->col);
    advance(p); /* { */
    vec_init(&n->args);
    for (;;) {
        skip_nl(p);
        if (is(p, T_RBRACE)) { advance(p); return n; }
        Node *el = is(p, T_LBRACE) ? parse_arraylit(p) : parse_expr(p);
        if (!el) return n;
        vec_push(&n->args, el);
        skip_nl(p);
        if (is(p, T_COMMA)) { advance(p); continue; }
        if (is(p, T_RBRACE)) { advance(p); return n; }
        perr(p, cur(p), "expected `,` or `}` in the array literal, but found %s.",
             tok_kind_name(cur(p)->kind));
        return n;
    }
}

/* initializer after `=` in a declaration: array literal or expression */
static Node *parse_initializer(Parser *p) {
    if (is(p, T_LBRACE)) return parse_arraylit(p);
    return parse_expr(p);
}

/* ---- expressions (spec §9 precedence) ---- */

static Node *parse_expr(Parser *p);

static Node *parse_primary(Parser *p) {
    Tok *t = cur(p);
    switch (t->kind) {
    case T_INT: {
        Node *n = node_new(p->ar, A_INT, t->line, t->col);
        n->spell = ok_xstrndup(p->f->data + t->off, t->len);
        n->ival = t->ival;
        advance(p);
        return n;
    }
    case T_DEC: {
        Node *n = node_new(p->ar, A_DEC, t->line, t->col);
        n->spell = ok_xstrndup(p->f->data + t->off, t->len);
        n->dval = t->dval;
        advance(p);
        return n;
    }
    case T_TEXT: {
        Node *n = node_new(p->ar, A_TEXT, t->line, t->col);
        n->spell = ok_xstrndup(p->f->data + t->off, t->len);
        n->str = ok_xstrdup(t->text);
        n->str_len = t->slen;
        advance(p);
        return n;
    }
    case T_KW_TRUE:
    case T_KW_FALSE: {
        Node *n = node_new(p->ar, A_BOOL, t->line, t->col);
        n->bval = t->kind == T_KW_TRUE;
        advance(p);
        return n;
    }
    case T_LPAREN: {
        advance(p);
        Node *e = parse_expr(p);
        if (!e) return NULL;
        if (!expect(p, T_RPAREN, "`)` to close the parenthesized expression"))
            return NULL;
        return e;
    }
    case T_KW_NULL: {
        /* the null pointer literal (spec §12) */
        Node *n = node_new(p->ar, A_NULL, t->line, t->col);
        advance(p);
        return n;
    }
    case T_KW_ALLOC: {
        /* alloc<type.T>(count) — manual heap allocation (spec §12) */
        Node *n = node_new(p->ar, A_ALLOC, t->line, t->col);
        advance(p);
        if (!expect(p, T_LT, "`<` after `alloc` (as in `alloc<type.number>(1)`"))
            { sync_stmt(p); return NULL; }
        OkType elem;
        if (!parse_type_prefix(p, &elem)) { sync_stmt(p); return NULL; }
        if (!expect(p, T_GT, "`>` to close the allocated type")) { sync_stmt(p); return NULL; }
        if (!elem || ty_kind(elem) == OK_VOID || ty_kind(elem) == OK_NULL) {
            perr(p, t, "`alloc` needs a value type (as in `alloc<type.number>(1)`).");
            sync_stmt(p);
            return NULL;
        }
        OkType pt = ty_ptr(elem);
        if (!pt) { perr(p, t, "this allocated type is too deep to intern."); sync_stmt(p); return NULL; }
        n->otype = pt;
        if (!expect(p, T_LPAREN, "`(` after the allocated type")) { sync_stmt(p); return NULL; }
        n->a = parse_expr(p);
        if (!n->a) { sync_stmt(p); return NULL; }
        if (!expect(p, T_RPAREN, "`)` to close the allocation")) { sync_stmt(p); return NULL; }
        return n;
    }
    case T_KW_WRITE:
        perr(p, t, "`write(...)` is a statement, not a value — it returns nothing.");
        advance(p);
        return NULL;
    case T_KW_PRINT:
        perr(p, t, "`print` is a statement, not a value.");
        advance(p);
        return NULL;
    case T_KW_RESERVED:
        perr(p, t, "`%s` is reserved for a future Okular feature and is not available in 0.2 (specs/spec-v0.2.md §20).", t->text);
        advance(p);
        return NULL;
    case T_IDENT: {
        Node *n = node_new(p->ar, A_PATH, t->line, t->col);
        Vec parts; vec_init(&parts);
        vec_push(&parts, ok_xstrdup(t->text));
        advance(p);
        while (is(p, T_DOT) && is_path_part(at(p, 1)->kind)) {
            advance(p);
            vec_push(&parts, path_part_text(cur(p)));
            advance(p);
        }
        n->parts = (char **)parts.items;
        n->nparts = parts.len;
        return n;
    }
    default:
        perr(p, t, "expected an expression, but found %s.", tok_kind_name(t->kind));
        return NULL;
    }
}

static Node *parse_call_args(Parser *p) {
    /* at '(' — parse ( args ) into a fresh Vec on the arena */
    Node *holder = node_new(p->ar, A_EXPRSTMT, cur(p)->line, cur(p)->col);
    advance(p); /* ( */
    vec_init(&holder->args);
    skip_nl(p);
    if (is(p, T_RPAREN)) { advance(p); return holder; }
    for (;;) {
        skip_nl(p);
        Node *a = parse_expr(p);
        if (!a) return NULL;
        vec_push(&holder->args, a);
        skip_nl(p);
        if (is(p, T_COMMA)) { advance(p); continue; }
        if (is(p, T_RPAREN)) { advance(p); return holder; }
        perr(p, cur(p), "expected `,` or `)` in the argument list, but found %s.",
             tok_kind_name(cur(p)->kind));
        return NULL;
    }
}

static Node *parse_postfix(Parser *p) {
    Node *e = parse_primary(p);
    if (!e) return NULL;
    if (e->kind == A_PATH && is(p, T_LPAREN)) {
        Node *args = parse_call_args(p);
        if (!args) return NULL;
        Node *call = node_new(p->ar, A_CALL, e->line, e->col);
        call->parts = e->parts;
        call->nparts = e->nparts;
        call->args = args->args;
        e = call;
    }
    /* postfix chains: indexing and member access mix freely
     * (grid[i][j], pkt.array[2].x, cell.pos.x — spec §9/§8.3) */
    for (;;) {
        if (is(p, T_LBRACKET)) {
            Tok *t = cur(p);
            advance(p); /* [ */
            Node *idx = parse_expr(p);
            if (!idx) return e;
            if (!expect(p, T_RBRACKET, "`]` to close the array index")) return e;
            Node *ix = node_new(p->ar, A_INDEX, t->line, t->col);
            ix->a = e;
            ix->b = idx;
            e = ix;
            continue;
        }
        if (is(p, T_DOT) && is_path_part(at(p, 1)->kind)) {
            /* member access on a computed base: base.field (spec §8.3).
             * Dotted paths (a.b) stay A_PATH — only postfix bases land here */
            Tok *t = cur(p);
            advance(p); /* . */
            Node *mem = node_new(p->ar, A_MEMBER, t->line, t->col);
            mem->a = e;
            mem->name = path_part_text(cur(p));
            advance(p);
            e = mem;
            continue;
        }
        if (is(p, T_DOT)) {
            perr(p, cur(p), "`.` starts member access (`value.field`), but found %s after it.",
                 tok_kind_name(at(p, 1)->kind));
            sync_stmt(p);
            return e;
        }
        break;
    }
    return e;
}

static Node *parse_unary(Parser *p) {
    if (is(p, T_MINUS)) {
        Tok *t = cur(p); advance(p);
        Node *e = parse_unary(p);
        if (!e) return NULL;
        Node *n = node_new(p->ar, A_UN, t->line, t->col);
        n->uop = UN_NEG; n->a = e;
        return n;
    }
    if (is(p, T_KW_NOT)) {
        Tok *t = cur(p); advance(p);
        Node *e = parse_unary(p);
        if (!e) return NULL;
        Node *n = node_new(p->ar, A_UN, t->line, t->col);
        n->uop = UN_NOT; n->a = e;
        return n;
    }
    if (is(p, T_AMP)) {
        /* &x — address-of (spec §12) */
        Tok *t = cur(p); advance(p);
        Node *e = parse_unary(p);
        if (!e) return NULL;
        Node *n = node_new(p->ar, A_UN, t->line, t->col);
        n->uop = UN_ADDR; n->a = e;
        return n;
    }
    if (is(p, T_TILDE)) {
        /* ~x — bitwise NOT (0.11, spec §9); integer types only */
        Tok *t = cur(p); advance(p);
        Node *e = parse_unary(p);
        if (!e) return NULL;
        Node *n = node_new(p->ar, A_UN, t->line, t->col);
        n->uop = UN_BNOT; n->a = e;
        return n;
    }
    if (is(p, T_STAR)) {
        /* *p — dereference (spec §12); in prefix position `*` is never
         * multiplication (binary `*` always follows its left operand) */
        Tok *t = cur(p); advance(p);
        Node *e = parse_unary(p);
        if (!e) return NULL;
        Node *n = node_new(p->ar, A_UN, t->line, t->col);
        n->uop = UN_DEREF; n->a = e;
        return n;
    }
    return parse_postfix(p);
}

static Node *mkbin(Parser *p, BinOp op, Node *l, Node *r) {
    Node *n = node_new(p->ar, A_BIN, l->line, l->col);
    n->op = op; n->a = l; n->b = r;
    return n;
}

static Node *parse_mul(Parser *p) {
    Node *e = parse_unary(p);
    if (!e) return NULL;
    for (;;) {
        BinOp op;
        if (is(p, T_STAR)) op = OP_MUL;
        else if (is(p, T_SLASH)) op = OP_DIV;
        else if (is(p, T_PERCENT)) op = OP_MOD;
        else return e;
        advance(p);
        Node *r = parse_unary(p);
        if (!r) return NULL;
        e = mkbin(p, op, e, r);
    }
}

static Node *parse_add(Parser *p) {
    Node *e = parse_mul(p);
    if (!e) return NULL;
    for (;;) {
        BinOp op;
        if (is(p, T_PLUS)) op = OP_ADD;
        else if (is(p, T_MINUS)) op = OP_SUB;
        else return e;
        advance(p);
        Node *r = parse_mul(p);
        if (!r) return NULL;
        e = mkbin(p, op, e, r);
    }
}

/* shifts (0.11, spec §9): looser than `+`/`-` (like C and Rust —
 * `1 << 2 + 3` shifts by 5), tighter than `&`. The count may be any
 * integer type; sema checks its range at compile time / runtime. */
static Node *parse_shift(Parser *p) {
    Node *e = parse_add(p);
    if (!e) return NULL;
    for (;;) {
        BinOp op;
        if (is(p, T_SHL)) op = OP_SHL;
        else if (is(p, T_SHR)) op = OP_SHR;
        else return e;
        advance(p);
        Node *r = parse_add(p);
        if (!r) return NULL;
        e = mkbin(p, op, e, r);
    }
}

static Node *parse_band(Parser *p) {
    Node *e = parse_shift(p);
    if (!e) return NULL;
    while (is(p, T_AMP)) {   /* infix `&`: prefix `&` is address-of (§12) */
        advance(p);
        Node *r = parse_shift(p);
        if (!r) return NULL;
        e = mkbin(p, OP_BAND, e, r);
    }
    return e;
}

static Node *parse_bxor(Parser *p) {
    Node *e = parse_band(p);
    if (!e) return NULL;
    while (is(p, T_CARET)) {
        advance(p);
        Node *r = parse_band(p);
        if (!r) return NULL;
        e = mkbin(p, OP_XOR, e, r);
    }
    return e;
}

static Node *parse_bor(Parser *p) {
    Node *e = parse_bxor(p);
    if (!e) return NULL;
    while (is(p, T_PIPE)) {
        advance(p);
        Node *r = parse_bxor(p);
        if (!r) return NULL;
        e = mkbin(p, OP_BOR, e, r);
    }
    return e;
}

static Node *parse_cmp(Parser *p) {
    Node *e = parse_bor(p);
    if (!e) return NULL;
    BinOp op;
    switch (cur(p)->kind) {
    case T_EQEQ: op = OP_EQ; break;
    case T_BANGEQ: op = OP_NEQ; break;
    case T_LT: op = OP_LT; break;
    case T_LE: op = OP_LE; break;
    case T_GT: op = OP_GT; break;
    case T_GE: op = OP_GE; break;
    default: return e;
    }
    advance(p);
    Node *r = parse_add(p);
    if (!r) return NULL;
    Node *n = mkbin(p, op, e, r);
    /* comparisons are non-associative (spec §9) */
    if (cur(p)->kind == T_EQEQ || cur(p)->kind == T_BANGEQ ||
        cur(p)->kind == T_LT || cur(p)->kind == T_LE ||
        cur(p)->kind == T_GT || cur(p)->kind == T_GE) {
        perr(p, cur(p), "comparisons do not chain in Okular (use `and` to combine them).");
    }
    return n;
}

static Node *parse_and(Parser *p) {
    Node *e = parse_cmp(p);
    if (!e) return NULL;
    while (is(p, T_KW_AND)) {
        advance(p);
        Node *r = parse_cmp(p);
        if (!r) return NULL;
        e = mkbin(p, OP_AND, e, r);
    }
    return e;
}

static Node *parse_expr(Parser *p) {
    Node *e = parse_and(p);
    if (!e) return NULL;
    while (is(p, T_KW_OR)) {
        advance(p);
        Node *r = parse_and(p);
        if (!r) return NULL;
        e = mkbin(p, OP_OR, e, r);
    }
    return e;
}

/* ---- statements ---- */

static bool parse_stmt_list(Parser *p, Vec *out, TokKind close);

/* `when (cond) { } else { }` (spec §10) */
static Node *parse_when(Parser *p) {
    Tok *t = cur(p); advance(p);
    Node *n = node_new(p->ar, A_WHEN, t->line, t->col);
    if (!expect(p, T_LPAREN, "`(` after `when`")) { sync_stmt(p); return n; }
    n->a = parse_expr(p);
    if (!n->a) { return n; }
    if (!expect(p, T_RPAREN, "`)` after the `when` condition")) { sync_stmt(p); return n; }
    vec_init(&n->body);
    if (!parse_stmt_list(p, &n->body, T_RBRACE)) return n;
    /* `else` may sit on the next line — peek past newlines, but restore the
     * position when there is no `else`, so the caller still sees its own
     * statement separator (top-level loops demand the newline stays). */
    size_t mark = p->pos;
    skip_nl(p);
    if (is(p, T_KW_ELSE)) {
        advance(p);
        if (is(p, T_KW_WHEN)) {
            /* `else when (...) { ... }` chain (spec §10): the nested when
             * statement IS this branch's body; it may chain onward itself */
            Node *nested = parse_when(p);
            if (!nested) return n;
            vec_init(&n->body_else);
            vec_push(&n->body_else, nested);
            return n;
        }
        vec_init(&n->body_else);
        if (!parse_stmt_list(p, &n->body_else, T_RBRACE)) return n;
    } else {
        p->pos = mark;
    }
    return n;
}

/* `loop (...) { }` — counted or conditional (spec §10) */
static Node *parse_loop(Parser *p) {
    Tok *t = cur(p); advance(p);
    if (!expect(p, T_LPAREN, "`(` after `loop`")) { sync_stmt(p); return node_new(p->ar, A_LOOP_COND, t->line, t->col); }

    if (is(p, T_IDENT) && isk(p, 1, T_KW_FROM)) {
        Node *n = node_new(p->ar, A_LOOP_COUNT, t->line, t->col);
        n->name = ok_xstrdup(cur(p)->text);
        advance(p); /* ident */
        advance(p); /* from */
        n->a = parse_expr(p);
        if (!n->a) return n;
        bool inclusive;
        if (is(p, T_KW_TO)) inclusive = true;
        else if (is(p, T_KW_UNTIL)) inclusive = false;
        else {
            perr(p, cur(p), "expected `to` (inclusive) or `until` (exclusive) in the counted loop, but found %s.",
                 tok_kind_name(cur(p)->kind));
            sync_stmt(p);
            return n;
        }
        n->inclusive = inclusive;
        advance(p);
        n->b = parse_expr(p);
        if (!n->b) return n;
        if (!expect(p, T_RPAREN, "`)` to close the loop head")) { sync_stmt(p); return n; }
        vec_init(&n->body);
        parse_stmt_list(p, &n->body, T_RBRACE);
        return n;
    }

    Node *n = node_new(p->ar, A_LOOP_COND, t->line, t->col);
    n->a = parse_expr(p);
    if (!n->a) return n;
    if (!expect(p, T_RPAREN, "`)` after the loop condition")) { sync_stmt(p); return n; }
    vec_init(&n->body);
    parse_stmt_list(p, &n->body, T_RBRACE);
    return n;
}

/* write(...) statement */
static Node *parse_write(Parser *p) {
    Tok *t = cur(p); advance(p);
    Node *n = node_new(p->ar, A_WRITE, t->line, t->col);
    if (!is(p, T_LPAREN)) {
        perr(p, cur(p), "`write` needs parentheses: `write(value)`.");
        sync_stmt(p);
        return n;
    }
    Node *args = parse_call_args(p);
    if (!args) return n;
    n->args = args->args;
    return n;
}

/* A statement or declaration; NOT function/column (those are top-level). */
static Node *parse_stmt(Parser *p) {
    Tok *t = cur(p);
    switch (t->kind) {
    case T_KW_TYPE: {
        /* `type.<feature>=v` is file-level only (spec §5); here it must be
         * a variable declaration `type.<T> name = init`. */
        if (isk(p, 1, T_DOT) && isk(p, 2, T_IDENT) && isk(p, 3, T_EQ)) {
            perr(p, t, "feature directives like `type.%s=%d` are file-level; move them to the top of the file.",
                 at(p, 2)->text, 0);
            /* parse it anyway so recovery is clean */
        }
        OkType ty;
        if (!parse_type_prefix(p, &ty)) { sync_stmt(p); return NULL; }
        if (!is(p, T_IDENT)) {
            perr(p, cur(p), "expected a variable name after `type.%s`, but found %s.",
                 ok_type_name(ty), tok_kind_name(cur(p)->kind));
            sync_stmt(p);
            return NULL;
        }
        Node *n = node_new(p->ar, A_VARDECL, t->line, t->col);
        n->otype = ty;
        n->name = ok_xstrdup(cur(p)->text);
        advance(p);
        if (!expect(p, T_EQ, "`=` and an initializer (Okular requires explicit initialization)")) {
            free(n->name);
            return NULL;
        }
        n->a = parse_initializer(p);
        if (!n->a) { free(n->name); return NULL; }
        return n;
    }
    case T_KW_WHEN:    return parse_when(p);
    case T_KW_LOOP:    return parse_loop(p);
    case T_KW_WRITE:   return parse_write(p);
    case T_KW_PRINT: {
        Node *n = node_new(p->ar, A_PRINT, t->line, t->col);
        advance(p);
        return n;
    }
    case T_KW_RELEASE: {
        /* release(p) — return a heap block (spec §12) */
        Node *n = node_new(p->ar, A_RELEASE, t->line, t->col);
        advance(p);
        if (!expect(p, T_LPAREN, "`(` after `release`")) { sync_stmt(p); return n; }
        n->a = parse_expr(p);
        if (!n->a) { sync_stmt(p); return n; }
        if (!expect(p, T_RPAREN, "`)` to close `release(...)`")) { sync_stmt(p); return n; }
        return n;
    }
    case T_STAR: {
        /* *p = value — dereference assignment (spec §12) */
        Node *e = parse_unary(p);
        if (!e) return NULL;
        if (is(p, T_EQ)) {
            advance(p);
            Node *val = parse_expr(p);
            if (!val) return NULL;
            if (e->kind == A_UN && e->uop == UN_DEREF) {
                Node *n = node_new(p->ar, A_DEREFASSIGN, t->line, t->col);
                n->a = e->a;
                n->c = val;
                return n;
            }
            Diag *d = perr(p, t, "the left side of `=` must be a name, an array element, or a dereference.");
            diag_note(d, "pointer stores use `*p = value` or `p[index] = value`.");
            return NULL;
        }
        Diag *d = perr(p, t, "a statement that starts with `*` must be a pointer store (`*p = value`).");
        (void)d;
        sync_stmt(p);
        return NULL;
    }
    case T_KW_BREAK: {
        Node *n = node_new(p->ar, A_BREAK, t->line, t->col);
        advance(p);
        return n;
    }
    case T_KW_CONTINUE: {
        Node *n = node_new(p->ar, A_CONTINUE, t->line, t->col);
        advance(p);
        return n;
    }
    case T_KW_RETURN: {
        Node *n = node_new(p->ar, A_RETURN, t->line, t->col);
        advance(p);
        /* bare `return` when the line ends; otherwise parse the value.
         * Do NOT consume the newline — the statement-list loop needs it. */
        if (!is(p, T_NL) && !is(p, T_RBRACE) && !is(p, T_EOF)) {
            n->a = parse_expr(p);
        }
        return n;
    }
    case T_KW_STRUCT: case T_KW_UNION: {
        /* record declarations are top level or column members (spec §8.3/§8.5) */
        Diag *d = perr(p, t, "structs and unions are declared at the top of a file or inside a column (`struct.Name = { ... }.end` / `union.Name = { ... }.end`), not inside function bodies.");
        (void)d;
        advance(p);
        skip_column_region(p);
        return NULL;
    }
    case T_KW_CONST: {
        Diag *d = perr(p, t, "constants are declared at the top of a file or inside a column (`const.limit = 100`), not inside function bodies.");
        (void)d;
        advance(p);
        sync_stmt(p);
        return NULL;
    }
    case T_KW_RESERVED:
        perr(p, t, "`%s` is reserved for a future Okular feature and is not available in 0.7 (specs/spec-v0.7.md §20).", t->text);
        advance(p);
        sync_stmt(p);
        return NULL;
    case T_IDENT: {
        /* assignment (path = expr, base[i] = expr) or call statement */
        Node *e = parse_postfix(p);
        if (!e) return NULL;
        if (is(p, T_EQ)) {
            advance(p);
            Node *val = parse_expr(p);
            if (!val) return NULL;
            if (e->kind == A_PATH) {
                Node *n = node_new(p->ar, A_ASSIGN, t->line, t->col);
                n->parts = e->parts; n->nparts = e->nparts;
                n->a = val;
                return n;
            }
            if (e->kind == A_INDEX) {
                /* base[i] = value  (m[i][j] = v nests: e->a is the inner index) */
                Node *n = node_new(p->ar, A_INDEXASSIGN, t->line, t->col);
                n->a = e->a;
                n->b = e->b;
                n->c = val;
                return n;
            }
            if (e->kind == A_MEMBER) {
                /* base.field = value (spec §8.3) */
                Node *n = node_new(p->ar, A_FIELDASSIGN, t->line, t->col);
                n->a = e->a;
                n->name = e->name;
                n->c = val;
                return n;
            }
            Diag *d = perr(p, t, "the left side of `=` must be a name or an array element, not this expression.");
            diag_note(d, "to store a value use `name = value` or `array[index] = value`.");
            return NULL;
        }
        if (e->kind == A_CALL) {
            Node *n = node_new(p->ar, A_EXPRSTMT, t->line, t->col);
            n->a = e;
            return n;
        }
        Diag *d = perr(p, cur(p), "a statement that starts with a name must be a call or an assignment.");
        diag_note(d, "expression statements must be calls like `greeting.greet()`; to store a value use `name = value` or `array[index] = value`.");
        sync_stmt(p);
        return NULL;
    }
    default:
        perr(p, t, "expected a statement, but found %s.", tok_kind_name(t->kind));
        advance(p);
        sync_stmt(p);
        return NULL;
    }
}

/* Parse `{ stmts }` until the close token (T_RBRACE). Returns false on hard
 * failure; recovers at statement boundaries otherwise. */
static bool parse_stmt_list(Parser *p, Vec *out, TokKind close) {
    vec_init(out);
    if (!expect(p, T_LBRACE, "`{` to open the block")) {
        sync_stmt(p);
        return false;
    }
    for (;;) {
        skip_nl(p);
        if (is(p, T_EOF)) {
            perr(p, cur(p), "the block starting earlier is never closed (missing `}`).");
            return false;
        }
        if (is(p, T_RBRACE)) { advance(p); return true; }
        if (is(p, T_DOT) && isk(p, 1, T_KW_END)) {
            perr(p, cur(p), "`.end` closes columns, not blocks — use `}` here (spec §3.1).");
            advance(p); advance(p);
            continue;
        }
        size_t before = p->pos;
        Node *s = parse_stmt(p);
        if (s) vec_push(out, s);
        if (p->pos == before) advance(p); /* guarantee progress */
    }
}

/* ---- top level ---- */

/* [path] = { "items" }.end — language column (spec §3.2) */
static Node *parse_langcol(Parser *p) {
    Tok *t = cur(p);
    advance(p); /* [ */
    Vec parts; vec_init(&parts);
    if (!is(p, T_IDENT)) {
        perr(p, cur(p), "expected a language column name like `libs.use` after `[`.");
        /* skip to ].end */
        while (!is(p, T_EOF) && !is(p, T_RBRACKET)) advance(p);
        if (is(p, T_RBRACKET)) advance(p);
        return NULL;
    }
    vec_push(&parts, ok_xstrdup(cur(p)->text));
    advance(p);
    while (is(p, T_DOT) && isk(p, 1, T_IDENT)) {
        advance(p);
        vec_push(&parts, ok_xstrdup(cur(p)->text));
        advance(p);
    }
    if (!expect(p, T_RBRACKET, "`]` to close the column name")) {
        for (size_t i = 0; i < parts.len; i++) free(parts.items[i]);
        free(parts.items);
        sync_stmt(p);
        return NULL;
    }
    if (!expect(p, T_EQ, "`=` before the column body `{`")) {
        for (size_t i = 0; i < parts.len; i++) free(parts.items[i]);
        free(parts.items);
        sync_stmt(p);
        return NULL;
    }

    Node *n = node_new(p->ar, A_LANGCOL, t->line, t->col);
    n->parts = (char **)parts.items;
    n->nparts = parts.len;

    if (!expect(p, T_LBRACE, "`{` to open the column body")) { sync_stmt(p); return n; }
    vec_init(&n->items);
    skip_nl(p);
    if (is(p, T_RBRACE)) { advance(p); expect_end(p); return n; }
    for (;;) {
        skip_nl(p);
        if (is(p, T_TEXT)) {
            svec_push((StrVec *)&n->items, ok_xstrdup(cur(p)->text));
            svec_push((StrVec *)&n->items_spell,
                      ok_xstrndup(p->f->data + cur(p)->off, cur(p)->len));
            advance(p);
            skip_nl(p);
            if (is(p, T_COMMA)) { advance(p); continue; }
            if (is(p, T_RBRACE)) { advance(p); break; }
            perr(p, cur(p), "expected `,` or `}` in the column list, but found %s.",
                 tok_kind_name(cur(p)->kind));
            break;
        }
        perr(p, cur(p), "language columns list text names (\"math\"), but found %s.",
             tok_kind_name(cur(p)->kind));
        break;
    }
    expect_end(p);
    return n;
}

/* `struct.Name = { type.T field ... }.end` / `union.Name = { ... }.end` —
 * member declarations without initializers (spec §8.3/§8.5). Fields ride
 * in the node's Param array. The two share one grammar; only the keyword,
 * node kind, and wording differ. */
static Node *parse_recorddecl(Parser *p, bool is_union) {
    Tok *t = cur(p);
    const char *kw = is_union ? "union" : "struct";
    char what_dot[64], what_eq[64], what_brace[64];
    snprintf(what_dot, sizeof what_dot, "`.` after `%s` (as in `%s.Packet`)", kw, kw);
    snprintf(what_eq, sizeof what_eq, "`=` before the %s body `{`", kw);
    snprintf(what_brace, sizeof what_brace, "`{` to open the %s body", kw);
    advance(p); /* struct / union */
    if (!expect(p, T_DOT, what_dot)) {
        skip_column_region(p);
        return NULL;
    }
    Tok *name = cur(p);
    if (!is(p, T_IDENT)) {
        perr(p, name, "expected a %s name after `%s.` (as in `%s.Packet`), but found %s.",
             kw, kw, kw, tok_kind_name(name->kind));
        skip_column_region(p);
        return NULL;
    }
    advance(p);
    Node *n = node_new(p->ar, is_union ? A_UNIONDECL : A_STRUCTDECL, t->line, t->col);
    n->name = ok_xstrdup(name->text);
    n->otype = parser_named_type(p, name->text); /* the shared placeholder */

    if (!expect(p, T_EQ, what_eq)) { skip_column_region(p); return n; }
    if (!expect(p, T_LBRACE, what_brace)) { skip_column_region(p); return n; }

    Vec fv; vec_init(&fv);
    for (;;) {
        skip_nl(p);
        if (is(p, T_EOF)) {
            perr(p, cur(p), "%s `%s` is never closed (missing `}.end`).", kw, n->name);
            return n;
        }
        if (is(p, T_RBRACE)) { advance(p); break; }
        if (is(p, T_DOT) && isk(p, 1, T_KW_END)) {
            perr(p, cur(p), "`.end` completes `}` — write `}.end` to close the %s.", kw);
            break;
        }
        OkType fty;
        if (!parse_type_prefix(p, &fty)) { sync_stmt(p); continue; }
        if (fty == ty_auto) {
            perr(p, cur(p), "%s members cannot use `type.auto` — write the member type explicitly.", kw);
            sync_stmt(p);
            continue;
        }
        if (!is(p, T_IDENT)) {
            perr(p, cur(p), "expected a member name in %s `%s`, but found %s.",
                 kw, n->name, tok_kind_name(cur(p)->kind));
            sync_stmt(p);
            continue;
        }
        Param *pa = ok_xmalloc(sizeof *pa);
        pa->name = ok_xstrdup(cur(p)->text);
        pa->type = fty;
        advance(p);  /* consume the field name */
        if (is(p, T_EQ)) {
            Diag *d = perr(p, cur(p), "%s members have no initializers — construct with a literal (`type.%s v = { ... }`) and set fields by assignment.", kw, n->name);
            (void)d;
            free(pa->name);
            free(pa);
            sync_stmt(p);
            continue;
        }
        vec_push(&fv, pa);
    }
    if (!expect_end(p)) {
        /* `.end` missing: recover to the next statement boundary */
    }

    n->params = ok_xmalloc((fv.len ? fv.len : 1) * sizeof(Param));
    n->nparams = fv.len;
    for (size_t i = 0; i < fv.len; i++) {
        Param *pa = (Param *)fv.items[i];
        n->params[i] = *pa;
        free(pa);
    }
    free(fv.items);
    return n;
}

/* `const.name = expr` — a folded, module-scope constant (0.8, spec §8.1).
 * Single line, like variable declarations. The value must fold at
 * compile time; sema enforces and stores the folded ConstVal. */
static Node *parse_constdecl(Parser *p) {
    Tok *t = cur(p);
    advance(p); /* const */
    if (!expect(p, T_DOT, "`.` after `const` (as in `const.limit`)")) {
        sync_stmt(p);
        return NULL;
    }
    Tok *name = cur(p);
    if (!is(p, T_IDENT)) {
        perr(p, name, "expected a constant name after `const.` (as in `const.limit`), but found %s.",
             tok_kind_name(name->kind));
        sync_stmt(p);
        return NULL;
    }
    advance(p);
    Node *n = node_new(p->ar, A_CONSTDECL, t->line, t->col);
    n->name = ok_xstrdup(name->text);
    if (!expect(p, T_EQ, "`=` and a constant value")) { free(n->name); sync_stmt(p); return NULL; }
    if (is(p, T_LBRACE)) {
        perr(p, cur(p), "constants are single scalar or text values — `{ ... }` literals initialize variables, not constants.");
        sync_stmt(p);
        return n;
    }
    n->a = parse_expr(p);
    if (!n->a) { free(n->name); return NULL; }
    return n;
}

/* `function.<name>(...)` shared by top level and columns */
static Node *parse_toplevel_function(Parser *p);

static Node *parse_devcol(Parser *p) {
    Tok *t = cur(p);
    Node *n = node_new(p->ar, A_DEVCOL, t->line, t->col);
    n->name = ok_xstrdup(cur(p)->text);
    advance(p); /* name */
    advance(p); /* = */
    if (!expect(p, T_LBRACE, "`{` to open the column body")) { sync_stmt(p); return n; }
    vec_init(&n->body);
    for (;;) {
        skip_nl(p);
        if (is(p, T_EOF)) {
            perr(p, cur(p), "column `%s` is never closed (missing `}.end`).", n->name);
            return n;
        }
        if (is(p, T_RBRACE)) {
            advance(p);
            expect_end(p);
            return n;
        }
        size_t before = p->pos;
        Node *m = NULL;
        if (is(p, T_KW_TYPE) && isk(p, 1, T_DOT) && isk(p, 2, T_IDENT) && isk(p, 3, T_EQ)) {
            perr(p, cur(p), "feature directives are file-level; move `type.%s=...` out of column `%s`.",
                 at(p, 2)->text, n->name);
            advance(p); advance(p); advance(p); advance(p); /* type.x= */
            sync_stmt(p);
            continue;
        }
        if (is(p, T_KW_TYPE)) {
            OkType ty;
            if (!parse_type_prefix(p, &ty)) { sync_stmt(p); continue; }
            if (!is(p, T_IDENT)) {
                perr(p, cur(p), "expected a member name in column `%s`, but found %s.",
                     n->name, tok_kind_name(cur(p)->kind));
                sync_stmt(p);
                continue;
            }
            Node *v = node_new(p->ar, A_VARDECL, t->line, t->col);
            v->otype = ty;
            v->name = ok_xstrdup(cur(p)->text);
            advance(p);
            if (!expect(p, T_EQ, "`=` and an initializer")) { free(v->name); continue; }
            v->a = parse_initializer(p);
            if (v->a) vec_push(&n->body, v);
            continue;
        }
        if (is(p, T_KW_FUNCTION)) {
            m = parse_toplevel_function(p);   /* forward use; defined below */
            if (m) vec_push(&n->body, m);
            continue;
        }
        if (is(p, T_KW_STRUCT)) {
            m = parse_recorddecl(p, false);
            if (m) vec_push(&n->body, m);
            continue;
        }
        if (is(p, T_KW_UNION)) {
            m = parse_recorddecl(p, true);
            if (m) vec_push(&n->body, m);
            continue;
        }
        if (is(p, T_KW_CONST)) {
            m = parse_constdecl(p);
            if (m) vec_push(&n->body, m);
            continue;
        }
        if (is(p, T_IDENT) && isk(p, 1, T_EQ) && isk(p, 2, T_LBRACE)) {
            m = parse_devcol(p);
            if (m) vec_push(&n->body, m);
            continue;
        }
        {
            TokKind k = cur(p)->kind;
            Diag *d = perr(p, cur(p), "columns contain declarations (variables, functions, nested columns), but found %s.",
                 tok_kind_name(k));
            if (k == T_INT || k == T_DEC || k == T_TEXT || k == T_KW_TRUE || k == T_KW_FALSE)
                diag_note(d, "this looks like an array literal — literals only initialize declarations: `type.array<type.number, 2> xs = {1, 2}` (spec §8.4).");
        }
        sync_stmt(p);
        if (p->pos == before) advance(p);
    }
}

/* ---- file ---- */

static Node *parse_toplevel_function(Parser *p) {
    Tok *t = cur(p);
    advance(p); /* function */
    if (!expect(p, T_DOT, "`.` after `function` (as in `function.add`)")) { sync_stmt(p); return NULL; }
    if (!is(p, T_IDENT)) {
        perr(p, cur(p), "expected a function name after `function.`, but found %s.",
             tok_kind_name(cur(p)->kind));
        sync_stmt(p);
        return NULL;
    }
    Node *n = node_new(p->ar, A_FUNC, t->line, t->col);
    n->name = ok_xstrdup(cur(p)->text);
    advance(p);

    /* parameters */
    if (!expect(p, T_LPAREN, "`(` to open the parameter list")) { free(n->name); sync_stmt(p); return NULL; }
    n->params = NULL; n->nparams = 0;
    Vec pv; vec_init(&pv);
    if (!is(p, T_RPAREN)) {
        for (;;) {
            OkType ty;
            if (!parse_bare_type(p, &ty)) { sync_stmt(p); break; }
            if (ty == ty_auto) {
                perr(p, cur(p), "parameters cannot use `type.auto` — write the parameter type explicitly (inference is for initializers, spec §8.1).");
                sync_stmt(p);
                break;
            }
            if (!expect(p, T_DOT, "`.` between the parameter type and name (as in `number.a`)")) {
                sync_stmt(p);
                break;
            }
            if (!is(p, T_IDENT)) {
                perr(p, cur(p), "expected a parameter name, but found %s.", tok_kind_name(cur(p)->kind));
                sync_stmt(p);
                break;
            }
            Param *pa = ok_xmalloc(sizeof *pa);
            pa->name = ok_xstrdup(cur(p)->text);
            pa->type = ty;
            vec_push(&pv, pa);
            advance(p);
            if (is(p, T_COMMA)) { advance(p); continue; }
            if (is(p, T_RPAREN)) break;
            perr(p, cur(p), "expected `,` or `)` in the parameter list, but found %s.",
                 tok_kind_name(cur(p)->kind));
            break;
        }
    }
    if (is(p, T_RPAREN)) advance(p);
    /* flatten the pointer vector into a real Param array */
    n->params = ok_xmalloc((pv.len ? pv.len : 1) * sizeof(Param));
    n->nparams = pv.len;
    for (size_t i = 0; i < pv.len; i++) {
        Param *pa = (Param *)pv.items[i];
        n->params[i] = *pa;   /* copies name pointer + type */
        free(pa);
    }
    free(pv.items);

    /* return type */
    if (is(p, T_ARROW)) {
        advance(p);
        OkType ty;
        if (!parse_bare_type(p, &ty)) { sync_stmt(p); return n; }
        if (ty == ty_auto) {
            perr(p, cur(p), "return types cannot use `type.auto` — write the return type explicitly (inference is for initializers, spec §8.1).");
            sync_stmt(p);
            return n;
        }
        if (ty && ty_kind(ty) == OK_ARRAY) {
            Diag *d = perr(p, cur(p), "functions cannot return arrays directly in Okular.");
            diag_note(d, "return `ptr<array<T, N>>` instead (spec §12), or an element.");
            n->otype = ty_number; /* recover as number */
        } else if (ty && (ty_kind(ty) == OK_STRUCT || ty_kind(ty) == OK_UNION)) {
            Diag *d = perr(p, cur(p), "functions cannot return structs or unions directly in Okular 0.7.");
            diag_note(d, "return `ptr<%s>` instead (spec §12), or write into a pointer parameter.", ty->name);
            n->otype = ty_number; /* recover as number */
        } else {
            n->otype = ty;
        }
    } else {
        n->otype = ty_void;
    }

    /* body */
    if (!parse_stmt_list(p, &n->body, T_RBRACE)) return n;
    return n;
}

static Node *parse_toplevel(Parser *p) {
    Tok *t = cur(p);
    switch (t->kind) {
    case T_KW_TYPE: {
        /* directive: type.<feature>=value   (spec §5) */
        if (isk(p, 1, T_DOT) && isk(p, 2, T_IDENT) && isk(p, 3, T_EQ)) {
            const char *feat = at(p, 2)->text;
            Node *n = node_new(p->ar, A_DIRECTIVE, t->line, t->col);
            if (strcmp(feat, "text") == 0) n->feature = OK_FEATURE_TEXT;
            else {
                Diag *d = perr(p, at(p, 2), "unknown feature directive `type.%s=...`.", feat);
                diag_note(d, "the 0.1 features are: text.");
                n->feature = -1;
            }
            advance(p); advance(p); advance(p); advance(p); /* type . feat = */
            if (is(p, T_INT)) {
                n->fvalue = (int)cur(p)->ival;
                advance(p);
            } else {
                perr(p, cur(p), "a feature directive value is 0 or 1, but found %s.",
                     tok_kind_name(cur(p)->kind));
                n->fvalue = 0;
                sync_stmt(p);
            }
            if (n->fvalue != 0 && n->fvalue != 1) {
                perr(p, t, "feature directive values are 0 (off) or 1 (on); got %d.", n->fvalue);
                n->fvalue = (n->fvalue != 0);
            }
            return n;
        }
        /* otherwise: top-level variable declaration (global) */
        OkType ty;
        if (!parse_type_prefix(p, &ty)) { sync_stmt(p); return NULL; }
        if (!is(p, T_IDENT)) {
            perr(p, cur(p), "expected a variable name after `type.%s`, but found %s.",
                 ok_type_name(ty), tok_kind_name(cur(p)->kind));
            sync_stmt(p);
            return NULL;
        }
        Node *n = node_new(p->ar, A_VARDECL, t->line, t->col);
        n->otype = ty;
        n->name = ok_xstrdup(cur(p)->text);
        advance(p);
        if (!expect(p, T_EQ, "`=` and an initializer")) { free(n->name); return NULL; }
        n->a = parse_initializer(p);
        if (!n->a) { free(n->name); return NULL; }
        return n;
    }
    case T_LBRACKET:
        return parse_langcol(p);
    case T_KW_FUNCTION:
        return parse_toplevel_function(p);
    case T_KW_STRUCT:
        return parse_recorddecl(p, false);
    case T_KW_UNION:
        return parse_recorddecl(p, true);
    case T_KW_CONST:
        return parse_constdecl(p);
    case T_IDENT: {
        if (isk(p, 1, T_EQ) && isk(p, 2, T_LBRACE))
            return parse_devcol(p);
        /* fall through: statements (main.ok only, sema enforces) */
        return parse_stmt(p);
    }
    default:
        /* statements at top level (main.ok); anything else is an error */
        return parse_stmt(p);
    }
}

Node *parse_file_tokens(TokList *toks, SourceFile *f, DiagEngine *de, Arena *ar) {
    Parser p = { toks, f, de, ar, 0 };
    /* registry already seeded project-wide by the loader */
    Node *file = node_new(ar, A_FILE, 1, 1);
    vec_init(&file->body);

    for (;;) {
        skip_nl(&p);
        if (is(&p, T_EOF)) break;
        if (is(&p, T_RBRACE)) {
            perr(&p, cur(&p), "unexpected `}` — there is no open block here.");
            advance(&p);
            continue;
        }
        if (is(&p, T_DOT) && isk(&p, 1, T_KW_END)) {
            perr(&p, cur(&p), "unexpected `.end` — there is no open column here (spec §3.1).");
            advance(&p); advance(&p);
            continue;
        }
        if (is(&p, T_RBRACKET)) {
            perr(&p, cur(&p), "unexpected `]` — there is no open `[` column name here.");
            advance(&p);
            continue;
        }
        size_t before = p.pos;
        Node *top = parse_toplevel(&p);
        if (top) vec_push(&file->body, top);
        if (p.pos == before) advance(&p); /* guarantee progress */
        if (!is(&p, T_NL) && !is(&p, T_EOF) && !is(&p, T_RBRACE)) {
            perr(&p, cur(&p), "expected the end of the line after this item, but found %s.",
                 tok_kind_name(cur(&p)->kind));
            sync_stmt(&p);
        }
    }
    return file;
}
