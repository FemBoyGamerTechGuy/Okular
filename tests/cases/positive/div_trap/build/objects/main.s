# Okular 0.2 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_run
ok_main_run:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    mov eax, 42
    push rax
    pop rax
    mov [rbp-8], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-16], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_0_0
    call rt_div_trap
.Ldvk_0_0:
    cmp rcx, -1
    jne .Ldvo_0_0
    neg rax
    jmp .Ldvd_0_0
.Ldvo_0_0:
    cqo
    idiv rcx
.Ldvd_0_0:
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_number
    mov rsp, rbx
    pop rbx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl __ok_entry
__ok_entry:
    push rbp
    mov rbp, rsp
    sub rsp, 192
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_run
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    leave
    ret

    .section .data
    .globl ok_main_k
    .balign 8
ok_main_k:
    .quad 7
