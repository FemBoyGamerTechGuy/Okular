/* parser.h — recursive descent parser (spec §16, brief §30). */
#ifndef OK_PARSER_H
#define OK_PARSER_H

#include "ok.h"
#include "ok/lexer.h"
#include "ok/ast.h"
#include "ok/diag.h"

/* Parses a token stream into an A_FILE node (arena-owned).
 * Diagnostics are recorded in `de` with recovery (brief §43). */
Node *parse_file_tokens(TokList *toks, SourceFile *f, DiagEngine *de, Arena *ar);

/* seed the (process-wide) struct-name registry from one file's tokens;
 * the project loader calls this for every module before parsing any */
void parser_register_struct_names(TokList *toks);

/* the shared placeholder for a named struct/union type (spec §8.3);
 * the machine-AST deserializer maps `T n:Name` records through this so
 * reconstructed trees reference the same interned types as C parses */
OkType parser_named_type_public(const char *name);

/* every registered struct/union name; the --selfhost-parse bridge passes
 * them to the Okular parser so cross-file references resolve */
void parser_named_type_names(Vec *out);

#endif /* OK_PARSER_H */
