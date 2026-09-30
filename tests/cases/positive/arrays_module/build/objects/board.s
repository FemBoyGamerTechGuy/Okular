# Okular 0.2 bootstrap — x86-64 Linux assembly
# module: board
    .intel_syntax noprefix

    .text

    .globl ok_board_total
ok_board_total:
    push rbp
    mov rbp, rsp
    sub rsp, 256
    mov rsi, rdi
    lea rdi, [rbp-32]
    mov rcx, 4
    rep movsq
    xor eax, eax
    push rax
    pop rax
    mov [rbp-40], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-48], rax
    mov eax, 4
    push rax
    pop rax
    mov [rbp-56], rax
.L0_0:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_2
    mov rax, [rbp-40]
    push rax
    lea rax, [rbp-32]
    push rax
    mov rax, [rbp-48]
    push rax
    pop rcx
    pop rax
    cmp rcx, 4
    jb .Lbok_0_0
    mov rdi, rcx
    mov rsi, 4
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_0:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-40], rax
.L0_1:
    mov rax, [rbp-48]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-48], rax
    jmp .L0_0
.L0_2:
    mov rax, [rbp-40]
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .section .data
    .balign 8
ok_board_cells:
    .quad 1
    .quad 2
    .quad 3
    .quad 4
