/* driver.h — compile pipeline orchestration (docs/architecture.md §1). */
#ifndef OK_DRIVER_H
#define OK_DRIVER_H

#include "ok.h"
#include "ok/diag.h"

/* Full compile of an Okular project per OkOptions.
 * Exit-code semantics: 0 ok, 1 compile errors, 2 usage/internal (main.c maps). */
int driver_compile(OkOptions *opt);

#endif /* OK_DRIVER_H */
