# Okular 0.4 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_run
ok_main_run:
    push rbp
    mov rbp, rsp
    sub rsp, 256
    lea rax, [rbp-24]
    push rax
    mov eax, 1
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-16]
    push rax
    mov eax, 2
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-8]
    push rax
    mov eax, 10
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-6]
    push rax
    mov eax, 20
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-24]
    push rax
    mov rax, [rsp+0]
    mov [rbp-136], rax
    add rsp, 8
    mov rdi, [rbp-136]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_shapes_area
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
    lea rax, [rbp-24]
    push rax
    mov rax, [rsp+0]
    mov rsi, rax
    lea rdi, [rbp-232]
    mov rcx, 24
    rep movsb
    add rsp, 8
    lea rdi, [rbp-232]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_shapes_area_by_value
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
    mov eax, 10
    push rax
    mov eax, 5
    push rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rsp+0]
    mov [rbp-136], rax
    mov rax, [rsp+8]
    mov [rbp-120], rax
    mov rax, [rsp+16]
    mov [rbp-104], rax
    add rsp, 24
    mov rdi, [rbp-136]
    mov rsi, [rbp-120]
    mov rdx, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_shapes_grow
    mov rsp, rbx
    pop rbx
    lea rax, [rbp-24]
    push rax
    mov rax, [rsp+0]
    mov [rbp-136], rax
    add rsp, 8
    mov rdi, [rbp-136]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_shapes_area
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
    lea rax, [rbp-24]
    push rax
    pop rax
    add rax, 16
    push rax
    pop rax
    movzx rax, WORD PTR [rax]
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
    lea rax, [rbp-24]
    push rax
    pop rax
    add rax, 18
    push rax
    pop rax
    movzx rax, WORD PTR [rax]
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
    lea rax, [rbp-40]
    push rax
    mov eax, 3
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-32]
    push rax
    mov eax, 4
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov eax, 20
    push rax
    mov eax, 10
    push rax
    lea rax, [rbp-40]
    push rax
    mov rax, [rsp+0]
    mov [rbp-136], rax
    mov rax, [rsp+8]
    mov [rbp-120], rax
    mov rax, [rsp+16]
    mov [rbp-104], rax
    add rsp, 24
    mov rdi, [rbp-136]
    mov rsi, [rbp-120]
    mov rdx, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_shapes_translate
    mov rsp, rbx
    pop rbx
    lea rax, [rbp-40]
    push rax
    pop rax
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
    lea rax, [rbp-40]
    push rax
    pop rax
    add rax, 8
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
    lea rax, [rbp-40]
    push rax
    mov rax, [rsp+0]
    mov rsi, rax
    lea rdi, [rbp-232]
    mov rcx, 16
    rep movsb
    add rsp, 8
    lea rdi, [rbp-232]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_shapes_manhattan
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
