/* ast_serial.c — the machine AST protocol (M4, --selfhost-parse).
 *
 * Two directions over one record stream (ok/selfhost.h):
 *   ast_serialize      C parse tree  -> records (differential verification)
 *   ast_deserialize    records       -> C parse tree (the real bridge)
 *
 * The Okular-written parser produces the same stream from its own tree,
 * so byte-for-byte equality of the two serializations proves the two
 * parsers built identical trees — and a deserialized tree is literally
 * interchangeable with a C-parsed one (sema cannot tell them apart).
 *
 * Literals serialize as RAW SOURCE SPELLINGS; values re-derive through
 * the same spell_* helpers the token bridge uses, so unsigned 64-bit
 * literals and text escape processing are identical by construction.
 */
#include "ok/ast.h"
#include "ok/selfhost.h"
#include "ok/parser.h"
#include "ok/util.h"
#include "ok/diag.h"
#include "ok/source.h"
#include <stdio.h>

/* ---------------- serializer ---------------- */

static void ser_str(Buf *o, const char *s, size_t n) {
    buf_puts(o, "S ");
    char tmp[24];
    int k = snprintf(tmp, sizeof tmp, "%zu", n);
    buf_put(o, tmp, (size_t)k);
    buf_putc(o, ' ');
    buf_put(o, s, n);
    buf_putc(o, '\n');
}

static void ser_int(Buf *o, const char *tag, uint64_t v) {
    char tmp[32];
    int k = snprintf(tmp, sizeof tmp, "%llu", (unsigned long long)v);
    buf_put(o, tag, 1);
    buf_putc(o, ' ');
    buf_put(o, tmp, (size_t)k);
    buf_putc(o, '\n');
}

static void ser_path(Buf *o, char **parts, size_t n) {
    ser_int(o, "P", n);
    for (size_t i = 0; i < n; i++)
        ser_str(o, parts[i], strlen(parts[i]));
}

/* the type serializer: form-tagged records */
static void ser_type(Buf *o, OkType t) {
    if (!t || ty_kind(t) == OK_VOID) { buf_puts(o, "T s:void\n"); return; }
    switch (ty_kind(t)) {
    case OK_NUMBER: case OK_DECIMAL: case OK_TEXT: case OK_BOOL:
    case OK_INT8: case OK_INT16: case OK_INT32:
    case OK_UINT8: case OK_UINT16: case OK_UINT32: case OK_UINT64:
    case OK_AUTO: {
        buf_puts(o, "T s:");
        buf_puts(o, ok_type_name(t));
        buf_putc(o, '\n');
        return;
    }
    case OK_ARRAY: {
        char tmp[32];
        int k = snprintf(tmp, sizeof tmp, "%zu", t->count);
        buf_puts(o, "T a:");
        buf_put(o, tmp, (size_t)k);
        buf_putc(o, '\n');
        ser_type(o, t->elem);
        return;
    }
    case OK_PTR: {
        buf_puts(o, "T p\n");
        ser_type(o, t->elem);
        return;
    }
    case OK_STRUCT: case OK_UNION: case OK_NAMED: {
        buf_puts(o, "T n:");
        buf_puts(o, t->name ? t->name : "?");
        buf_putc(o, '\n');
        return;
    }
    default:
        buf_puts(o, "T s:void\n");
        return;
    }
}

static void ser_node(Buf *o, Node *n);

static void ser_node_or_nil(Buf *o, Node *n) {
    if (!n) { buf_puts(o, "X\n"); return; }
    ser_node(o, n);
}

static void ser_node_list(Buf *o, Vec *body) {
    ser_int(o, "L", body ? body->len : 0);
    for (size_t i = 0; body && i < body->len; i++)
        ser_node(o, (Node *)body->items[i]);
}

static void ser_node(Buf *o, Node *n) {
    char tmp[96];
    int k = snprintf(tmp, sizeof tmp, "N %d %zu %zu\n", (int)n->kind, n->line, n->col);
    buf_put(o, tmp, (size_t)k);

    switch (n->kind) {
    case A_INT:
        ser_str(o, n->spell ? n->spell : "0", n->spell ? strlen(n->spell) : 1);
        return;
    case A_DEC:
        buf_puts(o, "D ");
        buf_puts(o, n->spell ? n->spell : "0");
        buf_putc(o, '\n');
        return;
    case A_TEXT:
        ser_str(o, n->spell ? n->spell : "\"\"", n->spell ? strlen(n->spell) : 2);
        return;
    case A_BOOL:
        ser_int(o, "I", n->bval ? 1 : 0);
        return;
    case A_PATH:
        ser_path(o, n->parts, n->nparts);
        return;
    case A_CALL:
        ser_path(o, n->parts, n->nparts);
        ser_node_list(o, &n->args);
        return;
    case A_WRITE:
        ser_node_list(o, &n->args);
        return;
    case A_BIN:
        ser_int(o, "I", (uint64_t)n->op);
        ser_node_or_nil(o, n->a);
        ser_node_or_nil(o, n->b);
        return;
    case A_UN:
        ser_int(o, "I", (uint64_t)n->uop);
        ser_node_or_nil(o, n->a);
        return;
    case A_ARRAYLIT:
        ser_node_list(o, &n->args);
        return;
    case A_INDEX:
        ser_node_or_nil(o, n->a);
        ser_node_or_nil(o, n->b);
        return;
    case A_NULL:
        return;
    case A_ALLOC:
        ser_type(o, n->otype);
        ser_node_or_nil(o, n->a);
        return;
    case A_MEMBER:
        ser_str(o, n->name, strlen(n->name));
        ser_node_or_nil(o, n->a);
        return;
    case A_VARDECL:
        ser_type(o, n->otype);
        ser_str(o, n->name, strlen(n->name));
        ser_node_or_nil(o, n->a);
        return;
    case A_ASSIGN:
        ser_path(o, n->parts, n->nparts);
        ser_node_or_nil(o, n->a);
        return;
    case A_INDEXASSIGN:
        ser_node_or_nil(o, n->a);
        ser_node_or_nil(o, n->b);
        ser_node_or_nil(o, n->c);
        return;
    case A_DEREFASSIGN:
        ser_node_or_nil(o, n->a);
        ser_node_or_nil(o, n->c);
        return;
    case A_RELEASE:
        ser_node_or_nil(o, n->a);
        return;
    case A_FIELDASSIGN:
        ser_str(o, n->name, strlen(n->name));
        ser_node_or_nil(o, n->a);
        ser_node_or_nil(o, n->c);
        return;
    case A_EXPRSTMT:
        ser_node_or_nil(o, n->a);
        return;
    case A_WHEN:
        ser_node_or_nil(o, n->a);
        ser_node_list(o, &n->body);
        ser_node_list(o, &n->body_else);
        return;
    case A_LOOP_COUNT:
        ser_str(o, n->name, strlen(n->name));
        ser_int(o, "I", n->inclusive ? 1 : 0);
        ser_node_or_nil(o, n->a);
        ser_node_or_nil(o, n->b);
        ser_node_list(o, &n->body);
        return;
    case A_LOOP_COND:
        ser_node_or_nil(o, n->a);
        ser_node_list(o, &n->body);
        return;
    case A_BREAK: case A_CONTINUE: case A_PRINT:
        return;
    case A_RETURN:
        if (n->a) { ser_int(o, "I", 1); ser_node(o, n->a); }
        else ser_int(o, "I", 0);
        return;
    case A_DIRECTIVE:
        ser_int(o, "I", (uint64_t)(int64_t)n->feature);
        ser_int(o, "I", (uint64_t)(int64_t)n->fvalue);
        return;
    case A_LANGCOL:
        ser_path(o, n->parts, n->nparts);
        ser_int(o, "L", n->items_spell.len ? n->items_spell.len : n->items.len);
        for (size_t i = 0; i < (n->items_spell.len ? n->items_spell.len : n->items.len); i++) {
            const char *sp = n->items_spell.len
                ? (char *)n->items_spell.items[i]
                : (char *)n->items.items[i];
            ser_str(o, sp, strlen(sp));
        }
        return;
    case A_DEVCOL:
        ser_str(o, n->name, strlen(n->name));
        ser_node_list(o, &n->body);
        return;
    case A_STRUCTDECL: case A_UNIONDECL:
        ser_str(o, n->name, strlen(n->name));
        ser_int(o, "L", n->nparams);
        for (size_t i = 0; i < n->nparams; i++) {
            ser_type(o, n->params[i].type);
            ser_str(o, n->params[i].name, strlen(n->params[i].name));
        }
        return;
    case A_CONSTDECL:
        ser_str(o, n->name, strlen(n->name));
        ser_node_or_nil(o, n->a);
        return;
    case A_FUNC:
        ser_str(o, n->name, strlen(n->name));
        ser_int(o, "L", n->nparams);
        for (size_t i = 0; i < n->nparams; i++) {
            ser_type(o, n->params[i].type);
            ser_str(o, n->params[i].name, strlen(n->params[i].name));
        }
        ser_type(o, n->otype);
        ser_node_list(o, &n->body);
        return;
    case A_FILE:
        ser_node_list(o, &n->body);
        return;
    default:
        /* sema-created nodes (A_CONV/A_TEXTOP/A_FSOP/A_ENVOP) never appear
         * in a parser tree; a protocol stream carrying them is malformed */
        buf_puts(o, "X\n");
        return;
    }
}

void ast_serialize(Node *file_node, Buf *out) {
    ser_node(out, file_node);
}

/* ---------------- deserializer ---------------- */

typedef struct {
    const char *p, *end;
    Arena *ar;
    DiagEngine *de;
    SourceFile *f;
    bool bad;
} Rd;

static bool rd_fail(Rd *r, const char *why) {
    if (!r->bad) {
        diag_emit(r->de, DIAG_ERROR, r->f, 1, 1,
                  "self-hosted parser protocol error: %s.", why);
        r->bad = true;
    }
    return false;
}

static bool rd_num(Rd *r, uint64_t *out) {
    uint64_t v = 0;
    bool any = false;
    while (r->p < r->end && *r->p >= '0' && *r->p <= '9') {
        v = v * 10 + (uint64_t)(*r->p - '0');
        any = true;
        r->p++;
    }
    if (!any) return rd_fail(r, "expected a number");
    *out = v;
    if (r->p < r->end && *r->p == ' ') r->p++;
    return true;
}

/* one raw field: bytes until NL (spellings of decimals carry no spaces) */
static bool rd_line(Rd *r, const char **out, size_t *out_n) {
    const char *start = r->p;
    while (r->p < r->end && *r->p != '\n') r->p++;
    if (r->p >= r->end) return rd_fail(r, "stream ended inside a record");
    *out = start;
    *out_n = (size_t)(r->p - start);
    r->p++; /* NL */
    return true;
}

static bool rd_srecord(Rd *r, const char **out, size_t *out_n) {
    if (r->p + 2 > r->end || r->p[0] != 'S' || r->p[1] != ' ')
        return rd_fail(r, "expected an S record");
    r->p += 2;
    uint64_t n;
    if (!rd_num(r, &n)) return false;
    if (n > (1u << 20)) return rd_fail(r, "string record is not sane");
    if ((size_t)(r->end - r->p) < (size_t)n + 1)
        return rd_fail(r, "stream ended inside a string record");
    *out = r->p;
    *out_n = (size_t)n;
    r->p += (size_t)n;
    if (*r->p != '\n') return rd_fail(r, "string record missing its terminator");
    r->p++;
    return true;
}

static bool rd_tag(Rd *r, char tag) {
    if (r->p + 1 > r->end || *r->p != tag) {
        char why[64];
        snprintf(why, sizeof why, "expected a `%c` record", tag);
        return rd_fail(r, why);
    }
    r->p++;
    if (r->p < r->end && *r->p == ' ') r->p++;
    return true;
}

static bool rd_nl(Rd *r) {
    if (r->p >= r->end || *r->p != '\n') return rd_fail(r, "missing record terminator");
    r->p++;
    return true;
}

/* an `I <int>` record */
static bool rd_int(Rd *r, uint64_t *out) {
    if (!rd_tag(r, 'I')) return false;
    if (!rd_num(r, out)) return false;
    return rd_nl(r);
}

static char *rd_take(Rd *r, const char *s, size_t n) {
    char *dup = ok_xstrndup(s, n);
    return dup;
}

static Node *rd_node(Rd *r);

static bool rd_type(Rd *r, OkType *out) {
    if (!rd_tag(r, 'T')) return false;
    const char *line;
    size_t n;
    if (!rd_line(r, &line, &n)) return false;
    if (n >= 2 && line[0] == 's' && line[1] == ':') {
        const char *name = line + 2;
        size_t namelen = n - 2;
        if (namelen == 4 && strncmp(name, "void", 4) == 0) { *out = ty_void; return true; }
        char tmp[32];
        if (namelen >= sizeof tmp) return rd_fail(r, "scalar type name too long");
        memcpy(tmp, name, namelen);
        tmp[namelen] = 0;
        if (!ty_from_scalar_name(tmp, out))
            return rd_fail(r, "unknown scalar type in stream");
        return true;
    }
    if (n >= 2 && line[0] == 'n' && line[1] == ':') {
        char tmp[128];
        size_t namelen = n - 2;
        if (namelen >= sizeof tmp) return rd_fail(r, "named type too long");
        memcpy(tmp, line + 2, namelen);
        tmp[namelen] = 0;
        *out = parser_named_type_public(tmp);
        return true;
    }
    if (n == 1 && line[0] == 'p') {
        OkType elem = NULL;
        if (!rd_type(r, &elem)) return false;
        *out = ty_ptr(elem);
        if (!*out) return rd_fail(r, "pointer type too deep to intern");
        return true;
    }
    if (n >= 2 && line[0] == 'a' && line[1] == ':') {
        char tmp[32];
        size_t cl = n - 2;
        if (cl >= sizeof tmp) return rd_fail(r, "array length too long");
        memcpy(tmp, line + 2, cl);
        tmp[cl] = 0;
        uint64_t count = strtoull(tmp, NULL, 10);
        if (count == 0 || count > 65536) return rd_fail(r, "array length out of range");
        OkType elem = NULL;
        if (!rd_type(r, &elem)) return false;
        *out = ty_array(elem, (size_t)count);
        if (!*out) return rd_fail(r, "array type too large");
        return true;
    }
    return rd_fail(r, "malformed type record");
}

static Node *rd_node_or_nil(Rd *r) {
    if (r->p < r->end && *r->p == 'X') {
        r->p++;
        if (r->p < r->end && *r->p == '\n') r->p++;
        return NULL;
    }
    return rd_node(r);
}

static bool rd_path(Rd *r, char ***parts_out, size_t *n_out) {
    if (!rd_tag(r, 'P')) return false;
    uint64_t n;
    if (!rd_num(r, &n)) return false;
    if (!rd_nl(r)) return false;
    if (n > 256) return rd_fail(r, "path too long");
    char **parts = ok_xmalloc((n ? n : 1) * sizeof(char *));
    for (uint64_t i = 0; i < n; i++) {
        const char *s;
        size_t sn;
        if (!rd_srecord(r, &s, &sn)) return false;
        parts[i] = rd_take(r, s, sn);
    }
    *parts_out = parts;
    *n_out = (size_t)n;
    return true;
}

static bool rd_node_list(Rd *r, Vec *out) {
    if (!rd_tag(r, 'L')) return false;
    uint64_t n;
    if (!rd_num(r, &n)) return false;
    if (!rd_nl(r)) return false;
    if (n > (1u << 20)) return rd_fail(r, "node list too long");
    vec_init(out);
    for (uint64_t i = 0; i < n; i++) {
        Node *child = rd_node_or_nil(r);
        if (r->bad) return false;
        vec_push(out, child);
    }
    return true;
}

static Node *rd_node(Rd *r) {
    if (!rd_tag(r, 'N')) return NULL;
    uint64_t kind, line, col;
    if (!rd_num(r, &kind) || !rd_num(r, &line) || !rd_num(r, &col)) return NULL;
    if (!rd_nl(r)) return NULL;
    if (kind > (uint64_t)A_FILE) { rd_fail(r, "unknown node kind"); return NULL; }

    Node *n = node_new(r->ar, (NodeKind)kind, (size_t)line, (size_t)col);
    const char *s;
    size_t sn;
    uint64_t v;
    OkType t;

    switch ((NodeKind)kind) {
    case A_INT: {
        if (!rd_srecord(r, &s, &sn)) break;
        n->spell = rd_take(r, s, sn);
        if (!spell_int_value(n->spell, sn, &n->ival))
            rd_fail(r, "malformed number literal spelling");
        break;
    }
    case A_DEC: {
        if (!rd_tag(r, 'D')) break;
        if (!rd_line(r, &s, &sn)) break;
        n->spell = rd_take(r, s, sn);
        n->dval = spell_dec_value(n->spell, sn);
        break;
    }
    case A_TEXT: {
        if (!rd_srecord(r, &s, &sn)) break;
        n->spell = rd_take(r, s, sn);
        size_t ulen = 0;
        char *bytes = spell_text_unescape(n->spell, sn, &ulen);
        if (!bytes) { rd_fail(r, "malformed text literal spelling"); break; }
        n->str = bytes;
        n->str_len = ulen;
        break;
    }
    case A_BOOL:
        if (rd_int(r, &v)) n->bval = v != 0;
        break;
    case A_PATH:
        rd_path(r, &n->parts, &n->nparts);
        break;
    case A_CALL:
        if (rd_path(r, &n->parts, &n->nparts)) rd_node_list(r, &n->args);
        break;
    case A_WRITE:
        rd_node_list(r, &n->args);
        break;
    case A_BIN:
        if (rd_int(r, &v)) { n->op = (BinOp)v; n->a = rd_node_or_nil(r); n->b = rd_node_or_nil(r); }
        break;
    case A_UN:
        if (rd_int(r, &v)) { n->uop = (UnOp)v; n->a = rd_node_or_nil(r); }
        break;
    case A_ARRAYLIT:
        rd_node_list(r, &n->args);
        break;
    case A_INDEX:
        n->a = rd_node_or_nil(r);
        n->b = rd_node_or_nil(r);
        break;
    case A_NULL:
        break;
    case A_ALLOC:
        if (rd_type(r, &t)) { n->otype = t; n->a = rd_node_or_nil(r); }
        break;
    case A_MEMBER:
        if (rd_srecord(r, &s, &sn)) { n->name = rd_take(r, s, sn); n->a = rd_node_or_nil(r); }
        break;
    case A_VARDECL:
        if (rd_type(r, &t) && rd_srecord(r, &s, &sn)) {
            n->otype = t;
            n->name = rd_take(r, s, sn);
            n->a = rd_node_or_nil(r);
        }
        break;
    case A_ASSIGN:
        if (rd_path(r, &n->parts, &n->nparts)) n->a = rd_node_or_nil(r);
        break;
    case A_INDEXASSIGN:
        n->a = rd_node_or_nil(r);
        n->b = rd_node_or_nil(r);
        n->c = rd_node_or_nil(r);
        break;
    case A_DEREFASSIGN:
        n->a = rd_node_or_nil(r);
        n->c = rd_node_or_nil(r);
        break;
    case A_RELEASE:
        n->a = rd_node_or_nil(r);
        break;
    case A_FIELDASSIGN:
        if (rd_srecord(r, &s, &sn)) { n->name = rd_take(r, s, sn); n->a = rd_node_or_nil(r); n->c = rd_node_or_nil(r); }
        break;
    case A_EXPRSTMT:
        n->a = rd_node_or_nil(r);
        break;
    case A_WHEN:
        n->a = rd_node_or_nil(r);
        if (rd_node_list(r, &n->body)) rd_node_list(r, &n->body_else);
        break;
    case A_LOOP_COUNT:
        if (rd_srecord(r, &s, &sn) && rd_int(r, &v)) {
            n->name = rd_take(r, s, sn);
            n->inclusive = v != 0;
            n->a = rd_node_or_nil(r);
            n->b = rd_node_or_nil(r);
            rd_node_list(r, &n->body);
        }
        break;
    case A_LOOP_COND:
        n->a = rd_node_or_nil(r);
        rd_node_list(r, &n->body);
        break;
    case A_BREAK: case A_CONTINUE: case A_PRINT:
        break;
    case A_RETURN:
        if (rd_int(r, &v) && v != 0) n->a = rd_node_or_nil(r);
        break;
    case A_DIRECTIVE:
        if (rd_int(r, &v)) n->feature = (int)v;
        if (rd_int(r, &v)) n->fvalue = (int)v;
        break;
    case A_LANGCOL: {
        if (!rd_path(r, &n->parts, &n->nparts)) break;
        if (!rd_tag(r, 'L')) break;
        uint64_t cnt;
        if (!rd_num(r, &cnt) || !rd_nl(r)) break;
        for (uint64_t i = 0; i < cnt; i++) {
            if (!rd_srecord(r, &s, &sn)) break;
            svec_push((StrVec *)&n->items_spell, rd_take(r, s, sn));
            size_t ulen = 0;
            char *bytes = spell_text_unescape(s, sn, &ulen);
            if (!bytes) { rd_fail(r, "malformed column item"); break; }
            svec_push((StrVec *)&n->items, bytes);
        }
        break;
    }
    case A_DEVCOL:
        if (rd_srecord(r, &s, &sn)) { n->name = rd_take(r, s, sn); rd_node_list(r, &n->body); }
        break;
    case A_STRUCTDECL: case A_UNIONDECL: {
        if (!rd_srecord(r, &s, &sn)) break;
        n->name = rd_take(r, s, sn);
        /* the shared named-type placeholder (spec §8.3): sema fills it in
         * place, so every reference — deserialized or C-parsed — resolves
         * through the same interned descriptor */
        n->otype = parser_named_type_public(n->name);
        if (!rd_tag(r, 'L')) break;
        uint64_t cnt;
        if (!rd_num(r, &cnt) || !rd_nl(r)) break;
        n->params = ok_xmalloc((cnt ? cnt : 1) * sizeof(Param));
        n->nparams = 0;
        for (uint64_t i = 0; i < cnt; i++) {
            OkType ft = NULL;
            const char *fn;
            size_t fnn;
            if (!rd_type(r, &ft) || !rd_srecord(r, &fn, &fnn)) break;
            n->params[n->nparams].name = rd_take(r, fn, fnn);
            n->params[n->nparams].type = ft;
            n->nparams++;
        }
        break;
    }
    case A_CONSTDECL:
        if (rd_srecord(r, &s, &sn)) { n->name = rd_take(r, s, sn); n->a = rd_node_or_nil(r); }
        break;
    case A_FUNC: {
        if (!rd_srecord(r, &s, &sn)) break;
        n->name = rd_take(r, s, sn);
        if (!rd_tag(r, 'L')) break;
        uint64_t cnt;
        if (!rd_num(r, &cnt) || !rd_nl(r)) break;
        n->params = ok_xmalloc((cnt ? cnt : 1) * sizeof(Param));
        n->nparams = 0;
        for (uint64_t i = 0; i < cnt; i++) {
            OkType pt = NULL;
            const char *pn;
            size_t pnn;
            if (!rd_type(r, &pt) || !rd_srecord(r, &pn, &pnn)) break;
            n->params[n->nparams].name = rd_take(r, pn, pnn);
            n->params[n->nparams].type = pt;
            n->nparams++;
        }
        if (!rd_type(r, &n->otype)) break;
        rd_node_list(r, &n->body);
        break;
    }
    case A_FILE:
        rd_node_list(r, &n->body);
        break;
    default:
        rd_fail(r, "unsupported node kind in stream");
        break;
    }
    return r->bad ? NULL : n;
}

Node *ast_deserialize(const char *data, size_t len, SourceFile *f,
                      DiagEngine *de, Arena *ar) {
    Rd r = { data, data + len, ar, de, f, false };
    if (len == 0) {
        diag_emit(de, DIAG_ERROR, f, 1, 1,
                  "the self-hosted parser produced no output.");
        return NULL;
    }
    /* leading E records: parse errors (reported; the tree is discarded) */
    bool saw_error = false;
    for (;;) {
        if (r.p < r.end && r.p[0] == 'E') {
            const char *save = r.p;
            r.p++;
            if (r.p < r.end && *r.p == ' ') r.p++;
            uint64_t line, col, n;
            const char *spell = "";
            size_t sn = 0;
            if (rd_num(&r, &line) && rd_num(&r, &col) && rd_num(&r, &n)
                && n <= (1u << 20) && (size_t)(r.end - r.p) >= (size_t)n + 1) {
                spell = r.p;
                sn = (size_t)n;
                r.p += (size_t)n;
                if (*r.p == '\n') r.p++;
                diag_emit(de, DIAG_ERROR, f, (size_t)line, (size_t)col,
                          "the self-hosted parser rejected this file: %.*s.",
                          (int)sn, spell);
                saw_error = true;
                continue;
            }
            r.p = save; /* not an E record after all */
        }
        break;
    }
    if (saw_error) return NULL;

    Node *file = rd_node(&r);
    if (r.bad) return NULL;
    if (r.p != r.end)
        rd_fail(&r, "trailing bytes after the tree");
    return file;
}
