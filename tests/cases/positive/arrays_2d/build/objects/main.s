# Okular 0.2 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl __ok_entry
__ok_entry:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    lea rax, [rip+ok_main_grid]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_0
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_0:
    imul rcx, rcx, 24
    add rax, rcx
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_0_1
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_1:
    lea rax, [rax + rcx*8]
    push rax
    mov eax, 60
    push rax
    pop rax
    pop rcx
    mov [rcx], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-8], rax
    mov eax, 2
    push rax
    pop rax
    mov [rbp-16], rax
.L0_0:
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
    jz .L0_2
    xor eax, eax
    push rax
    pop rax
    mov [rbp-24], rax
    mov eax, 3
    push rax
    pop rax
    mov [rbp-32], rax
.L0_3:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_5
    lea rax, [rip+ok_main_grid]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_2
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_2:
    imul rcx, rcx, 24
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_0_3
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_3:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, [rax]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_number
    mov rsp, rbx
    pop rbx
    lea rax, [rip+.Lstr0]
    mov rdx, 1
    push rdx
    push rax
    mov rdi, [rsp]
    mov rsi, [rsp+8]
    add rsp, 16
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_text
    mov rsp, rbx
    pop rbx
    mov rax, [rip+ok_main_total]
    push rax
    lea rax, [rip+ok_main_grid]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_4
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_4:
    imul rcx, rcx, 24
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_0_5
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_5:
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
    mov [rip+ok_main_total], rax
.L0_4:
    mov rax, [rbp-24]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-24], rax
    jmp .L0_3
.L0_5:
.L0_1:
    mov rax, [rbp-8]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-8], rax
    jmp .L0_0
.L0_2:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov rax, [rip+ok_main_total]
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
    lea rax, [rip+ok_main_rows]
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_0_6
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_6:
    imul rcx, rcx, 16
    add rax, rcx
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_7
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_7:
    lea rax, [rax + rcx*8]
    push rax
    mov eax, 30
    push rax
    pop rax
    pop rcx
    mov [rcx], rax
    lea rax, [rip+ok_main_rows]
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_0_8
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_8:
    imul rcx, rcx, 16
    add rax, rcx
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_9
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_9:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, [rax]
    push rax
    lea rax, [rip+ok_main_rows]
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_0_10
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_10:
    imul rcx, rcx, 16
    add rax, rcx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_11
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_11:
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
    leave
    ret

    .section .rodata
.Lstr0:
    .byte 32

    .section .data
    .globl ok_main_grid
    .balign 8
ok_main_grid:
    .quad 1
    .quad 2
    .quad 3
    .quad 4
    .quad 5
    .quad 6
    .globl ok_main_total
    .balign 8
ok_main_total:
    .quad 0
    .globl ok_main_rows
    .balign 8
ok_main_rows:
    .quad 1
    .quad 1
    .quad 2
    .quad 2
    .quad 3
    .quad 3
