# Okular 0.4 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_run
ok_main_run:
    push rbp
    mov rbp, rsp
    sub rsp, 272
    lea rax, [rbp-16]
    push rax
    mov eax, 3
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-8]
    push rax
    mov eax, 4
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-16]
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
    lea rax, [rbp-16]
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
    lea rax, [rbp-16]
    push rax
    pop rax
    push rax
    mov eax, 30
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-16]
    push rax
    pop rax
    add rax, 8
    push rax
    mov eax, 40
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-16]
    push rax
    pop rax
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    lea rax, [rbp-16]
    push rax
    pop rax
    add rax, 8
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
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
    lea rax, [rbp-32]
    push rax
    lea rax, [rbp-16]
    push rax
    pop rsi
    pop rdi
    mov rcx, 16
    rep movsb
    lea rax, [rbp-32]
    push rax
    pop rax
    push rax
    mov eax, 999
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-16]
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
    lea rax, [rbp-56]
    push rax
    mov eax, 1
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-48]
    push rax
    mov eax, 2
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-40]
    push rax
    mov eax, 10
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-38]
    push rax
    mov eax, 20
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-36]
    push rax
    mov eax, 7
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-35]
    push rax
    mov eax, 1
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-56]
    push rax
    pop rax
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
    lea rax, [rbp-56]
    push rax
    pop rax
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
    lea rax, [rbp-56]
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
    lea rax, [rbp-56]
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
    lea rax, [rbp-56]
    push rax
    pop rax
    add rax, 20
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
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
    lea rax, [rbp-56]
    push rax
    pop rax
    add rax, 21
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_bool
    mov rsp, rbx
    pop rbx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    lea rax, [rbp-56]
    push rax
    pop rax
    push rax
    pop rax
    add rax, 8
    push rax
    mov eax, 22
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-56]
    push rax
    pop rax
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
    lea rax, [rbp-56]
    push rax
    pop rax
    add rax, 16
    push rax
    mov eax, 100
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-56]
    push rax
    pop rax
    add rax, 18
    push rax
    mov eax, 5
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-56]
    push rax
    pop rax
    add rax, 16
    push rax
    pop rax
    movzx rax, WORD PTR [rax]
    push rax
    lea rax, [rbp-56]
    push rax
    pop rax
    add rax, 18
    push rax
    pop rax
    movzx rax, WORD PTR [rax]
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    shl rax, 48
    shr rax, 48
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
    lea rax, [rbp-56]
    push rax
    pop rax
    add rax, 21
    push rax
    mov eax, 0
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-56]
    push rax
    pop rax
    add rax, 21
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
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
    jmp .L0_1
.L0_0:
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
.L0_1:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    lea rax, [rbp-72]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-64]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-72]
    push rax
    lea rax, [rbp-16]
    push rax
    pop rsi
    pop rdi
    mov rcx, 16
    rep movsb
    lea rax, [rbp-72]
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
