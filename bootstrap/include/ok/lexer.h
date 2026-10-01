/* lexer.h — tokens + lexer (spec §1, brief §29). */
#ifndef OK_LEXER_H
#define OK_LEXER_H

#include "ok.h"
#include "ok/source.h"
#include "ok/diag.h"
#include "ok/util.h"

typedef enum {
    T_EOF = 0,
    T_NL,          /* statement separator; suppressed inside ( ) and [ ] */
    T_IDENT,
    T_INT,         /* number literal (u64 payload) */
    T_DEC,         /* decimal literal (double payload) */
    T_TEXT,        /* text literal (unescaped bytes + slen) */
    /* operators */
    T_PLUS, T_MINUS, T_STAR, T_SLASH, T_PERCENT,
    T_EQ, T_EQEQ, T_BANGEQ, T_LT, T_LE, T_GT, T_GE,
    T_ARROW,       /* -> */
    T_DOT, T_COMMA, T_AMP,
    T_LPAREN, T_RPAREN, T_LBRACE, T_RBRACE, T_LBRACKET, T_RBRACKET,
    /* active keywords */
    T_KW_TYPE, T_KW_FUNCTION, T_KW_STRUCT, T_KW_WHEN, T_KW_ELSE,
    T_KW_LOOP, T_KW_FROM, T_KW_TO, T_KW_UNTIL,
    T_KW_BREAK, T_KW_CONTINUE, T_KW_RETURN,
    T_KW_PRINT, T_KW_WRITE, T_KW_TRUE, T_KW_FALSE,
    T_KW_AND, T_KW_OR, T_KW_NOT, T_KW_END,
    /* memory keywords (0.4, spec §12) */
    T_KW_ALLOC, T_KW_RELEASE, T_KW_NULL,
    /* overlap keyword (0.7, spec §8.5) */
    T_KW_UNION,
    /* reserved for designed-but-unimplemented features (spec §1.5) */
    T_KW_RESERVED,
} TokKind;

typedef struct Tok {
    TokKind kind;
    size_t line, col;    /* 1-based */
    size_t off, len;     /* byte span in source */
    char *text;          /* IDENT name / TEXT payload (unescaped) / RESERVED word */
    size_t slen;         /* TEXT payload length */
    uint64_t ival;       /* INT payload (also directive values) */
    double dval;         /* DEC payload */
} Tok;

typedef struct TokList {
    Tok *items;
    size_t len, cap;
    Arena *arena;        /* owns token payloads */
} TokList;

const char *tok_kind_name(TokKind k);

/* Tokenize one file. Always returns a list (possibly empty of useful tokens);
 * errors are recorded in `de` — check de->errors afterwards. */
TokList *lex_file(SourceFile *f, DiagEngine *de);

void toklist_free(TokList *t);

#endif /* OK_LEXER_H */
