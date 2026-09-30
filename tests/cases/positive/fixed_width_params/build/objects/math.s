# Okular 0.2 bootstrap — x86-64 Linux assembly
# module: math
    .intel_syntax noprefix

    .text

    .globl ok_math_clamp_int8
ok_math_clamp_int8:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_0
    mov rax, [rbp-16]
    push rax
    pop rax
    leave
    ret
.L0_0:
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_2
    mov rax, [rbp-24]
    push rax
    pop rax
    leave
    ret
.L0_2:
    mov rax, [rbp-8]
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_math_mix
ok_math_mix:
    push rbp
    mov rbp, rsp
    sub rsp, 256
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov rax, [rbp-24]
    push rax
    pop rax
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    pop rax
    shl rax, 32
    shr rax, 32
    push rax
    pop rax
    mov [rbp-48], rax
    mov rax, [rbp-16]
    push rax
    pop rax
    mov [rbp-56], rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rax
    push rax
    pop rax
    shl rax, 32
    shr rax, 32
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 32
    shr rax, 32
    push rax
    pop rax
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rax
    push rax
    pop rax
    shl rax, 32
    shr rax, 32
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 32
    shr rax, 32
    push rax
    pop rax
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_math_wrap16
ok_math_wrap16:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    shl rax, 48
    sar rax, 48
    push rax
    pop rax
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret
