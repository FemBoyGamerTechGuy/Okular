/* lexer.c — the Okular lexer (spec §1).
 *
 * Design notes:
 *  - Every token carries exact line/col/span (brief §29).
 *  - Newlines are tokens (T_NL) and act as statement separators (spec §1.2).
 *    They are suppressed while inside ( ) or [ ] so argument lists may wrap.
 *  - Text literals are unescaped here; unknown escapes are errors.
 *  - Integer literals support 0x hex and _ digit grouping with placement
 *    validation (spec §1.6).
 */
#include "ok/lexer.h"

typedef struct {
    SourceFile *f;
    DiagEngine *de;
    size_t pos, line, col;
    size_t paren_depth;   /* ( and [ nest; T_NL suppressed while > 0 */
    TokList *out;
} Lexer;

static char peek(Lexer *lx)   { return lx->f->data[lx->pos]; }
static char peek2(Lexer *lx)  { return lx->f->data[lx->pos + 1]; }
static bool at_end(Lexer *lx) { return lx->pos >= lx->f->len; }

static void advance(Lexer *lx) {
    char c = lx->f->data[lx->pos++];
    if (c == '\n') { lx->line++; lx->col = 1; }
    else lx->col++;
}

static void push_tok(Lexer *lx, TokKind kind, size_t line, size_t col, size_t off, size_t len) {
    TokList *out = lx->out;
    if (out->len == out->cap) {
        out->cap = out->cap ? out->cap * 2 : 256;
        out->items = ok_xrealloc(out->items, out->cap * sizeof(Tok));
    }
    Tok *t = &out->items[out->len++];
    memset(t, 0, sizeof *t);
    t->kind = kind; t->line = line; t->col = col; t->off = off; t->len = len;
}

static Diag *lex_err(Lexer *lx, size_t line, size_t col, const char *fmt, ...)
    __attribute__((format(printf, 4, 5)));
static Diag *lex_err(Lexer *lx, size_t line, size_t col, const char *fmt, ...) {
    va_list ap; va_start(ap, fmt);
    char buf[512]; vsnprintf(buf, sizeof buf, fmt, ap); va_end(ap);
    return diag_emit(lx->de, DIAG_ERROR, lx->f, line, col, "%s", buf);
}

/* ---- keywords ---- */

typedef struct { const char *word; TokKind kind; } KwEntry;

static const KwEntry keywords[] = {
    {"type", T_KW_TYPE},       {"function", T_KW_FUNCTION},
    {"struct", T_KW_STRUCT},   {"when", T_KW_WHEN},
    {"else", T_KW_ELSE},       {"loop", T_KW_LOOP},
    {"from", T_KW_FROM},       {"to", T_KW_TO},
    {"until", T_KW_UNTIL},     {"break", T_KW_BREAK},
    {"continue", T_KW_CONTINUE}, {"return", T_KW_RETURN},
    {"print", T_KW_PRINT},     {"write", T_KW_WRITE},
    {"true", T_KW_TRUE},       {"false", T_KW_FALSE},
    {"and", T_KW_AND},         {"or", T_KW_OR},
    {"not", T_KW_NOT},         {"end", T_KW_END},
    /* reserved: designed features, not implemented (spec §1.5 / §20) */
    {"union", T_KW_RESERVED},  {"pointer", T_KW_RESERVED},
    {"alloc", T_KW_RESERVED},  {"release", T_KW_RESERVED},
    {"null", T_KW_RESERVED},   {"guard", T_KW_RESERVED},
    {"fail", T_KW_RESERVED},   {"with", T_KW_RESERVED},
    {"priv", T_KW_RESERVED},   {"pub", T_KW_RESERVED},
    {"match", T_KW_RESERVED},  {"case", T_KW_RESERVED},
    {"const", T_KW_RESERVED},  {"ptr", T_KW_RESERVED},
};

static bool kw_lookup(const char *s, size_t n, TokKind *out) {
    for (size_t i = 0; i < sizeof keywords / sizeof keywords[0]; i++) {
        if (strlen(keywords[i].word) == n && memcmp(keywords[i].word, s, n) == 0) {
            *out = keywords[i].kind;
            return true;
        }
    }
    return false;
}

const char *tok_kind_name(TokKind k) {
    switch (k) {
    case T_EOF: return "end of file";
    case T_NL: return "end of line";
    case T_IDENT: return "identifier";
    case T_INT: return "number literal";
    case T_DEC: return "decimal literal";
    case T_TEXT: return "text literal";
    case T_PLUS: return "`+`";   case T_MINUS: return "`-`";
    case T_STAR: return "`*`";   case T_SLASH: return "`/`";
    case T_PERCENT: return "`%`";
    case T_EQ: return "`=`";     case T_EQEQ: return "`==`";
    case T_BANGEQ: return "`!=`";
    case T_LT: return "`<`";     case T_LE: return "`<=`";
    case T_GT: return "`>`";     case T_GE: return "`>=`";
    case T_ARROW: return "`->`";
    case T_DOT: return "`.`";    case T_COMMA: return "`,`";
    case T_LPAREN: return "`(`"; case T_RPAREN: return "`)`";
    case T_LBRACE: return "`{`"; case T_RBRACE: return "`}`";
    case T_LBRACKET: return "`[`"; case T_RBRACKET: return "`]`";
    case T_KW_TYPE: return "`type`"; case T_KW_FUNCTION: return "`function`";
    case T_KW_STRUCT: return "`struct`"; case T_KW_WHEN: return "`when`";
    case T_KW_ELSE: return "`else`"; case T_KW_LOOP: return "`loop`";
    case T_KW_FROM: return "`from`"; case T_KW_TO: return "`to`";
    case T_KW_UNTIL: return "`until`"; case T_KW_BREAK: return "`break`";
    case T_KW_CONTINUE: return "`continue`"; case T_KW_RETURN: return "`return`";
    case T_KW_PRINT: return "`print`"; case T_KW_WRITE: return "`write`";
    case T_KW_TRUE: return "`true`"; case T_KW_FALSE: return "`false`";
    case T_KW_AND: return "`and`"; case T_KW_OR: return "`or`";
    case T_KW_NOT: return "`not`"; case T_KW_END: return "`end`";
    case T_KW_RESERVED: return "reserved keyword";
    }
    return "?";
}

/* ---- literal helpers ---- */

/* validate underscore placement in a digit run: no __, no trailing _ */
static bool underscores_ok(const char *s, size_t n) {
    if (n == 0) return true;
    if (s[n - 1] == '_') return false;
    for (size_t i = 1; i < n; i++)
        if (s[i] == '_' && s[i - 1] == '_') return false;
    return true;
}

static void lex_number(Lexer *lx) {
    size_t line = lx->line, col = lx->col, off = lx->pos;

    if (peek(lx) == '0' && (peek2(lx) == 'x' || peek2(lx) == 'X')) {
        advance(lx); advance(lx);
        size_t ds = lx->pos;
        while (!at_end(lx) && ((peek(lx) >= '0' && peek(lx) <= '9') ||
                               (peek(lx) >= 'a' && peek(lx) <= 'f') ||
                               (peek(lx) >= 'A' && peek(lx) <= 'F') ||
                               peek(lx) == '_'))
            advance(lx);
        size_t dn = lx->pos - ds;
        if (dn == 0) {
            lex_err(lx, line, col, "expected hexadecimal digits after `0x`.");
            push_tok(lx, T_INT, line, col, off, lx->pos - off);
            return;
        }
        if (!underscores_ok(lx->f->data + ds, dn)) {
            lex_err(lx, line, col, "misplaced `_` in the hexadecimal literal (group digits like `0xFF_FF`).");
        }
        /* parse value */
        uint64_t v = 0; bool overflow = false;
        for (size_t i = 0; i < dn; i++) {
            char c = lx->f->data[ds + i];
            if (c == '_') continue;
            int d = (c <= '9') ? c - '0' : ((c | 32) - 'a' + 10);
            if (v > (UINT64_MAX - (uint64_t)d) / 16) overflow = true;
            v = v * 16 + (uint64_t)d;
        }
        if (overflow)
            lex_err(lx, line, col, "hexadecimal literal is too large for `number` (64-bit).");
        push_tok(lx, T_INT, line, col, off, lx->pos - off);
        lx->out->items[lx->out->len - 1].ival = overflow ? UINT64_MAX : v;
        return;
    }

    /* decimal integer part: one full [0-9_] run */
    size_t ds = lx->pos;
    while (!at_end(lx) && ((peek(lx) >= '0' && peek(lx) <= '9') || peek(lx) == '_'))
        advance(lx);
    size_t dn = lx->pos - ds;

    /* decimal point + fraction => decimal literal */
    if (!at_end(lx) && peek(lx) == '.' && peek2(lx) >= '0' && peek2(lx) <= '9') {
        advance(lx); /* . */
        while (!at_end(lx) && ((peek(lx) >= '0' && peek(lx) <= '9') || peek(lx) == '_')) advance(lx);
        /* parse double */
        char tmp[128];
        size_t n = lx->pos - off;
        size_t m = 0;
        for (size_t i = 0; i < n && m < sizeof tmp - 1; i++)
            if (lx->f->data[off + i] != '_') tmp[m++] = lx->f->data[off + i];
        tmp[m] = 0;
        push_tok(lx, T_DEC, line, col, off, lx->pos - off);
        lx->out->items[lx->out->len - 1].dval = strtod(tmp, NULL);
        return;
    }

    if (dn == 0) {
        lex_err(lx, line, col, "unexpected character `%c`.", peek(lx));
        advance(lx);
        return;
    }

    if (!underscores_ok(lx->f->data + ds, dn))
        lex_err(lx, line, col, "misplaced `_` in the number literal (group digits like `1_000_000`).");

    uint64_t v = 0; bool overflow = false;
    for (size_t i = 0; i < dn; i++) {
        char c = lx->f->data[ds + i];
        if (c == '_') continue;
        int d = c - '0';
        if (v > (UINT64_MAX - (uint64_t)d) / 10) overflow = true;
        v = v * 10 + (uint64_t)d;
    }
    if (overflow)
        lex_err(lx, line, col, "number literal is too large for `number` (64-bit).");
    push_tok(lx, T_INT, line, col, off, lx->pos - off);
    lx->out->items[lx->out->len - 1].ival = overflow ? UINT64_MAX : v;
}

static void lex_text(Lexer *lx) {
    size_t line = lx->line, col = lx->col, off = lx->pos;
    advance(lx); /* opening quote */
    Buf b; buf_init(&b);
    for (;;) {
        if (at_end(lx) || peek(lx) == '\n') {
            lex_err(lx, line, col, "unterminated text literal (missing closing `\"`).");
            break;
        }
        char c = peek(lx);
        if (c == '"') { advance(lx); break; }
        if (c == '\\') {
            advance(lx);
            if (at_end(lx)) { lex_err(lx, line, col, "unterminated text literal."); break; }
            char e = peek(lx);
            switch (e) {
            case 'n': buf_putc(&b, '\n'); break;
            case 't': buf_putc(&b, '\t'); break;
            case 'r': buf_putc(&b, '\r'); break;
            case '0': buf_putc(&b, '\0'); break;
            case '\\': buf_putc(&b, '\\'); break;
            case '"': buf_putc(&b, '"'); break;
            default:
                lex_err(lx, lx->line, lx->col,
                        "unknown escape `\\%c` in text literal (supported: \\n \\t \\r \\0 \\\\ \\\").", e);
                buf_putc(&b, e);
                break;
            }
            advance(lx);
        } else {
            buf_putc(&b, c);
            advance(lx);
        }
    }
    push_tok(lx, T_TEXT, line, col, off, lx->pos - off);
    Tok *t = &lx->out->items[lx->out->len - 1];
    t->slen = b.len;
    t->text = ok_xstrndup(b.data ? b.data : "", b.len);
    buf_free(&b);
}

static void lex_ident(Lexer *lx) {
    size_t line = lx->line, col = lx->col, off = lx->pos;
    while (!at_end(lx) && ((peek(lx) >= 'A' && peek(lx) <= 'Z') ||
                           (peek(lx) >= 'a' && peek(lx) <= 'z') ||
                           (peek(lx) >= '0' && peek(lx) <= '9') ||
                           peek(lx) == '_'))
        advance(lx);
    size_t n = lx->pos - off;
    const char *s = lx->f->data + off;

    TokKind kw;
    if (kw_lookup(s, n, &kw)) {
        push_tok(lx, kw, line, col, off, n);
        if (kw == T_KW_RESERVED)
            lx->out->items[lx->out->len - 1].text = ok_xstrndup(s, n);
        return;
    }
    push_tok(lx, T_IDENT, line, col, off, n);
    lx->out->items[lx->out->len - 1].text = ok_xstrndup(s, n);
}

TokList *lex_file(SourceFile *f, DiagEngine *de) {
    Lexer lx;
    lx.f = f; lx.de = de;
    lx.pos = 0; lx.line = 1; lx.col = 1; lx.paren_depth = 0;
    lx.out = ok_xmalloc(sizeof *lx.out);
    lx.out->items = NULL; lx.out->len = lx.out->cap = 0;
    lx.out->arena = NULL; /* payloads are individually malloc'd; freed by toklist_free */

    while (!at_end(&lx)) {
        char c = peek(&lx);
        size_t line = lx.line, col = lx.col, off = lx.pos;

        if (c == ' ' || c == '\t' || c == '\r') { advance(&lx); continue; }

        if (c == '\n') {
            advance(&lx);
            if (lx.paren_depth == 0)
                push_tok(&lx, T_NL, line, col, off, 1);
            continue;
        }

        if (c == '#') { /* comment to end of line (spec §1.3) */
            while (!at_end(&lx) && peek(&lx) != '\n') advance(&lx);
            continue;
        }

        if (c == '"') { lex_text(&lx); continue; }

        if ((c >= '0' && c <= '9') ||
            (c == '.' && peek2(&lx) >= '0' && peek2(&lx) <= '9')) {
            if (c == '.') {
                lex_err(&lx, line, col, "a decimal literal needs a digit before the `.` (write `0.%c`).", peek2(&lx));
                advance(&lx);
            } else {
                lex_number(&lx);
            }
            continue;
        }

        if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || c == '_') {
            lex_ident(&lx);
            continue;
        }

        switch (c) {
        case '+': advance(&lx); push_tok(&lx, T_PLUS, line, col, off, 1); break;
        case '*': advance(&lx); push_tok(&lx, T_STAR, line, col, off, 1); break;
        case '/': advance(&lx); push_tok(&lx, T_SLASH, line, col, off, 1); break;
        case '%': advance(&lx); push_tok(&lx, T_PERCENT, line, col, off, 1); break;
        case '-':
            advance(&lx);
            if (!at_end(&lx) && peek(&lx) == '>') { advance(&lx); push_tok(&lx, T_ARROW, line, col, off, 2); }
            else push_tok(&lx, T_MINUS, line, col, off, 1);
            break;
        case '=':
            advance(&lx);
            if (!at_end(&lx) && peek(&lx) == '=') { advance(&lx); push_tok(&lx, T_EQEQ, line, col, off, 2); }
            else push_tok(&lx, T_EQ, line, col, off, 1);
            break;
        case '!':
            advance(&lx);
            if (!at_end(&lx) && peek(&lx) == '=') { advance(&lx); push_tok(&lx, T_BANGEQ, line, col, off, 2); }
            else {
                lex_err(&lx, line, col, "unexpected `!` — Okular spells logical negation `not`.");
                push_tok(&lx, T_KW_NOT, line, col, off, 1);
            }
            break;
        case '<':
            advance(&lx);
            if (!at_end(&lx) && peek(&lx) == '=') { advance(&lx); push_tok(&lx, T_LE, line, col, off, 2); }
            else push_tok(&lx, T_LT, line, col, off, 1);
            break;
        case '>':
            advance(&lx);
            if (!at_end(&lx) && peek(&lx) == '=') { advance(&lx); push_tok(&lx, T_GE, line, col, off, 2); }
            else push_tok(&lx, T_GT, line, col, off, 1);
            break;
        case '.': advance(&lx); push_tok(&lx, T_DOT, line, col, off, 1); break;
        case ',': advance(&lx); push_tok(&lx, T_COMMA, line, col, off, 1); break;
        case '(': advance(&lx); push_tok(&lx, T_LPAREN, line, col, off, 1); lx.paren_depth++; break;
        case ')': advance(&lx); push_tok(&lx, T_RPAREN, line, col, off, 1);
            if (lx.paren_depth) lx.paren_depth--;
            else lex_err(&lx, line, col, "unmatched `)`.");
            break;
        case '{': advance(&lx); push_tok(&lx, T_LBRACE, line, col, off, 1); break;
        case '}': advance(&lx); push_tok(&lx, T_RBRACE, line, col, off, 1); break;
        case '[': advance(&lx); push_tok(&lx, T_LBRACKET, line, col, off, 1); lx.paren_depth++; break;
        case ']': advance(&lx); push_tok(&lx, T_RBRACKET, line, col, off, 1);
            if (lx.paren_depth) lx.paren_depth--;
            else lex_err(&lx, line, col, "unmatched `]`.");
            break;
        default: {
            unsigned char u = (unsigned char)c;
            lex_err(&lx, line, col, "unexpected byte 0x%02X in source (Okular sources are UTF-8; this byte does not start a token).", u);
            advance(&lx);
        }
        }
    }

    /* a stray T_NL at the very end is harmless; ensure EOF token exists */
    push_tok(&lx, T_EOF, lx.line, lx.col, lx.pos, 0);
    return lx.out;
}

void toklist_free(TokList *t) {
    if (!t) return;
    for (size_t i = 0; i < t->len; i++)
        free(t->items[i].text);
    free(t->items);
    free(t);
}
