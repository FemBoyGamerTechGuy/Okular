/* ir.h — typed stack IR (brief §33).
 *
 * A typed stack machine between sema and codegen: every instruction's
 * effect on the operand stack is known, so the backend never guesses.
 * ir_fold() is the first optimization pass (constant folding, spec §15).
 */
#ifndef OK_IR_H
#define OK_IR_H

#include "ok.h"
#include "ok/ast.h"
#include "ok/project.h"
#include "ok/symtab.h"

typedef enum {
    I_CONST_INT,     /* i: u64 value          -> number      */
    I_CONST_DEC,     /* d: double value       -> decimal     */
    I_CONST_BOOL,    /* b                     -> bool        */
    I_CONST_TEXT,    /* text_idx              -> text        */
    /* text operations (0.9, spec §4.5): operands and results are ordinary
     * stack values; BYTE and SLICE bounds-trap like array indexing */
    I_TEXT_LEN,      /* (text)                -> number      */
    I_TEXT_BYTE,     /* (text, index)         -> uint8       */
    I_TEXT_SLICE,    /* (text, from, to)      -> text [from, to) */
    I_LOAD_LOCAL,    /* slot                  -> type        */
    I_STORE_LOCAL,   /* slot  (pops)                            */
    I_LOAD_GLOBAL,   /* sym: Symbol*          -> type        */
    I_STORE_GLOBAL,  /* sym: Symbol* (pops)                     */
    I_CONV,          /* type=src, type2=dst; pops 1 -> converted */
    I_BINOP,         /* op + type; pops 2 -> result            */
    I_UNOP,          /* uop + type                             */
    I_LABEL,         /* label id                               */
    I_JMP,           /* label id                               */
    I_JMPF,          /* label id (pops bool)                   */
    I_CALL,          /* sym: FuncInfo*, nargs; pops args       */
    I_WRITE,         /* type; pops 1                           */
    I_PRINT,         /*                                        */
    I_RETURN,        /* optional value on stack               */
    I_POP,           /* discard top                            */
    /* arrays (spec §8.4/9): address-forming + memory ops.
     * Array-typed expressions evaluate to an ADDRESS on the operand stack;
     * scalars evaluate to values. Bounds are always checked. */
    I_ADDR_LOCAL,    /* slot + i:offset  -> address of slot+off  */
    I_ADDR_GLOBAL,   /* sym + i:offset   -> address of glob+off  */
    I_INDEX,         /* type: array; pop index, pop base -> elem addr (checked) */
    I_LOAD_AT,       /* type; pop addr -> value at addr          */
    I_STORE_AT,      /* type; pop value, pop addr                */
    I_COPY,          /* i: bytes; pop src addr, pop dst addr     */
    /* pointers + manual memory (spec §12, 0.4) */
    I_ALLOC,         /* type: pointee; pop count -> ptr (rt_alloc)   */
    I_RELEASE,       /* pop ptr -> (rt_release; null is a no-op)     */
    I_PTRCHK,        /* pop ptr, trap if null, push back            */
    I_PTR_SCALE,     /* type: ptr<T>; pop index, pop ptr -> elem addr */
    I_PTR_DIFF,      /* type: ptr<T>; pop q, pop p -> number (p-q)/size(T) */
    I_ADDOFF,        /* i: offset; pop addr -> addr+offset (struct fields) */
} IrKind;

typedef struct IrInst {
    IrKind kind;
    OkType type;        /* operand/result type where relevant */
    OkType type2;       /* I_CONV: destination type            */
    uint64_t i;
    double d;
    bool b;
    int slot;
    int label;
    int text_idx;
    BinOp op;
    UnOp uop;
    void *sym;          /* Symbol* or FuncInfo* */
    int nargs;
    size_t line, col;
} IrInst;

typedef struct IrSlot {
    Symbol *sym;        /* NULL-safe: loop vars also carry symbols */
    OkType type;
} IrSlot;

typedef struct IrFunc {
    FuncInfo *fi;
    IrInst *insts;
    size_t n, cap;
    IrSlot *slots;
    size_t nslots, slots_cap;
    int nlabels;
} IrFunc;

typedef struct IrText {
    char *bytes;
    size_t len;
} IrText;

typedef struct IrModule {
    OkModule *mod;
    Vec funcs;          /* IrFunc* */
    Vec globals;        /* Symbol* in declaration order */
    IrText *texts;
    size_t ntexts, texts_cap;
} IrModule;

/* Builds IR for one module (required modules only). Returns NULL if the
 * module is broken or has no code. */
IrModule *ir_build_module(OkModule *m);

/* Constant folding pass (in place). */
void ir_fold(IrFunc *f);

/* --dump-ir */
void ir_dump(IrModule *im);

void ir_module_free(IrModule *im);

#endif /* OK_IR_H */
