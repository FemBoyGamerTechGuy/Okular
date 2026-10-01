/* selfhost_bridge.c — consume the Okular-written lexer's token stream (M4).
 *
 * The compiled selfhost/lexer program takes one argument (a .ok path) and
 * writes the machine token stream of ok/selfhost.h's protocol to stdout.
 * This file spawns it, parses the stream back into Tok records, and
 * constructs the payloads the C pipeline expects: identifier names,
 * integer literal values (hex/underscores mirrored from lexer.c), decimal
 * values, and unescaped text literal bytes. The scanning itself — the
 * actual lexing — runs in Okular.
 */
#define _POSIX_C_SOURCE 200809L
#include "ok/selfhost.h"
#include "ok/util.h"
#include "ok/parser.h"
#include "ok/ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

#ifndef PATH_MAX
#define PATH_MAX 4096
#endif

static char g_lex_bin[PATH_MAX];

void selfhost_set_lexer(const char *binary_path) {
    if (!binary_path || !binary_path[0]) { g_lex_bin[0] = 0; return; }
    snprintf(g_lex_bin, sizeof g_lex_bin, "%s", binary_path);
}

bool selfhost_enabled(void) {
    return g_lex_bin[0] != 0;
}

/* ---- protocol parsing over one captured buffer ---- */

typedef struct {
    const char *p, *end;
} Cursor;

/* one decimal number; skips a single following space */
static bool cur_num(Cursor *c, uint64_t *out) {
    uint64_t v = 0;
    bool any = false;
    while (c->p < c->end && *c->p >= '0' && *c->p <= '9') {
        v = v * 10 + (uint64_t)(*c->p - '0');
        any = true;
        c->p++;
    }
    if (!any) return false;
    *out = v;
    if (c->p < c->end && *c->p == ' ') c->p++; /* the record separator */
    return true;
}

static bool cur_bytes(Cursor *c, size_t n, const char **out) {
    if ((size_t)(c->end - c->p) < n) return false;
    *out = c->p;
    c->p += n;
    return true;
}

static bool cur_nl(Cursor *c) {
    if (c->p >= c->end || *c->p != '\n') return false;
    c->p++;
    return true;
}

/* ---- payload construction (mirrors bootstrap/src/lexer.c) ---- */

/* integer literal value from the raw spelling: 0x… hex or decimal, with
 * `_` grouping. Returns false on malformed digits (the Okular scanner
 * already guaranteed the shape; this is belt-and-braces). */
/* exported for the machine-AST deserializer (ast_serial.c): literal
 * payloads re-derive from raw spellings exactly as the token bridge does */
bool spell_int_value(const char *s, size_t n, uint64_t *out) {
    uint64_t v = 0;
    size_t i = 0;
    bool hex = false;
    if (n >= 2 && s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) {
        hex = true;
        i = 2;
        if (i == n) return false;
    }
    for (; i < n; i++) {
        char ch = s[i];
        if (ch == '_') continue;
        int d;
        if (ch >= '0' && ch <= '9') d = ch - '0';
        else if (hex && ch >= 'a' && ch <= 'f') d = ch - 'a' + 10;
        else if (hex && ch >= 'A' && ch <= 'F') d = ch - 'A' + 10;
        else return false;
        if (v > (UINT64_MAX - (uint64_t)d) / (hex ? 16u : 10u)) return false;
        v = v * (hex ? 16u : 10u) + (uint64_t)d;
    }
    *out = v;
    return true;
}

/* decimal literal value: strip `_`, strtod */
double spell_dec_value(const char *s, size_t n) {
    char tmp[128];
    size_t m = 0;
    for (size_t i = 0; i < n && m < sizeof tmp - 1; i++)
        if (s[i] != '_') tmp[m++] = s[i];
    tmp[m] = 0;
    return strtod(tmp, NULL);
}

/* text literal payload: strip the quotes, process the escapes; returns
 * NULL (no allocation) when the record is not a quoted literal */
char *spell_text_unescape(const char *s, size_t n, size_t *out_len) {
    if (n < 2 || s[0] != '"' || s[n - 1] != '"') return NULL;
    Buf b; buf_init(&b);
    for (size_t i = 1; i + 1 < n; i++) {
        char ch = s[i];
        if (ch == '\\' && i + 2 < n) {
            char e = s[i + 1];
            switch (e) {
            case 'n': buf_putc(&b, '\n'); break;
            case 't': buf_putc(&b, '\t'); break;
            case 'r': buf_putc(&b, '\r'); break;
            case '0': buf_putc(&b, '\0'); break;
            case '\\': buf_putc(&b, '\\'); break;
            case '"': buf_putc(&b, '"'); break;
            default: buf_putc(&b, e); break; /* the scanner kept it raw */
            }
            i++;
        } else {
            buf_putc(&b, ch);
        }
    }
    char *bytes = ok_xstrndup(b.data ? b.data : "", b.len);
    *out_len = b.len;
    buf_free(&b);
    return bytes;
}

/* ---- the bridge ---- */

static Diag *sh_err(DiagEngine *de, SourceFile *f, size_t line, size_t col,
                    const char *fmt, ...) {
    char buf[512];
    va_list ap; va_start(ap, fmt);
    vsnprintf(buf, sizeof buf, fmt, ap);
    va_end(ap);
    return diag_emit(de, DIAG_ERROR, f, line, col, "%s", buf);
}

TokList *selfhost_lex_file(SourceFile *f, const char *fs_path, DiagEngine *de) {
    TokList *out = ok_xmalloc(sizeof *out);
    out->items = NULL; out->len = out->cap = 0;
    out->arena = NULL;

    /* spawn '<binary>' '<path>' — quoting both paths */
    char cmd[PATH_MAX * 2 + 8];
    snprintf(cmd, sizeof cmd, "'%s' '%s'", g_lex_bin, fs_path);
    FILE *fp = popen(cmd, "r");
    if (!fp) {
        sh_err(de, f, 1, 1, "cannot run the self-hosted lexer `%s`.", g_lex_bin);
        return out;
    }

    Buf data; buf_init(&data);
    char chunk[4096];
    size_t got;
    while ((got = fread(chunk, 1, sizeof chunk, fp)) > 0)
        buf_put(&data, chunk, got);
    int rc = pclose(fp);
    if (rc != 0) {
        sh_err(de, f, 1, 1, "the self-hosted lexer exited with status %d (%s).",
               rc, g_lex_bin);
        buf_free(&data);
        return out;
    }

    Cursor c = { data.data ? data.data : "", data.data ? data.data + data.len : NULL };

    bool saw_eof = false;
    while (c.p < c.end) {
        uint64_t k, l, cc, s;
        if (!cur_num(&c, &k) || !cur_num(&c, &l) || !cur_num(&c, &cc) || !cur_num(&c, &s)) {
            sh_err(de, f, 1, 1, "self-hosted lexer protocol error: expected a token record.");
            break;
        }
        if (s > (1u << 20)) {
            sh_err(de, f, 1, 1, "self-hosted lexer protocol error: spelling length %llu is not sane.",
                   (unsigned long long)s);
            break;
        }
        const char *spell = "";
        if (s > 0 && !cur_bytes(&c, (size_t)s, &spell)) {
            sh_err(de, f, 1, 1, "self-hosted lexer protocol error: stream ended inside a spelling.");
            break;
        }
        if (!cur_nl(&c)) {
            sh_err(de, f, 1, 1, "self-hosted lexer protocol error: missing record terminator.");
            break;
        }

        if (k == 99) {
            sh_err(de, f, (size_t)l, (size_t)cc,
                   "the self-hosted lexer rejected byte %.*s in the source.",
                   (int)s, spell);
            continue;
        }
        if (k > (uint64_t)T_KW_RESERVED) {
            sh_err(de, f, (size_t)l, (size_t)cc,
                   "self-hosted lexer protocol error: unknown token kind %llu.",
                   (unsigned long long)k);
            continue;
        }

        /* grow the list */
        if (out->len == out->cap) {
            out->cap = out->cap ? out->cap * 2 : 256;
            out->items = ok_xrealloc(out->items, out->cap * sizeof(Tok));
        }
        Tok *t = &out->items[out->len++];
        memset(t, 0, sizeof *t);
        t->kind = (TokKind)k;
        t->line = (size_t)l;
        t->col = (size_t)cc;
        t->off = 0;
        t->len = 1;

        if (t->kind == T_EOF) {
            saw_eof = true;
            break; /* nothing follows by protocol */
        }
        if (t->kind == T_IDENT || t->kind == T_KW_RESERVED) {
            t->text = ok_xstrndup(spell, (size_t)s);
        } else if (t->kind == T_INT) {
            uint64_t v = 0;
            if (!spell_int_value(spell, (size_t)s, &v)) {
                sh_err(de, f, t->line, t->col, "self-hosted lexer sent a malformed number literal.");
            }
            t->ival = v;
        } else if (t->kind == T_DEC) {
            t->dval = spell_dec_value(spell, (size_t)s);
        } else if (t->kind == T_TEXT) {
            size_t ulen = 0;
            char *bytes = spell_text_unescape(spell, (size_t)s, &ulen);
            if (!bytes) {
                sh_err(de, f, t->line, t->col, "self-hosted lexer sent a malformed text literal.");
                bytes = ok_xstrndup("", 0);
            }
            t->text = bytes;
            t->slen = ulen;
        }
    }

    if (!saw_eof && de->errors == 0) {
        sh_err(de, f, 1, 1, "self-hosted lexer protocol error: stream ended without an end-of-file token.");
    }
    buf_free(&data);
    return out;
}

/* ---- the parser bridge (--selfhost-parse, M4) ----
 *
 * Spawns the compiled selfhost/parser program once per file:
 *     <binary> <file.ok> --names <struct/union names...>
 * reads its machine AST stream, and rebuilds the Node tree through
 * ast_deserialize. The names come from the parser's process-wide
 * registry (seeded from every module before any is parsed, spec §8.3),
 * so struct types resolve across files exactly as in a C parse. */

static char g_parse_bin[PATH_MAX];

void selfhost_set_parser(const char *binary_path) {
    if (!binary_path || !binary_path[0]) { g_parse_bin[0] = 0; return; }
    snprintf(g_parse_bin, sizeof g_parse_bin, "%s", binary_path);
}

bool selfhost_parse_enabled(void) {
    return g_parse_bin[0] != 0;
}

static char *sh_read_stream(const char *cmd, size_t *out_len) {
    FILE *fp = popen(cmd, "r");
    if (!fp) return NULL;
    Buf data;
    buf_init(&data);
    char chunk[4096];
    size_t got;
    while ((got = fread(chunk, 1, sizeof chunk, fp)) > 0)
        buf_put(&data, chunk, got);
    int rc = pclose(fp);
    if (rc != 0) {
        buf_free(&data);
        return NULL;
    }
    *out_len = data.len;
    return data.data ? data.data : ok_xstrdup("");
}

Node *selfhost_parse_file(SourceFile *f, const char *fs_path, DiagEngine *de, Arena *ar) {
    /* collect the pre-registered struct/union names for --names */
    Vec names;
    vec_init(&names);
    parser_named_type_names(&names);

    Buf cmd;
    buf_init(&cmd);
    buf_printf(&cmd, "'%s' '%s'", g_parse_bin, fs_path);
    if (names.len > 0) {
        buf_puts(&cmd, " --names");
        for (size_t i = 0; i < names.len; i++)
            buf_printf(&cmd, " '%s'", (const char *)names.items[i]);
    }
    for (size_t i = 0; i < names.len; i++) free(names.items[i]);
    vec_free(&names);

    size_t len = 0;
    char *data = sh_read_stream(cmd.data ? cmd.data : "", &len);
    buf_free(&cmd);
    if (!data) {
        diag_emit(de, DIAG_ERROR, f, 1, 1,
                  "cannot run the self-hosted parser `%s`.", g_parse_bin);
        return NULL;
    }

    Node *tree = ast_deserialize(data, len, f, de, ar);
    free(data);
    return tree;
}
