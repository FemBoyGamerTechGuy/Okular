/* sema.h — semantic analysis (brief §32).
 *
 * Two phases:
 *   collect: build scopes/symbols for every module (order-independent)
 *   check:   type-check bodies, annotate AST nodes for IR
 */
#ifndef OK_SEMA_H
#define OK_SEMA_H

#include "ok.h"
#include "ok/diag.h"
#include "ok/project.h"
#include "ok/symtab.h"

/* Runs both phases over the whole project. Returns false if any REQUIRED
 * module has errors (optional modules' failures were downgraded to warnings
 * by the project loader). */
bool sema_run(OkProject *p, DiagEngine *de, const OkOptions *opt);

/* Suggestion helper: closest name within edit distance 2 (nice diagnostics). */
const char *ok_suggest_name(Scope *s, const char *name);

#endif /* OK_SEMA_H */
