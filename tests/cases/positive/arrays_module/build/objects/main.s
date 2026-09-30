# Okular 0.2 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl __ok_entry
__ok_entry:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    lea rax, [rip+ok_board_cells]
    push rax
    mov rax, [rsp+0]
    mov rsi, rax
    lea rdi, [rbp-192]
    mov rcx, 4
    rep movsq
    add rsp, 8
    lea rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_board_total
    mov rsp, rbx
    pop rbx
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
    lea rax, [rip+ok_board_cells]
    push rax
    xor eax, eax
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
    mov eax, 40
    push rax
    pop rax
    pop rcx
    mov [rcx], rax
    lea rax, [rip+ok_board_cells]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 4
    jb .Lbok_0_1
    mov rdi, rcx
    mov rsi, 4
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_1:
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
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    xor eax, eax
    leave
    ret
