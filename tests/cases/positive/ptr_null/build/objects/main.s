# Okular 0.3 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_run
ok_main_run:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    xor eax, eax
    push rax
    pop rax
    push rax
    pop rax
    mov [rbp-8], rax
    mov rax, [rbp-8]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_0
    mov eax, 1
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_bool
    mov rsp, rbx
    pop rbx
.L0_0:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-8]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_2
    mov eax, 1
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_bool
    mov rsp, rbx
    pop rbx
    jmp .L0_3
.L0_2:
    mov eax, 0
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_bool
    mov rsp, rbx
    pop rbx
.L0_3:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-8]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_release
    mov rsp, rbx
    pop rbx
    mov rax, QWORD PTR [rip+ok_main_gp]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_4
    mov eax, 1
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_bool
    mov rsp, rbx
    pop rbx
.L0_4:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    lea rax, [rip+ok_main_table]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_0_0
    mov rdi, rcx
    mov rsi, 3
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
    mov rax, QWORD PTR [rax]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_6
    mov eax, 1
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_bool
    mov rsp, rbx
    pop rbx
.L0_6:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov eax, 1
    push rax
    pop rax
    imul rax, 8
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_alloc
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_8
    mov eax, 1
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_bool
    mov rsp, rbx
    pop rbx
.L0_8:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-16]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_0
    call rt_null_trap
.Lpnk_0_0:
    push rax
    mov eax, 5
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-16]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_release
    mov rsp, rbx
    pop rbx
    xor eax, eax
    push rax
    pop rax
    push rax
    pop rax
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_10
    mov eax, 1
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_bool
    mov rsp, rbx
    pop rbx
.L0_10:
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
    .globl ok_main_gp
    .balign 8
ok_main_gp:
    .quad 0
    .globl ok_main_table
    .balign 8
ok_main_table:
    .quad 0
    .quad 0
    .quad 0
