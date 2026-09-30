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

#endif /* OK_PARSER_H */
