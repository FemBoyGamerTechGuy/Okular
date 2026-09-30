/* codegen_x64.c — x86-64 Linux backend (brief §34, docs/architecture.md §3.5).
 *
 * Okular Internal ABI v0:
 *   - args 1..6 in rdi, rsi, rdx, rcx, r8, r9 (integer registers)
 *   - `decimal` travels as raw bits in integer registers/stack slots,
 *     computed in xmm0/xmm1 locally
 *   - `text` args: address of a 16-byte (ptr, len) pair in one register
 *   - returns: scalar/decimal-bits in rax; text pair in rax (ptr) + rdx (len)
 *   - rbx, r12..r15 callee-saved; rbx is the alignment scratch across calls
 *   - calls align rsp to 16 via `mov rbx,rsp / and rsp,-16 / mov rsp,rbx`
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
} FnCtx;

static size_t slot_words(IrSlot *s) { return ok_type_words(s->type); }

/* value push/pop macros (emit text) */
static void push_rax(Buf *o)      { buf_puts(o, "    push rax\n"); }
static void push_xmm0(Buf *o)     { buf_puts(o, "    sub rsp, 8\n    movsd QWORD PTR [rsp], xmm0\n"); }
static void push_pair_rax_rdx(Buf *o) { buf_puts(o, "    push rdx\n    push rax\n"); }
static void pop_rax(Buf *o)       { buf_puts(o, "    pop rax\n"); }
static void pop_xmm0(Buf *o)      { buf_puts(o, "    movsd xmm0, QWORD PTR [rsp]\n    add rsp, 8\n"); }
static void pop_pair_rax_rdx(Buf *o) { buf_puts(o, "    pop rax\n    pop rdx\n"); }

/* aligned call: rbx is pushed around the sequence because callees (including
 * Okular functions, which use the same sequence) freely clobber rbx. */
static void call_aligned(Buf *o, const char *fn) {
    buf_puts(o, "    push rbx\n    mov rbx, rsp\n    and rsp, -16\n");
    buf_printf(o, "    call %s\n", fn);
    buf_puts(o, "    mov rsp, rbx\n    pop rbx\n");
}

static void emit_inst(FnCtx *fc, IrInst *in);

/* ---------------- functions ---------------- */

static void gen_function(Buf *out, IrModule *im, IrFunc *f, size_t seq) {
    FnCtx fc;
    fc.out = out;
    fc.im = im;
    fc.f = f;
    fc.func_seq = seq;

    /* slot offsets: locals occupy [rbp-locals_bytes, rbp) */
    fc.offsets = ok_xmalloc((f->nslots ? f->nslots : 1) * sizeof(size_t));
    size_t off = 0;
    for (size_t i = 0; i < f->nslots; i++) {
        off += 8 * slot_words(&f->slots[i]);
        fc.offsets[i] = off;
    }
    fc.locals_bytes = off;
    fc.oa_base = off + 96; /* 6 outgoing arg slots x 16 bytes */

    size_t frame = fc.oa_base;
    frame = (frame + 15) & ~(size_t)15;

    buf_printf(out, "\n    .globl %s\n%s:\n", f->fi->mangled, f->fi->mangled);
    buf_puts(out, "    push rbp\n    mov rbp, rsp\n");
    buf_printf(out, "    sub rsp, %zu\n", frame);

    /* store parameters into their slots (params are slots 0..n-1) */
    for (size_t k = 0; k < f->fi->nparams && k < 6; k++) {
        size_t o = fc.offsets[k];
        if (f->fi->param_types[k] == OK_TEXT) {
            /* reg holds the address of a (ptr,len) pair */
            buf_printf(out, "    mov rax, [%s]\n", arg_regs[k]);
            buf_printf(out, "    mov rdx, [%s+8]\n", arg_regs[k]);
            buf_printf(out, "    mov [rbp-%zu], rax\n", o);
            buf_printf(out, "    mov [rbp-%zu], rdx\n", o + 8);
        } else {
            buf_printf(out, "    mov [rbp-%zu], %s\n", o, arg_regs[k]);
        }
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
     * so `lea reg,[rbp-oa]` gives the callee a (ptr,len) pair pointer. */
    size_t stack_off = 0; /* byte offset from rsp of arg1's slot */
    for (size_t k = 0; k < n; k++) {
        OkType t = (k < fi->nparams) ? fi->param_types[k] : OK_NUMBER;
        size_t w = (size_t)ok_type_words(t) * 8;
        size_t oa = fc->oa_base - k * 16;
        buf_printf(o, "    mov rax, [rsp+%zu]\n", stack_off);
        buf_printf(o, "    mov [rbp-%zu], rax\n", oa);
        if (t == OK_TEXT) {
            buf_printf(o, "    mov rdx, [rsp+%zu]\n", stack_off + 8);
            buf_printf(o, "    mov [rbp-%zu], rdx\n", oa - 8);
        }
        stack_off += w;
    }
    if (stack_off)
        buf_printf(o, "    add rsp, %zu\n", stack_off);

    /* load argument registers from the outgoing area */
    for (size_t k = 0; k < n && k < 6; k++) {
        OkType t = (k < fi->nparams) ? fi->param_types[k] : OK_NUMBER;
        size_t oa = fc->oa_base - k * 16;
        if (t == OK_TEXT)
            buf_printf(o, "    lea %s, [rbp-%zu]\n", arg_regs[k], oa);
        else
            buf_printf(o, "    mov %s, [rbp-%zu]\n", arg_regs[k], oa);
    }

    /* align rsp to 16 across the call (SysV + SSE safety); rbx is saved
     * around the sequence because callees clobber it (see call_aligned) */
    buf_puts(o, "    push rbx\n    mov rbx, rsp\n    and rsp, -16\n");
    buf_printf(o, "    call %s\n", fi->mangled);
    buf_puts(o, "    mov rsp, rbx\n    pop rbx\n");

    /* result */
    if (fi->ret == OK_NUMBER || fi->ret == OK_BOOL) {
        push_rax(o);
    } else if (fi->ret == OK_DECIMAL) {
        buf_puts(o, "    movq xmm0, rax\n");
        push_xmm0(o);
    } else if (fi->ret == OK_TEXT) {
        push_pair_rax_rdx(o);
    }
}

static void emit_binop(FnCtx *fc, IrInst *in) {
    Buf *o = fc->out;

    if (in->type == OK_TEXT) {
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

    if (in->type == OK_DECIMAL) {
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

    /* integer / bool */
    buf_puts(o, "    pop rcx\n    pop rax\n"); /* rcx = right, rax = left */
    switch (in->op) {
    case OP_ADD: buf_puts(o, "    add rax, rcx\n"); break;
    case OP_SUB: buf_puts(o, "    sub rax, rcx\n"); break;
    case OP_MUL: buf_puts(o, "    imul rax, rcx\n"); break;
    case OP_DIV:
        buf_puts(o, "    cqo\n    idiv rcx\n");
        break;
    case OP_MOD:
        buf_puts(o, "    cqo\n    idiv rcx\n    mov rax, rdx\n");
        break;
    case OP_AND: buf_puts(o, "    and rax, rcx\n"); break;
    case OP_OR:  buf_puts(o, "    or rax, rcx\n"); break;
    case OP_EQ:  buf_puts(o, "    cmp rax, rcx\n    sete al\n    movzx rax, al\n"); break;
    case OP_NEQ: buf_puts(o, "    cmp rax, rcx\n    setne al\n    movzx rax, al\n"); break;
    case OP_LT:  buf_puts(o, "    cmp rax, rcx\n    setl al\n    movzx rax, al\n"); break;
    case OP_LE:  buf_puts(o, "    cmp rax, rcx\n    setle al\n    movzx rax, al\n"); break;
    case OP_GT:  buf_puts(o, "    cmp rax, rcx\n    setg al\n    movzx rax, al\n"); break;
    case OP_GE:  buf_puts(o, "    cmp rax, rcx\n    setge al\n    movzx rax, al\n"); break;
    default: OK_ICE("bad integer binop %d", (int)in->op);
    }
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
        if (in->type == OK_TEXT) {
            buf_printf(o, "    mov rax, [rbp-%zu]\n", off);
            buf_printf(o, "    mov rdx, [rbp-%zu]\n", off + 8);
            push_pair_rax_rdx(o);
        } else {
            buf_printf(o, "    mov rax, [rbp-%zu]\n", off);
            push_rax(o);
        }
        break;
    }
    case I_STORE_LOCAL: {
        size_t off = fc->offsets[in->slot];
        if (in->type == OK_TEXT) {
            pop_pair_rax_rdx(o);
            buf_printf(o, "    mov [rbp-%zu], rax\n", off);
            buf_printf(o, "    mov [rbp-%zu], rdx\n", off + 8);
        } else {
            pop_rax(o);
            buf_printf(o, "    mov [rbp-%zu], rax\n", off);
        }
        break;
    }
    case I_LOAD_GLOBAL: {
        Symbol *s = (Symbol *)in->sym;
        if (in->type == OK_TEXT) {
            buf_printf(o, "    mov rax, [rip+%s]\n", s->mangled);
            buf_printf(o, "    mov rdx, [rip+%s+8]\n", s->mangled);
            push_pair_rax_rdx(o);
        } else {
            buf_printf(o, "    mov rax, [rip+%s]\n", s->mangled);
            push_rax(o);
        }
        break;
    }
    case I_STORE_GLOBAL: {
        Symbol *s = (Symbol *)in->sym;
        if (in->type == OK_TEXT) {
            pop_pair_rax_rdx(o);
            buf_printf(o, "    mov [rip+%s], rax\n", s->mangled);
            buf_printf(o, "    mov [rip+%s+8], rdx\n", s->mangled);
        } else {
            pop_rax(o);
            buf_printf(o, "    mov [rip+%s], rax\n", s->mangled);
        }
        break;
    }
    case I_CONV_NUM_DEC:
        pop_rax(o);
        buf_puts(o, "    cvtsi2sd xmm0, rax\n");
        push_xmm0(o);
        break;
    case I_BINOP:
        emit_binop(fc, in);
        break;
    case I_UNOP:
        if (in->uop == UN_NEG && in->type == OK_DECIMAL) {
            pop_xmm0(o);
            buf_puts(o, "    movq rax, xmm0\n    mov rcx, 0x8000000000000000\n    xor rax, rcx\n    movq xmm0, rax\n");
            push_xmm0(o);
        } else if (in->uop == UN_NEG) {
            pop_rax(o);
            buf_puts(o, "    neg rax\n");
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
        switch (in->type) {
        case OK_NUMBER:
            pop_rax(o);
            buf_puts(o, "    mov rdi, rax\n");
            call_aligned(o, "rt_write_number");
            break;
        case OK_DECIMAL:
            pop_xmm0(o);
            call_aligned(o, "rt_write_decimal");
            break;
        case OK_BOOL:
            pop_rax(o);
            buf_puts(o, "    mov rdi, rax\n");
            call_aligned(o, "rt_write_bool");
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
        if (in->type == OK_NUMBER || in->type == OK_BOOL) {
            pop_rax(o);
        } else if (in->type == OK_DECIMAL) {
            pop_xmm0(o);
            buf_puts(o, "    movq rax, xmm0\n");
        } else if (in->type == OK_TEXT) {
            pop_pair_rax_rdx(o);
        } else {
            buf_puts(o, "    xor eax, eax\n");
        }
        buf_puts(o, "    leave\n    ret\n");
        break;
    case I_POP: {
        size_t w = (in->type == OK_TEXT) ? 16 : 8;
        buf_printf(o, "    add rsp, %zu\n", w);
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

bool codegen_module(IrModule *im, const char *out_path) {
    Buf o;
    buf_init(&o);

    buf_puts(&o, "# Okular 0.1 bootstrap — x86-64 Linux assembly\n");
    buf_puts(&o, "# module: ");
    buf_puts(&o, im->mod->name);
    buf_puts(&o, "\n    .intel_syntax noprefix\n\n    .text\n");

    for (size_t i = 0; i < im->funcs.len; i++) {
        IrFunc *f = im->funcs.items[i];
        gen_function(&o, im, f, i);
    }

    /* text literals */
    if (im->ntexts > 0) {
        buf_puts(&o, "\n    .section .rodata\n");
        for (size_t i = 0; i < im->ntexts; i++) {
            buf_printf(&o, ".Lstr%zu:\n", i);
            emit_bytes_as_dotbyte(&o, im->texts[i].bytes, im->texts[i].len);
        }
    }

    /* global text initializers need labels too */
    size_t ngtext = 0;
    for (size_t i = 0; i < im->globals.len; i++) {
        Symbol *s = im->globals.items[i];
        if (s->type == OK_TEXT && s->cval.valid) ngtext++;
    }
    if (ngtext > 0) {
        buf_puts(&o, "\n    .section .rodata\n");
        size_t k = 0;
        for (size_t i = 0; i < im->globals.len; i++) {
            Symbol *s = im->globals.items[i];
            if (s->type != OK_TEXT || !s->cval.valid) continue;
            buf_printf(&o, ".Lgstr%zu:\n", k++);
            emit_bytes_as_dotbyte(&o, s->cval.t, s->cval.t_len);
        }
    }

    /* globals */
    if (im->globals.len > 0) {
        buf_puts(&o, "\n    .section .data\n");
        size_t k = 0;
        for (size_t i = 0; i < im->globals.len; i++) {
            Symbol *s = im->globals.items[i];
            if (!s->cval.valid) {
                /* broken initializer: sema reported; emit zeroed storage so
                 * linking still succeeds for the erroring module path */
                buf_printf(&o, "%s: .quad 0\n", s->mangled);
                if (s->type == OK_TEXT) buf_printf(&o, "    .quad 0\n");
                continue;
            }
            switch (s->type) {
            case OK_NUMBER:
                buf_printf(&o, "%s: .quad %llu\n", s->mangled, (unsigned long long)s->cval.i);
                break;
            case OK_BOOL:
                buf_printf(&o, "%s: .quad %d\n", s->mangled, s->cval.b ? 1 : 0);
                break;
            case OK_DECIMAL: {
                union { double d; uint64_t u; } u;
                u.d = s->cval.d;
                buf_printf(&o, "%s: .quad 0x%016llx\n", s->mangled, (unsigned long long)u.u);
                break;
            }
            case OK_TEXT:
                buf_printf(&o, "%s: .quad .Lgstr%zu, %zu\n", s->mangled, k++, s->cval.t_len);
                break;
            default:
                buf_printf(&o, "%s: .quad 0\n", s->mangled);
            }
        }
    }

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
