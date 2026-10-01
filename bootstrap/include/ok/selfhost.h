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

#endif /* OK_SELFHOST_H */
