/* selfhost.h — bridge to the Okular-written lexer (M4, docs/roadmap.md).
 *
 * `selfhost/lexer` is the tokenizer written in Okular. When enabled
 * (--selfhost-lex <binary>), every project file is tokenized by that
 * compiled Okular program instead of bootstrap/src/lexer.c: the driver
 * spawns the binary with the source path as its argument and consumes
 * the machine token stream it writes to stdout.
 *
 * Stream protocol (one record per token, byte-exact):
 *     K SP L SP C SP S SP <S raw bytes> NL
 * K/L/C are the token kind, line, column; S is the spelling byte count
 * (0 for punctuation and keywords; the raw spelling for identifiers,
 * number literals, text literals — quotes and escapes included — and
 * reserved words). K = 99 marks an invalid byte the scanner rejected.
 * Kind numbers are the bootstrap lexer's TokKind order (they are the
 * same by construction: selfhost/lexer/src/lexer.ok §K_*).
 */
#ifndef OK_SELFHOST_H
#define OK_SELFHOST_H

#include "ok.h"
#include "ok/lexer.h"
#include "ok/diag.h"
#include "ok/ast.h"
#include "ok/util.h"

/* Select the Okular-written lexer binary (NULL/empty disables the bridge
 * and lexing stays in C). Called by the driver before project load. */
void selfhost_set_lexer(const char *binary_path);

bool selfhost_enabled(void);

/* Tokenize one file through the Okular-written lexer. `fs_path` is the
 * file's real filesystem path (SourceFile.path may carry only a display
 * name — the spawned program needs a path that actually opens).
 * Always returns a TokList (errors are recorded in `de`); on failure the
 * list may be shorter than the file requires — compilation stops on the
 * errors. */
TokList *selfhost_lex_file(SourceFile *f, const char *fs_path, DiagEngine *de);

/* ---- machine AST protocol (M4, --selfhost-parse) ----
 *
 * The Okular-written parser (selfhost/parser) lexes AND parses one .ok
 * file, then serializes its AST as a record stream (docs/architecture.md):
 *   E <line> <col> <len> <msg> NL   parse error (module is broken)
 *   N <kind> <line> <col> NL        node header
 *   I <int> NL                      integer payload
 *   D <spelling> NL                 decimal literal spelling
 *   S <len> <bytes> NL              raw string payload (spellings, names)
 *   P <n> NL + n S                  dotted path
 *   T s:<name> | T p +elem | T a:<n> +elem | T n:<name> NL
 *   L <n> NL + n nodes (or S for language columns)
 *   X NL                            nil child (recovery)
 * spell_int_value / spell_dec_value / spell_text_unescape turn the raw
 * spellings back into the payloads the C parser would have produced. */
bool spell_int_value(const char *s, size_t n, uint64_t *out);
double spell_dec_value(const char *s, size_t n);
char *spell_text_unescape(const char *s, size_t n, size_t *out_len);

/* C-parse-tree -> record stream (differential verification) and back
 * (the real bridge). Both live in bootstrap/src/ast_serial.c. */
void ast_serialize(Node *file_node, Buf *out);
Node *ast_deserialize(const char *data, size_t len, SourceFile *f,
                      DiagEngine *de, Arena *ar);

/* set the parser bridge binary (--selfhost-parse); NULL disables it */
void selfhost_set_parser(const char *binary_path);
bool selfhost_parse_enabled(void);

/* parse one file through the Okular-written parser: spawn the binary with
 * the project's pre-registered struct names, read the machine AST stream,
 * rebuild the Node tree (arena-owned). Parse errors become diagnostics;
 * the returned node is NULL only on protocol failure. */
Node *selfhost_parse_file(SourceFile *f, const char *fs_path, DiagEngine *de, Arena *ar);

#endif /* OK_SELFHOST_H */
