/* codegen.h — backend interface (brief §34).
 *
 * One backend implements this per target; codegen_x64.c is the x86-64
 * Linux implementation. Adding a target = adding a file + a --target flag.
 */
#ifndef OK_CODEGEN_H
#define OK_CODEGEN_H

#include "ok.h"
#include "ok/ir.h"

/* Emits assembly for one module to `out_path` (.s).
 * Returns false on I/O failure. */
bool codegen_module(IrModule *im, const char *out_path);

#endif /* OK_CODEGEN_H */
