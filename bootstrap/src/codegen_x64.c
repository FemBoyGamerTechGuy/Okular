/* codegen_x64.c — x86-64 Linux backend (brief §34, docs/architecture.md §3.5).
 *
 * Okular Internal ABI v1 (v0 + arrays, spec §8.4):
 *   - args 1..6 in rdi, rsi, rdx, rcx, r8, r9 (integer registers)
 *   - `decimal` travels as raw bits in integer registers/stack slots,
 *     computed in xmm0/xmm1 locally
 *   - `text` args: address of a 16-byte (ptr, len) pair in one register
 *   - `array` args: the CALLER copies the array into its private scratch
 *     block and passes the copy's address in one register (value semantics);
 *     the callee's prologue copies from that address into its own slot
 *   - returns: scalar/decimal-bits in rax; text pair in rax (ptr) + rdx (len)
 *   - rbx, r12..r15 callee-saved; rbx is the alignment scratch across calls
 *   - calls align rsp to 16 via `mov rbx,rsp / and rsp,-16 / mov rsp,rbx`
 *
 * Frame layout (rbp-relative, growing downward):
 *   [rbp] frame link        [rbp-locals)   local slots (arrays included)
 *   outgoing arg area 96B   [rbp-oa_base, rbp-oa_base+96)
 *   array-arg scratch       [rbp-scratch_base, rbp-oa_base)
 *
 * The emitted program is freestanding: no libc, entry `_start` (runtime/),
 * syscalls only. Correctness before speed (spec §15): the operand stack is
 * the machine stack; the optimization milestone will lower through regs.
 */
#include "ok/codegen.h"

static const char *arg_regs[6] = { "rdi", "rsi", "rdx", "rcx", "r8", "r9" };

/* ---------------- per-function layout ---------------- */

typedef struct {
    Buf *out;
    IrModule *im;
    IrFunc *f;
    size_t func_seq;        /* label namespace */
    size_t *offsets;        /* slot i -> rbp-relative byte offset (negative) */
    size_t locals_bytes;
    size_t oa_base;         /* outgoing-arg area: [rbp-oa_base, rbp-oa_base+96) */
    size_t scratch_base;    /* array-arg scratch: [rbp-scratch_base, rbp-oa_base) */
    size_t scratch_bytes;
    size_t trap_seq;        /* bounds-trap label sequence */
    size_t div_seq;         /* division-guard label sequence */
} FnCtx;

/* lea rax, [rbp ± disp] with sign-aware formatting */
static void lea_rbp(Buf *o, long disp) {
    if (disp < 0)      buf_printf(o, "    lea rax, [rbp-%ld]\n", -disp);
    else if (disp > 0) buf_printf(o, "    lea rax, [rbp+%ld]\n", disp);
    else               buf_puts(o, "    mov rax, rbp\n");
}

static size_t slot_bytes(IrSlot *s) {
    /* every slot is 8-byte granular: sub-word scalars (bool, int8, ...) are
     * padded — the padding is never observable through the language */
    size_t b = ty_bytes(s->type);
    return (b + 7) & ~(size_t)7;
}

/* value push/pop macros (emit text) */
static void push_rax(Buf *o)      { buf_puts(o, "    push rax\n"); }
static void push_xmm0(Buf *o)     { buf_puts(o, "    sub rsp, 8\n    movsd QWORD PTR [rsp], xmm0\n"); }
static void push_pair_rax_rdx(Buf *o) { buf_puts(o, "    push rdx\n    push rax\n"); }
static void pop_rax(Buf *o)       { buf_puts(o, "    pop rax\n"); }
static void pop_rdx(Buf *o)       { buf_puts(o, "    pop rdx\n"); }
static void pop_xmm0(Buf *o)      { buf_puts(o, "    movsd xmm0, QWORD PTR [rsp]\n    add rsp, 8\n"); }
static void pop_pair_rax_rdx(Buf *o) { buf_puts(o, "    pop rax\n    pop rdx\n"); }

/* aligned call: rbx is pushed around the sequence because callees (including
 * Okular functions, which use the same sequence) freely clobber rbx. */
static void call_aligned(Buf *o, const char *fn) {
    buf_puts(o, "    push rbx\n    mov rbx, rsp\n    and rsp, -16\n");
    buf_printf(o, "    call %s\n", fn);
    buf_puts(o, "    mov rsp, rbx\n    pop rbx\n");
}

/* ---- fixed-width integer support (spec §4.2) ----
 * Invariant: every integer value in a register / on the operand stack is the
 * 64-bit register representation of its semantic value — sign-extended for
 * signed types, zero-extended for unsigned ones. Arithmetic runs at 64 bits
 * and is re-encoded (truncating wrap) to the result type's width. */

/* re-encode rax to type t's width: shl/sar (signed) or shl/shr (unsigned) */
static void emit_reencode(Buf *o, OkType t) {
    if (!t || !ty_is_integer(t) || t->bits >= 64) return;
    int sh = 64 - t->bits;
    if (t->is_signed) {
        buf_printf(o, "    shl rax, %d\n    sar rax, %d\n", sh, sh);
    } else {
        buf_printf(o, "    shl rax, %d\n    shr rax, %d\n", sh, sh);
    }
}

/* load a scalar of type t into rax from [reg] at its natural width */
static void emit_load_at_rax(Buf *o, OkType t, const char *addr) {
    switch (ty_kind(t)) {
    case OK_BOOL:
    case OK_UINT8:  buf_printf(o, "    movzx rax, BYTE PTR [%s]\n", addr); break;
    case OK_INT8:   buf_printf(o, "    movsx rax, BYTE PTR [%s]\n", addr); break;
    case OK_UINT16: buf_printf(o, "    movzx rax, WORD PTR [%s]\n", addr); break;
    case OK_INT16:  buf_printf(o, "    movsx rax, WORD PTR [%s]\n", addr); break;
    case OK_UINT32: buf_printf(o, "    mov eax, DWORD PTR [%s]\n", addr); break; /* zero-extends */
    case OK_INT32:  buf_printf(o, "    movsxd rax, DWORD PTR [%s]\n", addr); break;
    default:        buf_printf(o, "    mov rax, QWORD PTR [%s]\n", addr); break; /* number/uint64/decimal bits */
    }
}

/* store rax into [reg] at type t's natural width */
static void emit_store_rax_at(Buf *o, OkType t, const char *addr) {
    switch (ty_kind(t)) {
    case OK_BOOL:
    case OK_UINT8:
    case OK_INT8:   buf_printf(o, "    mov BYTE PTR [%s], al\n", addr); break;
    case OK_UINT16:
    case OK_INT16:  buf_printf(o, "    mov WORD PTR [%s], ax\n", addr); break;
    case OK_UINT32:
    case OK_INT32:  buf_printf(o, "    mov DWORD PTR [%s], eax\n", addr); break;
    default:        buf_printf(o, "    mov QWORD PTR [%s], rax\n", addr); break;
    }
}

static void emit_inst(FnCtx *fc, IrInst *in);

/* ---------------- functions ---------------- */

static void gen_function(Buf *out, IrModule *im, IrFunc *f, size_t seq) {
    FnCtx fc;
    memset(&fc, 0, sizeof fc);
    fc.out = out;
    fc.im = im;
    fc.f = f;
    fc.func_seq = seq;

    /* slot offsets: locals occupy [rbp-locals_bytes, rbp) */
    fc.offsets = ok_xmalloc((f->nslots ? f->nslots : 1) * sizeof(size_t));
    size_t off = 0;
    for (size_t i = 0; i < f->nslots; i++) {
        off += slot_bytes(&f->slots[i]);
        fc.offsets[i] = off;
    }
    fc.locals_bytes = off;
    fc.oa_base = off + 96; /* 6 outgoing arg slots x 16 bytes */
    fc.scratch_base = fc.oa_base + 96;

    /* array-arg scratch: the largest total of array bytes any single call
     * site passes. One shared block is sound: a copy is written immediately
     * before its call, and inner calls have finished by then (their copies
     * are dead); two arrays in one call are laid out back to back. */
    size_t scratch = 0;
    for (size_t i = 0; i < f->n; i++) {
        if (f->insts[i].kind != I_CALL) continue;
        FuncInfo *cfi = (FuncInfo *)f->insts[i].sym;
        size_t need = 0;
        for (size_t k = 0; k < (size_t)f->insts[i].nargs && k < cfi->nparams; k++)
            if (ty_kind(cfi->param_types[k]) == OK_ARRAY || ty_is_record(cfi->param_types[k]))
                need += ty_bytes(cfi->param_types[k]);
        if (need > scratch) scratch = need;
    }
    fc.scratch_bytes = scratch;

    size_t frame = fc.scratch_base + fc.scratch_bytes;
    frame = (frame + 15) & ~(size_t)15;

    buf_printf(out, "\n    .globl %s\n%s:\n", f->fi->mangled, f->fi->mangled);
    buf_puts(out, "    push rbp\n    mov rbp, rsp\n");
    buf_printf(out, "    sub rsp, %zu\n", frame);

    /* store parameters into their slots (params are slots 0..n-1).
     *
     * ARGUMENT REGISTERS ARE SAVED FIRST: adopting one parameter can
     * clobber scratch registers (text uses rax/rdx, arrays use rsi/rdi/rcx)
     * that a LATER parameter still needs in its original argument register
     * — the third text parameter travels in rdx and used to crash exactly
     * here (found by the 0.9 text-op work; regression: text_local_layout) */
    if (f->fi->nparams > 0) {
        buf_puts(out, "    push rdi\n    push rsi\n    push rdx\n"
                      "    push rcx\n    push r8\n    push r9\n");
    }
    for (size_t k = 0; k < f->fi->nparams && k < 6; k++) {
        size_t o = fc.offsets[k];
        size_t so = (5 - k) * 8;  /* saved argument register k at [rsp+so] */
        if (ty_kind(f->fi->param_types[k]) == OK_ARRAY || ty_is_record(f->fi->param_types[k])) {
            /* the saved register holds the caller's copy: adopt it by value */
            buf_printf(out, "    mov r11, [rsp+%zu]\n", so);
            buf_puts(out, "    mov rsi, r11\n");
            buf_printf(out, "    lea rdi, [rbp-%zu]\n", o);
            buf_printf(out, "    mov rcx, %zu\n    rep movsb\n",
                       ty_bytes(f->fi->param_types[k]));
        } else if (f->fi->param_types[k] == ty_text) {
            /* the saved register holds the address of a (ptr,len) pair; the
             * slot's second word sits toward rbp (LOAD/STORE_LOCAL match) */
            buf_printf(out, "    mov r11, [rsp+%zu]\n", so);
            buf_puts(out, "    mov rax, [r11]\n    mov rdx, [r11+8]\n");
            buf_printf(out, "    mov [rbp-%zu], rax\n", o);
            buf_printf(out, "    mov [rbp-%zu], rdx\n", o - 8);
        } else {
            /* scalars (any width) travel extended: one full word */
            buf_printf(out, "    mov r11, [rsp+%zu]\n", so);
            buf_printf(out, "    mov [rbp-%zu], r11\n", o);
        }
    }
    if (f->fi->nparams > 0) {
        buf_puts(out, "    add rsp, 48\n");
    }

    for (size_t i = 0; i < f->n; i++)
        emit_inst(&fc, &f->insts[i]);

    /* implicit fall-off return: deterministic rax */
    buf_puts(out, "    xor eax, eax\n    leave\n    ret\n");
    free(fc.offsets);
}

/* ---------------- instruction emission ---------------- */

static void emit_call(FnCtx *fc, IrInst *in) {
    Buf *o = fc->out;
    FuncInfo *fi = (FuncInfo *)in->sym;
    size_t n = (size_t)in->nargs;

    /* args sit on the machine stack: arg1 on top (right-to-left evaluation).
     * outgoing-arg slots live below the locals at depth
     *   oa_base - k*16   (slot k, 16 bytes each, max 6)
     * and hold text pairs contiguously: [slot]=ptr, [slot-8]=len,
     * so `lea reg,[rbp-oa]` gives the callee a (ptr,len) pair pointer.
     *
     * array args arrive as an 8-byte SOURCE ADDRESS on the machine stack:
     * copy the array into this frame's scratch block (value semantics) and
     * hand the callee the copy's address (ABI v1, docs/architecture.md). */
    size_t stack_off = 0;  /* byte offset from rsp of arg1's slot */
    size_t scratch_off = 0; /* cumulative array-copy offset in the scratch */
    size_t arr_off[16];
    for (size_t k = 0; k < n && k < 16; k++) arr_off[k] = 0;
    for (size_t k = 0; k < n; k++) {
        OkType t = (k < fi->nparams) ? fi->param_types[k] : ty_number;
        if (ty_kind(t) == OK_ARRAY || ty_is_record(t)) {
            size_t bytes = ty_bytes(t);
            buf_printf(o, "    mov rax, [rsp+%zu]\n", stack_off);
            buf_puts(o, "    mov rsi, rax\n");
            buf_printf(o, "    lea rdi, [rbp-%zu]\n", fc->scratch_base - scratch_off);
            buf_printf(o, "    mov rcx, %zu\n    rep movsb\n", bytes);
            if (k < 16) arr_off[k] = scratch_off;
            scratch_off += bytes;
            stack_off += 8; /* the operand was an address */
            continue;
        }
        size_t w = (t == ty_text) ? 16 : 8; /* every scalar occupies one 8-byte
                                               machine word; text a pair */
        size_t oa = fc->oa_base - k * 16;
        buf_printf(o, "    mov rax, [rsp+%zu]\n", stack_off);
        buf_printf(o, "    mov [rbp-%zu], rax\n", oa);
        if (t == ty_text) {
            buf_printf(o, "    mov rdx, [rsp+%zu]\n", stack_off + 8);
            buf_printf(o, "    mov [rbp-%zu], rdx\n", oa - 8);
        }
        stack_off += w;
    }
    if (stack_off)
        buf_printf(o, "    add rsp, %zu\n", stack_off);

    /* load argument registers from the outgoing area / scratch */
    for (size_t k = 0; k < n && k < 6; k++) {
        OkType t = (k < fi->nparams) ? fi->param_types[k] : ty_number;
        size_t oa = fc->oa_base - k * 16;
        if (ty_kind(t) == OK_ARRAY || ty_is_record(t)) {
            buf_printf(o, "    lea %s, [rbp-%zu]\n", arg_regs[k],
                       fc->scratch_base - arr_off[k]);
            continue;
        }
        if (t == ty_text)
            buf_printf(o, "    lea %s, [rbp-%zu]\n", arg_regs[k], oa);
        else
            buf_printf(o, "    mov %s, [rbp-%zu]\n", arg_regs[k], oa);
    }

    /* align rsp to 16 across the call (SysV + SSE safety); rbx is saved
     * around the sequence because callees clobber it (see call_aligned) */
    buf_puts(o, "    push rbx\n    mov rbx, rsp\n    and rsp, -16\n");
    buf_printf(o, "    call %s\n", fi->mangled);
    buf_puts(o, "    mov rsp, rbx\n    pop rbx\n");

    /* result: every integer result travels extended in rax; decimal as
     * raw bits in rax; text as the (ptr,len) pair; pointers as rax */
    if (ty_is_integer(fi->ret) || fi->ret == ty_bool || ty_is_ptr(fi->ret)
        || fi->ret == ty_null) {
        push_rax(o);
    } else if (fi->ret == ty_decimal) {
        buf_puts(o, "    movq xmm0, rax\n");
        push_xmm0(o);
    } else if (fi->ret == ty_text) {
        push_pair_rax_rdx(o);
    }
}

static void emit_binop(FnCtx *fc, IrInst *in) {
    Buf *o = fc->out;

    /* pointer arithmetic: rax = pointer, rcx = integer scaled by size(T) */
    if (ty_is_ptr(in->type) && (in->op == OP_ADD || in->op == OP_SUB)) {
        size_t esz = ty_bytes(in->type->elem);
        buf_puts(o, "    pop rcx\n    pop rax\n"); /* rcx = n, rax = p */
        buf_printf(o, "    imul rcx, %zu\n", esz);
        if (in->op == OP_ADD) buf_puts(o, "    add rax, rcx\n");
        else                  buf_puts(o, "    sub rax, rcx\n");
        push_rax(o);
        return;
    }

    if (in->type == ty_text) {
        /* only `+` (concat) reaches here; == / != also possible */
        if (in->op == OP_ADD) {
            pop_pair_rax_rdx(o); /* rax = right.ptr, rdx = right.len */
            buf_puts(o, "    mov r9, rax\n    mov r10, rdx\n");
            pop_pair_rax_rdx(o); /* rax = left.ptr, rdx = left.len */
            /* rt_concat(result_out, l_ptr, l_len, r_ptr, r_len):
             * rdi = &scratch, rsi = l_ptr, rdx = l_len (already),
             * rcx = r_ptr, r8 = r_len */
            buf_printf(o, "    lea rdi, [rbp-%zu]\n", fc->oa_base); /* scratch: outgoing slot 0 */
            buf_puts(o, "    mov rsi, rax\n");
            buf_puts(o, "    mov rcx, r9\n    mov r8, r10\n");
            call_aligned(o, "rt_concat");
            buf_printf(o, "    mov rax, [rbp-%zu]\n", fc->oa_base);
            buf_printf(o, "    mov rdx, [rbp-%zu]\n", fc->oa_base - 8);
            push_pair_rax_rdx(o);
            return;
        }
        /* text equality */
        pop_pair_rax_rdx(o); /* right */
        buf_puts(o, "    mov r9, rax\n    mov r10, rdx\n");
        pop_pair_rax_rdx(o); /* left */
        buf_puts(o, "    mov rsi, rdx\n    mov rdi, rax\n    mov rdx, r9\n    mov rcx, r10\n");
        call_aligned(o, "rt_text_eq");
        if (in->op == OP_NEQ)
            buf_puts(o, "    xor eax, 1\n");
        buf_puts(o, "    movzx rax, al\n");
        push_rax(o);
        return;
    }

    if (in->type == ty_decimal) {
        pop_xmm0(o); /* right */
        buf_puts(o, "    movsd xmm1, xmm0\n");
        pop_xmm0(o); /* left -> xmm0 */
        switch (in->op) {
        case OP_ADD: buf_puts(o, "    addsd xmm0, xmm1\n"); break;
        case OP_SUB: buf_puts(o, "    subsd xmm0, xmm1\n"); break;
        case OP_MUL: buf_puts(o, "    mulsd xmm0, xmm1\n"); break;
        case OP_DIV: buf_puts(o, "    divsd xmm0, xmm1\n"); break;
        case OP_EQ:
            buf_puts(o, "    ucomisd xmm0, xmm1\n    sete al\n    setnp cl\n    and al, cl\n    movzx rax, al\n");
            break;
        case OP_NEQ:
            buf_puts(o, "    ucomisd xmm0, xmm1\n    setne al\n    setp cl\n    or al, cl\n    movzx rax, al\n");
            break;
        case OP_LT: /* a < b  <=>  b > a (ordered) */
            buf_puts(o, "    ucomisd xmm1, xmm0\n    seta al\n    movzx rax, al\n");
            break;
        case OP_LE:
            buf_puts(o, "    ucomisd xmm1, xmm0\n    setae al\n    movzx rax, al\n");
            break;
        case OP_GT:
            buf_puts(o, "    ucomisd xmm0, xmm1\n    seta al\n    movzx rax, al\n");
            break;
        case OP_GE:
            buf_puts(o, "    ucomisd xmm0, xmm1\n    setae al\n    movzx rax, al\n");
            break;
        default: OK_ICE("bad decimal binop %d", (int)in->op);
        }
        if (in->op <= OP_MOD)
            push_xmm0(o);
        else
            push_rax(o);
        return;
    }

    /* integer / bool: values on the stack are 64-bit register
     * representations; arithmetic runs at 64 bits and wraps back to the
     * type's width (spec §4.2). Comparisons use the type's signedness. */
    bool is_bool = (in->type == ty_bool);
    bool is_unsigned = ty_is_integer(in->type) && !in->type->is_signed;
    /* arith + bitwise + shifts re-encode to the result width (0.11);
     * comparisons yield bool and never re-encode */
    bool is_intop = (in->op <= OP_MOD || in->op >= OP_BAND);
    buf_puts(o, "    pop rcx\n    pop rax\n"); /* rcx = right, rax = left */
    switch (in->op) {
    case OP_ADD: buf_puts(o, "    add rax, rcx\n"); break;
    case OP_SUB: buf_puts(o, "    sub rax, rcx\n"); break;
    case OP_MUL: buf_puts(o, "    imul rax, rcx\n"); break;
    case OP_BAND: buf_puts(o, "    and rax, rcx\n"); break;
    case OP_BOR:  buf_puts(o, "    or rax, rcx\n"); break;
    case OP_XOR:  buf_puts(o, "    xor rax, rcx\n"); break;
    case OP_SHL: case OP_SHR: {
        /* rcx = count (i64), rax = value. Out-of-range counts are fatal
         * traps (0.11, spec §13, exit 72): count >= width, including
         * negative counts (huge as unsigned, so `jae` catches them) */
        size_t sv = fc->div_seq++;
        /* jb = count < width: the good path; fallthrough (count >= width,
         * negative counts included — huge as unsigned) hits the trap */
        buf_printf(o, "    cmp rcx, %d\n    jb .Lsvk_%zu_%zu\n",
                   in->type ? in->type->bits : 64, fc->func_seq, sv);
        buf_puts(o, "    mov rdi, rcx\n");
        buf_puts(o, "    call rt_shift_trap\n"); /* never returns */
        buf_printf(o, ".Lsvk_%zu_%zu:\n", fc->func_seq, sv);
        if (in->op == OP_SHL) buf_puts(o, "    shl rax, cl\n");
        else if (in->type && in->type->is_signed)
            buf_puts(o, "    sar rax, cl\n");   /* arithmetic (spec §4.2) */
        else
            buf_puts(o, "    shr rax, cl\n");   /* logical */
        break;
    }
    case OP_DIV: case OP_MOD: {
        /* division by zero is a fatal runtime trap (spec §13, exit 71);
         * signed INT64_MIN / -1 wraps (idiv would fault #DE) */
        size_t dv = fc->div_seq++;
        buf_printf(o, "    test rcx, rcx\n    jnz .Ldvk_%zu_%zu\n", fc->func_seq, dv);
        buf_puts(o, "    call rt_div_trap\n"); /* never returns */
        buf_printf(o, ".Ldvk_%zu_%zu:\n", fc->func_seq, dv);
        if (!is_unsigned) {
            buf_printf(o, "    cmp rcx, -1\n    jne .Ldvo_%zu_%zu\n", fc->func_seq, dv);
            if (in->op == OP_DIV) {
                buf_puts(o, "    neg rax\n"); /* INT64_MIN negates to itself */
            } else {
                buf_puts(o, "    xor eax, eax\n"); /* INT64_MIN % -1 == 0 */
            }
            buf_printf(o, "    jmp .Ldvd_%zu_%zu\n", fc->func_seq, dv);
            buf_printf(o, ".Ldvo_%zu_%zu:\n", fc->func_seq, dv);
            buf_puts(o, "    cqo\n    idiv rcx\n");
            if (in->op == OP_MOD)
                buf_puts(o, "    mov rax, rdx\n");
        } else {
            buf_puts(o, "    xor edx, edx\n    div rcx\n");
            if (in->op == OP_MOD)
                buf_puts(o, "    mov rax, rdx\n");
        }
        buf_printf(o, ".Ldvd_%zu_%zu:\n", fc->func_seq, dv);
        break;
    }
    case OP_AND: buf_puts(o, "    and rax, rcx\n"); break;
    case OP_OR:  buf_puts(o, "    or rax, rcx\n"); break;
    case OP_EQ:  buf_puts(o, "    cmp rax, rcx\n    sete al\n    movzx rax, al\n"); break;
    case OP_NEQ: buf_puts(o, "    cmp rax, rcx\n    setne al\n    movzx rax, al\n"); break;
    case OP_LT:
        if (is_unsigned) buf_puts(o, "    cmp rax, rcx\n    setb al\n    movzx rax, al\n");
        else             buf_puts(o, "    cmp rax, rcx\n    setl al\n    movzx rax, al\n");
        break;
    case OP_LE:
        if (is_unsigned) buf_puts(o, "    cmp rax, rcx\n    setbe al\n    movzx rax, al\n");
        else             buf_puts(o, "    cmp rax, rcx\n    setle al\n    movzx rax, al\n");
        break;
    case OP_GT:
        if (is_unsigned) buf_puts(o, "    cmp rax, rcx\n    seta al\n    movzx rax, al\n");
        else             buf_puts(o, "    cmp rax, rcx\n    setg al\n    movzx rax, al\n");
        break;
    case OP_GE:
        if (is_unsigned) buf_puts(o, "    cmp rax, rcx\n    setae al\n    movzx rax, al\n");
        else             buf_puts(o, "    cmp rax, rcx\n    setge al\n    movzx rax, al\n");
        break;
    default: OK_ICE("bad integer binop %d", (int)in->op);
    }
    if (is_intop && !is_bool)
        emit_reencode(o, in->type); /* wrap to the result width */
    push_rax(o);
}

static void emit_inst(FnCtx *fc, IrInst *in) {
    Buf *o = fc->out;

    switch (in->kind) {
    case I_CONST_INT:
        if (in->i == 0) {
            buf_puts(o, "    xor eax, eax\n");
        } else if (in->i <= 0x7fffffff) {
            /* positive int32: mov eax zero-extends safely */
            buf_printf(o, "    mov eax, %llu\n", (unsigned long long)in->i);
        } else {
            /* full 64-bit immediate (negative values included: `mov eax`
             * would zero-extend and corrupt the sign) */
            buf_printf(o, "    mov rax, %llu\n", (unsigned long long)in->i);
        }
        push_rax(o);
        break;
    case I_CONST_DEC: {
        union { double d; uint64_t u; } u;
        u.d = in->d;
        buf_printf(o, "    mov rax, 0x%016llx\n", (unsigned long long)u.u);
        buf_puts(o, "    movq xmm0, rax\n");
        push_xmm0(o);
        break;
    }
    case I_CONST_BOOL:
        buf_printf(o, "    mov eax, %d\n", in->b ? 1 : 0);
        push_rax(o);
        break;
    case I_CONST_TEXT:
        buf_printf(o, "    lea rax, [rip+.Lstr%d]\n", in->text_idx);
        buf_printf(o, "    mov rdx, %zu\n", fc->im->texts[in->text_idx].len);
        push_pair_rax_rdx(o);
        break;
    case I_LOAD_LOCAL: {
        size_t off = fc->offsets[in->slot];
        if (in->type == ty_text) {
            /* the pair is [rbp-off] = ptr, [rbp-off+8] = len — the SECOND
             * word sits TOWARD rbp (off-8 in rbp-relative form). Writing it
             * at off+8 would land in the NEIGHBOR slot (a 0.6 defect that
             * surfaced when a text local was followed by any other local) */
            buf_printf(o, "    mov rax, [rbp-%zu]\n", off);
            buf_printf(o, "    mov rdx, [rbp-%zu]\n", off - 8);
            push_pair_rax_rdx(o);
        } else {
            buf_printf(o, "    mov rax, [rbp-%zu]\n", off);
            push_rax(o);
        }
        break;
    }
    case I_STORE_LOCAL: {
        size_t off = fc->offsets[in->slot];
        if (in->type == ty_text) {
            pop_pair_rax_rdx(o);
            buf_printf(o, "    mov [rbp-%zu], rax\n", off);
            buf_printf(o, "    mov [rbp-%zu], rdx\n", off - 8);
        } else {
            pop_rax(o);
            buf_printf(o, "    mov [rbp-%zu], rax\n", off);
        }
        break;
    }
    case I_LOAD_GLOBAL: {
        Symbol *s = (Symbol *)in->sym;
        if (in->type == ty_text) {
            buf_printf(o, "    mov rax, [rip+%s]\n", s->mangled);
            buf_printf(o, "    mov rdx, [rip+%s+8]\n", s->mangled);
            push_pair_rax_rdx(o);
        } else {
            char addr[64];
            snprintf(addr, sizeof addr, "rip+%s", s->mangled);
            emit_load_at_rax(o, in->type, addr); /* natural width */
            push_rax(o);
        }
        break;
    }
    case I_STORE_GLOBAL: {
        Symbol *s = (Symbol *)in->sym;
        if (in->type == ty_text) {
            pop_pair_rax_rdx(o);
            buf_printf(o, "    mov [rip+%s], rax\n", s->mangled);
            buf_printf(o, "    mov [rip+%s+8], rdx\n", s->mangled);
        } else {
            pop_rax(o);
            char addr[64];
            snprintf(addr, sizeof addr, "rip+%s", s->mangled);
            emit_store_rax_at(o, in->type, addr); /* natural width */
        }
        break;
    }
    case I_CONV: {
        OkType src = in->type, dst = in->type2;
        if (src == dst) break; /* identity: no code */
        if (dst == ty_text) {
            /* T.to_text(v): rt_*_to_text(out16, v) with the outgoing-area
             * slot 0 as scratch, then push the (ptr, len) pair (§4.4, 0.6) */
            buf_printf(o, "    lea rdi, [rbp-%zu]\n", fc->oa_base);
            if (src == ty_decimal) {
                pop_xmm0(o);
                buf_puts(o, "    movq rsi, xmm0\n");
                call_aligned(o, "rt_decimal_to_text");
            } else if (src == ty_bool) {
                pop_rax(o);
                buf_puts(o, "    mov rsi, rax\n");
                call_aligned(o, "rt_bool_to_text");
            } else if (src == ty_uint64) {
                pop_rax(o);
                buf_puts(o, "    mov rsi, rax\n");
                call_aligned(o, "rt_uint_to_text");
            } else {
                pop_rax(o);
                buf_puts(o, "    mov rsi, rax\n");
                call_aligned(o, "rt_number_to_text");
            }
            buf_printf(o, "    mov rax, [rbp-%zu]\n", fc->oa_base);
            buf_printf(o, "    mov rdx, [rbp-%zu]\n", fc->oa_base - 8);
            push_pair_rax_rdx(o);
            break;
        }
        if (src == ty_text) {
            /* text.to_number / text.to_decimal(s) */
            pop_rax(o); /* ptr */
            pop_rdx(o); /* len */
            buf_puts(o, "    mov rdi, rax\n    mov rsi, rdx\n");
            if (dst == ty_decimal) {
                call_aligned(o, "rt_text_to_decimal");
                buf_puts(o, "    movq xmm0, rax\n");
                push_xmm0(o);
            } else {
                call_aligned(o, "rt_text_to_number");
                emit_reencode(o, dst);
                push_rax(o);
            }
            break;
        }
        if (src == ty_decimal) {
            pop_xmm0(o);
            buf_puts(o, "    cvttsd2si rax, xmm0\n"); /* NaN/overflow -> INT64_MIN sentinel */
            emit_reencode(o, dst);
            push_rax(o);
        } else if (dst == ty_decimal) {
            pop_rax(o);
            if (src == ty_bool) {
                buf_puts(o, "    cvtsi2sd xmm0, rax\n");
            } else if (src == ty_uint64) {
                /* exact uint64 -> double: x/2*2 + x&1 (rounds correctly) */
                buf_puts(o, "    mov rcx, rax\n    and rcx, 1\n    shr rax, 1\n");
                buf_puts(o, "    cvtsi2sd xmm0, rax\n    addsd xmm0, xmm0\n");
                buf_puts(o, "    cvtsi2sd xmm1, rcx\n    addsd xmm0, xmm1\n");
            } else {
                /* signed or narrower unsigned: the register rep is the value */
                buf_puts(o, "    cvtsi2sd xmm0, rax\n");
            }
            push_xmm0(o);
        } else {
            /* integer -> integer (bool included): truncating wrap */
            pop_rax(o);
            emit_reencode(o, dst);
            push_rax(o);
        }
        break;
    }
    case I_BINOP:
        emit_binop(fc, in);
        break;
    case I_UNOP:
        if (in->uop == UN_NEG && in->type == ty_decimal) {
            pop_xmm0(o);
            buf_puts(o, "    movq rax, xmm0\n    mov rcx, 0x8000000000000000\n    xor rax, rcx\n    movq xmm0, rax\n");
            push_xmm0(o);
        } else if (in->uop == UN_NEG) {
            pop_rax(o);
            buf_puts(o, "    neg rax\n");
            emit_reencode(o, in->type); /* wrap (uint8 0 -> 0; int8 -128 -> -128) */
            push_rax(o);
        } else if (in->uop == UN_BNOT) {
            /* ~x — bitwise not (0.11, spec §9); re-encode because `not`
            * flips the high bits above the type's width */
            pop_rax(o);
            buf_puts(o, "    not rax\n");
            emit_reencode(o, in->type);
            push_rax(o);
        } else {
            pop_rax(o);
            buf_puts(o, "    xor eax, 1\n");
            push_rax(o);
        }
        break;
    case I_LABEL:
        buf_printf(o, ".L%zu_%d:\n", fc->func_seq, in->label);
        break;
    case I_JMP:
        buf_printf(o, "    jmp .L%zu_%d\n", fc->func_seq, in->label);
        break;
    case I_JMPF:
        pop_rax(o);
        buf_puts(o, "    test rax, rax\n");
        buf_printf(o, "    jz .L%zu_%d\n", fc->func_seq, in->label);
        break;
    case I_CALL:
        emit_call(fc, in);
        break;
    case I_WRITE:
        if (ty_kind(in->type) == OK_ARRAY)
            OK_ICE("WRITE of array type at %zu:%zu (sema should have rejected it)", in->line, in->col);
        switch (ty_kind(in->type)) {
        case OK_UINT64:
            pop_rax(o);
            buf_puts(o, "    mov rdi, rax\n");
            call_aligned(o, "rt_write_uint");
            break;
        case OK_BOOL:
            pop_rax(o);
            buf_puts(o, "    mov rdi, rax\n");
            call_aligned(o, "rt_write_bool");
            break;
        case OK_NUMBER:
        case OK_INT8: case OK_INT16: case OK_INT32:
        case OK_UINT8: case OK_UINT16: case OK_UINT32:
            /* signed print: the register rep is the value (unsigned values
             * below 2^63 print identically) */
            pop_rax(o);
            buf_puts(o, "    mov rdi, rax\n");
            call_aligned(o, "rt_write_number");
            break;
        case OK_DECIMAL:
            pop_xmm0(o);
            call_aligned(o, "rt_write_decimal");
            break;
        case OK_TEXT:
            buf_puts(o, "    mov rdi, [rsp]\n    mov rsi, [rsp+8]\n    add rsp, 16\n");
            call_aligned(o, "rt_write_text");
            break;
        default:
            OK_ICE("write of void type at %zu:%zu", in->line, in->col);
        }
        break;
    case I_PRINT:
        call_aligned(o, "rt_print");
        break;
    case I_RETURN:
        if (ty_kind(in->type) == OK_ARRAY || ty_is_record(in->type))
            OK_ICE("RETURN of aggregate type at %zu:%zu (sema should have rejected it)", in->line, in->col);
        if (ty_is_integer(in->type) || in->type == ty_bool || ty_is_ptr(in->type)
            || in->type == ty_null) {
            pop_rax(o);
        } else if (in->type == ty_decimal) {
            pop_xmm0(o);
            buf_puts(o, "    movq rax, xmm0\n");
        } else if (in->type == ty_text) {
            pop_pair_rax_rdx(o);
        } else {
            buf_puts(o, "    xor eax, eax\n");
        }
        buf_puts(o, "    leave\n    ret\n");
        break;
    case I_POP: {
        /* operand-stack widths: text is a 16-byte pair; every scalar is one
         * 8-byte word (extended); arrays travel as 8-byte addresses */
        size_t w = (in->type == ty_text) ? 16 : 8;
        buf_printf(o, "    add rsp, %zu\n", w);
        break;
    }
    case I_ADDR_LOCAL: {
        /* slot storage starts at [rbp-offsets[slot]] and grows toward rbp */
        size_t base = fc->offsets[in->slot];
        long disp = (long)in->i - (long)base;
        lea_rbp(o, disp);
        push_rax(o);
        break;
    }
    case I_ADDR_GLOBAL: {
        Symbol *sym = (Symbol *)in->sym;
        buf_printf(o, "    lea rax, [rip+%s]\n", sym->mangled);
        if (in->i) buf_printf(o, "    add rax, %llu\n", (unsigned long long)in->i);
        push_rax(o);
        break;
    }
    case I_INDEX: {
        /* pop index (rcx), pop base (rax); unsigned bounds check; scale */
        size_t count = in->type ? in->type->count : 0;
        size_t esz = in->type ? ty_bytes(in->type->elem) : 8;
        buf_puts(o, "    pop rcx\n    pop rax\n");
        buf_printf(o, "    cmp rcx, %zu\n", count);
        buf_printf(o, "    jb .Lbok_%zu_%zu\n", fc->func_seq, fc->trap_seq);
        /* out of bounds: rt_bounds_trap(index, count) never returns */
        buf_puts(o, "    mov rdi, rcx\n");
        buf_printf(o, "    mov rsi, %zu\n", count);
        call_aligned(o, "rt_bounds_trap");
        buf_printf(o, ".Lbok_%zu_%zu:\n", fc->func_seq, fc->trap_seq);
        fc->trap_seq++;
        if (esz == 1 || esz == 2 || esz == 4 || esz == 8) {
            buf_printf(o, "    lea rax, [rax + rcx*%zu]\n", esz);
        } else {
            buf_printf(o, "    imul rcx, rcx, %zu\n", esz);
            buf_puts(o, "    add rax, rcx\n");
        }
        push_rax(o);
        break;
    }
    case I_TEXT_LEN: {
        /* pop the (ptr,len) pair; the length half IS the value */
        pop_pair_rax_rdx(o);
        buf_puts(o, "    mov rax, rdx\n");
        push_rax(o);
        break;
    }
    case I_TEXT_BYTE: {
        /* pop index (r11), pop text (rax=ptr, rdx=len); unsigned bounds
         * check traps exactly like array indexing (D24); movzx the byte */
        buf_puts(o, "    pop r11\n");           /* index */
        pop_pair_rax_rdx(o);                     /* rax = ptr, rdx = len */
        buf_puts(o, "    cmp r11, rdx\n");
        buf_printf(o, "    jb .Lbok_%zu_%zu\n", fc->func_seq, fc->trap_seq);
        buf_puts(o, "    mov rdi, r11\n    mov rsi, rdx\n");
        call_aligned(o, "rt_text_bounds_trap");
        buf_printf(o, ".Lbok_%zu_%zu:\n", fc->func_seq, fc->trap_seq);
        fc->trap_seq++;
        buf_puts(o, "    movzx rax, BYTE PTR [rax + r11]\n");
        push_rax(o);
        break;
    }
    case I_TEXT_SLICE: {
        /* pop to (r10), pop from (r11), pop text (rax=ptr, rdx=len);
         * bounds: 0 <= from <= to <= len, end-exclusive; traps otherwise.
         * The result shares the original's immutable bytes — O(1) */
        buf_puts(o, "    pop r10\n");           /* to (exclusive) */
        buf_puts(o, "    pop r11\n");           /* from */
        pop_pair_rax_rdx(o);                     /* rax = ptr, rdx = len */
        buf_puts(o, "    cmp r11, r10\n");
        buf_printf(o, "    jbe .Lsok_%zu_%zu\n", fc->func_seq, fc->trap_seq);
        buf_puts(o, "    mov rdi, r11\n    mov rsi, r10\n");
        call_aligned(o, "rt_text_bounds_trap");
        buf_printf(o, ".Lsok_%zu_%zu:\n", fc->func_seq, fc->trap_seq);
        fc->trap_seq++;
        buf_puts(o, "    cmp r10, rdx\n");
        buf_printf(o, "    jbe .Lsok_%zu_%zu\n", fc->func_seq, fc->trap_seq);
        buf_puts(o, "    mov rdi, r10\n    mov rsi, rdx\n");
        call_aligned(o, "rt_text_bounds_trap");
        buf_printf(o, ".Lsok_%zu_%zu:\n", fc->func_seq, fc->trap_seq);
        fc->trap_seq++;
        buf_puts(o, "    add rax, r11\n");       /* new ptr */
        buf_puts(o, "    sub r10, r11\n");      /* new len */
        buf_puts(o, "    mov rdx, r10\n");
        push_pair_rax_rdx(o);
        break;
    }
    case I_FS_READ: {
        /* pop the path pair; rt_fs_read returns the file's (ptr,len) in
         * rax:rdx — the text ABI */
        pop_pair_rax_rdx(o);
        buf_puts(o, "    mov rdi, rax\n    mov rsi, rdx\n");
        call_aligned(o, "rt_fs_read");
        push_pair_rax_rdx(o);
        break;
    }
    case I_FS_WRITE: {
        /* pop data pair (save), pop path pair, call; rax = bytes written */
        pop_pair_rax_rdx(o);                    /* data: rax=ptr, rdx=len */
        buf_puts(o, "    mov r9, rax\n    mov r10, rdx\n");
        pop_pair_rax_rdx(o);                    /* path: rax=ptr, rdx=len */
        buf_puts(o, "    mov rdi, rax\n    mov rsi, rdx\n");
        buf_puts(o, "    mov rdx, r9\n    mov rcx, r10\n");
        call_aligned(o, "rt_fs_write");
        push_rax(o);
        break;
    }
    case I_FS_EXISTS: {
        pop_pair_rax_rdx(o);
        buf_puts(o, "    mov rdi, rax\n    mov rsi, rdx\n");
        call_aligned(o, "rt_fs_exists");
        buf_puts(o, "    movzx rax, al\n");
        push_rax(o);
        break;
    }
    case I_LOAD_AT: {
        buf_puts(o, "    pop rax\n"); /* address */
        if (in->type == ty_text) {
            buf_puts(o, "    mov rdx, [rax+8]\n    mov rax, [rax]\n");
            push_pair_rax_rdx(o);
        } else {
            emit_load_at_rax(o, in->type, "rax"); /* natural width */
            push_rax(o);
        }
        break;
    }
    case I_STORE_AT: {
        if (in->type == ty_text) {
            pop_pair_rax_rdx(o); /* rax = ptr, rdx = len */
            buf_puts(o, "    pop rcx\n"); /* address */
            buf_puts(o, "    mov [rcx], rax\n    mov [rcx+8], rdx\n");
        } else {
            pop_rax(o);      /* value (or decimal bits) at natural width */
            buf_puts(o, "    pop rcx\n"); /* address */
            emit_store_rax_at(o, in->type, "rcx");
        }
        break;
    }
    case I_COPY: {
        /* pop src (rsi), pop dst (rdi); copy i bytes exactly (sub-word
         * element sizes make qword copies wrong — spec §8.4 layout) */
        buf_puts(o, "    pop rsi\n    pop rdi\n");
        buf_printf(o, "    mov rcx, %llu\n    rep movsb\n",
                   (unsigned long long)in->i);
        break;
    }
    case I_ALLOC: {
        /* pop count (rax); bytes = count * size(T); rt_alloc(bytes) */
        size_t esz = ty_bytes(in->type);
        buf_puts(o, "    pop rax\n");
        if (esz != 1) buf_printf(o, "    imul rax, %zu\n", esz);
        buf_puts(o, "    mov rdi, rax\n");
        call_aligned(o, "rt_alloc");
        push_rax(o);
        break;
    }
    case I_RELEASE: {
        /* pop ptr; rt_release handles null (no-op) and validates headers */
        buf_puts(o, "    pop rax\n    mov rdi, rax\n");
        call_aligned(o, "rt_release");
        break;
    }
    case I_PTRCHK: {
        /* pop ptr; null dereferences trap (spec §13, exit 73); push back */
        size_t pk = fc->div_seq++;   /* reuse the per-function label counter */
        buf_puts(o, "    pop rax\n    test rax, rax\n");
        buf_printf(o, "    jnz .Lpnk_%zu_%zu\n", fc->func_seq, pk);
        buf_puts(o, "    call rt_null_trap\n"); /* never returns */
        buf_printf(o, ".Lpnk_%zu_%zu:\n", fc->func_seq, pk);
        push_rax(o);
        break;
    }
    case I_PTR_SCALE: {
        /* pop index (rcx), pop ptr (rax); addr = ptr + index*size(T) */
        size_t esz = ty_bytes(in->type->elem);
        buf_puts(o, "    pop rcx\n    pop rax\n");
        if (esz == 1) {
            buf_puts(o, "    add rax, rcx\n");
        } else if (esz == 2 || esz == 4 || esz == 8) {
            buf_printf(o, "    lea rax, [rax + rcx*%zu]\n", esz);
        } else {
            buf_printf(o, "    imul rcx, rcx, %zu\n    add rax, rcx\n", esz);
        }
        push_rax(o);
        break;
    }
    case I_PTR_DIFF: {
        /* pop q (rcx), pop p (rax); result = (p - q) / size(T), signed */
        size_t esz = ty_bytes(in->type->elem);
        buf_puts(o, "    pop rcx\n    pop rax\n");
        buf_puts(o, "    sub rax, rcx\n    cqo\n");
        buf_printf(o, "    mov rcx, %zu\n    idiv rcx\n", esz);
        push_rax(o);
        break;
    }
    case I_ADDOFF: {
        /* pop addr (rax); push addr + field offset (spec §8.3) */
        buf_puts(o, "    pop rax\n");
        if (in->i) buf_printf(o, "    add rax, %llu\n", (unsigned long long)in->i);
        push_rax(o);
        break;
    }
    default:
        OK_ICE("unhandled IR kind %d at %zu:%zu", (int)in->kind, in->line, in->col);
    }
}

/* ---------------- module ---------------- */

static void emit_bytes_as_dotbyte(Buf *o, const char *bytes, size_t len) {
    buf_puts(o, "    .byte ");
    for (size_t i = 0; i < len; i++) {
        if (i) buf_puts(o, ", ");
        buf_printf(o, "%u", (unsigned char)bytes[i]);
    }
    buf_puts(o, "\n");
}

/* ---- global data emission (arrays included, spec §8.4) ---- */

typedef struct {
    Buf *rodata;         /* text bytes of initializers land here */
    Buf *data;           /* storage words land here */
    size_t text_seq;     /* .Lgstr label counter */
} GlobCtx;

/* emit one constant value (or a whole array of them) into the data buffer;
 * text leaves get .rodata labels first. `label` names the storage start. */
static void emit_const_elems(GlobCtx *g, const char *label, OkType t, ConstVal *cv) {
    if (label) buf_printf(g->data, "%s:\n", label);
    if (ty_kind(t) == OK_ARRAY) {
        for (size_t k = 0; k < t->count; k++) {
            ConstVal *ev = (cv && k < cv->nelems) ? &cv->elems[k] : NULL;
            if (!ev || !ev->valid) {
                /* broken element: sema reported; zeros keep the layout */
                buf_printf(g->data, "    .zero %zu\n", ty_bytes(t->elem) ? ty_bytes(t->elem) : 8);
                continue;
            }
            emit_const_elems(g, NULL, t->elem, ev);
        }
        return;
    }
    if (ty_kind(t) == OK_UNION) {
        /* one activated member's constant, then zero to the union's full
         * size — deterministic .data even for the overlapping bytes */
        OkType mt = cv ? cv->mtype : NULL;
        if (!cv || !cv->valid || !mt) {
            buf_printf(g->data, "    .zero %zu\n", t->count ? t->count : 8);
        } else {
            emit_const_elems(g, NULL, mt, cv);
            size_t mb = ty_bytes(mt);
            if (t->count > mb)
                buf_printf(g->data, "    .zero %zu\n", t->count - mb);
        }
        return;
    }
    if (ty_kind(t) == OK_STRUCT) {
        size_t cur = 0;
        for (size_t k = 0; k < t->nsfields; k++) {
            StructField *f = &t->sfields[k];
            if (f->offset > cur)
                buf_printf(g->data, "    .zero %zu\n", f->offset - cur); /* padding */
            ConstVal *ev = (cv && k < cv->nelems) ? &cv->elems[k] : NULL;
            if (!ev || !ev->valid) {
                buf_printf(g->data, "    .zero %zu\n", ty_bytes(f->type) ? ty_bytes(f->type) : 8);
            } else {
                emit_const_elems(g, NULL, f->type, ev);
            }
            cur = f->offset + ty_bytes(f->type);
        }
        if (t->count > cur)
            buf_printf(g->data, "    .zero %zu\n", t->count - cur); /* tail padding */
        return;
    }
    switch (ty_kind(t)) {
    case OK_NUMBER:
        buf_printf(g->data, "    .quad %llu\n", (unsigned long long)cv->i);
        break;
    case OK_BOOL:
        buf_printf(g->data, "    .byte %d\n", cv->b ? 1 : 0);
        break;
    case OK_INT8:
        buf_printf(g->data, "    .byte %u\n", (unsigned)(cv->i & 0xFF));
        break;
    case OK_UINT8:
        buf_printf(g->data, "    .byte %u\n", (unsigned)(cv->i & 0xFF));
        break;
    case OK_INT16:
        buf_printf(g->data, "    .value %u\n", (unsigned)(cv->i & 0xFFFF));
        break;
    case OK_UINT16:
        buf_printf(g->data, "    .value %u\n", (unsigned)(cv->i & 0xFFFF));
        break;
    case OK_INT32:
        buf_printf(g->data, "    .long %llu\n", (unsigned long long)(cv->i & 0xFFFFFFFF));
        break;
    case OK_UINT32:
        buf_printf(g->data, "    .long %llu\n", (unsigned long long)(cv->i & 0xFFFFFFFF));
        break;
    case OK_UINT64:
        buf_printf(g->data, "    .quad %llu\n", (unsigned long long)cv->i);
        break;
    case OK_PTR: case OK_NULL:
        /* pointers in .data: the address bits (null = 0); address-of-global
         * initializers arrive with the relocation milestone */
        buf_printf(g->data, "    .quad %llu\n", (unsigned long long)cv->i);
        break;
    case OK_DECIMAL: {
        union { double d; uint64_t u; } u;
        u.d = cv->d;
        buf_printf(g->data, "    .quad 0x%016llx\n", (unsigned long long)u.u);
        break;
    }
    case OK_TEXT: {
        char lbl[32];
        snprintf(lbl, sizeof lbl, ".Lgstr%zu", g->text_seq++);
        buf_printf(g->rodata, "%s:\n", lbl);
        emit_bytes_as_dotbyte(g->rodata, cv->t, cv->t_len);
        buf_printf(g->data, "    .quad %s, %zu\n", lbl, cv->t_len);
        break;
    }
    default:
        buf_printf(g->data, "    .quad 0\n");
    }
}

bool codegen_module(IrModule *im, const char *out_path) {
    Buf o;
    buf_init(&o);

    buf_puts(&o, "# Okular 0.6 bootstrap — x86-64 Linux assembly\n");
    buf_puts(&o, "# module: ");
    buf_puts(&o, im->mod->name);
    buf_puts(&o, "\n    .intel_syntax noprefix\n\n    .text\n");

    for (size_t i = 0; i < im->funcs.len; i++) {
        IrFunc *f = im->funcs.items[i];
        gen_function(&o, im, f, i);
    }

    /* global initializers: text bytes to .rodata, words to .data */
    Buf rodata, data;
    buf_init(&rodata);
    buf_init(&data);
    GlobCtx gc = { &rodata, &data, 0 };
    for (size_t i = 0; i < im->globals.len; i++) {
        Symbol *s = im->globals.items[i];
        size_t bytes = ty_bytes(s->type) ? ty_bytes(s->type) : 8;
        buf_printf(&data, "    .globl %s\n", s->mangled);
        if (!s->cval.valid) {
            /* broken initializer: sema reported; zeroed storage keeps
             * linking sound for the erroring-module path */
            buf_printf(&data, "    .balign 8\n%s: .zero %zu\n", s->mangled, bytes);
            continue;
        }
        {
            size_t al = ty_align(s->type);
            if (al < 1) al = 1;
            if (al > 8) al = 8;
            buf_printf(&data, "    .balign %zu\n", al);
        }
        emit_const_elems(&gc, s->mangled, s->type, &s->cval);
    }

    /* text literals */
    if (im->ntexts > 0) {
        buf_puts(&o, "\n    .section .rodata\n");
        for (size_t i = 0; i < im->ntexts; i++) {
            buf_printf(&o, ".Lstr%zu:\n", i);
            emit_bytes_as_dotbyte(&o, im->texts[i].bytes, im->texts[i].len);
        }
    }

    if (rodata.len > 0) {
        buf_puts(&o, "\n    .section .rodata\n");
        buf_put(&o, rodata.data, rodata.len);
    }
    if (data.len > 0) {
        buf_puts(&o, "\n    .section .data\n");
        buf_put(&o, data.data, data.len);
    }
    buf_free(&rodata);
    buf_free(&data);

    FILE *fp = fopen(out_path, "w");
    if (!fp) {
        buf_free(&o);
        return false;
    }
    fwrite(o.data, 1, o.len, fp);
    fclose(fp);
    buf_free(&o);
    return true;
}
