# Okular 0.3 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_bump
ok_main_bump:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_0
    call rt_null_trap
.Lpnk_0_0:
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_1
    call rt_null_trap
.Lpnk_0_1:
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    xor eax, eax
    leave
    ret

    .globl ok_main_set_to
ok_main_set_to:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_1_0
    call rt_null_trap
.Lpnk_1_0:
    push rax
    mov rax, [rbp-16]
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    xor eax, eax
    leave
    ret

    .globl ok_main_pick
ok_main_pick:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_2_0
    call rt_null_trap
.Lpnk_2_0:
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_2_1
    call rt_null_trap
.Lpnk_2_1:
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L2_0
    mov rax, [rbp-8]
    push rax
    pop rax
    leave
    ret
.L2_0:
    mov rax, [rbp-16]
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_main_run
ok_main_run:
    push rbp
    mov rbp, rsp
    sub rsp, 240
    mov eax, 41
    push rax
    pop rax
    mov [rbp-8], rax
    lea rax, [rbp-8]
    push rax
    pop rax
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_3_0
    call rt_null_trap
.Lpnk_3_0:
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
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
    mov rax, [rbp-16]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_3_1
    call rt_null_trap
.Lpnk_3_1:
    push rax
    mov rax, [rbp-16]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_3_2
    call rt_null_trap
.Lpnk_3_2:
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-8]
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
    lea rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-144], rax
    add rsp, 8
    mov rdi, [rbp-144]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_bump
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-8]
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
    mov eax, 500
    push rax
    lea rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-144], rax
    mov rax, [rsp+8]
    mov [rbp-128], rax
    add rsp, 16
    mov rdi, [rbp-144]
    mov rsi, [rbp-128]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_set_to
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-8]
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
    mov eax, 900
    push rax
    pop rax
    mov [rbp-24], rax
    lea rax, [rbp-24]
    push rax
    lea rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-144], rax
    mov rax, [rsp+8]
    mov [rbp-128], rax
    add rsp, 16
    mov rdi, [rbp-144]
    mov rsi, [rbp-128]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_pick
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_3_3
    call rt_null_trap
.Lpnk_3_3:
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
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
    lea rax, [rip+ok_main_counter]
    push rax
    pop rax
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_3_4
    call rt_null_trap
.Lpnk_3_4:
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
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
    mov rax, [rbp-40]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_3_5
    call rt_null_trap
.Lpnk_3_5:
    push rax
    mov rax, [rbp-40]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_3_6
    call rt_null_trap
.Lpnk_3_6:
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, QWORD PTR [rip+ok_main_counter]
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
    push rax
    pop rax
    mov [rbp-48], rax
    mov rax, [rbp-48]
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
    jz .L3_0
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
.L3_0:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
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
    jz .L3_2
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
.L3_2:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    xor eax, eax
    push rax
    pop rax
    push rax
    mov rax, [rbp-48]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L3_4
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
.L3_4:
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
    .globl ok_main_counter
    .balign 8
ok_main_counter:
    .quad 1000
