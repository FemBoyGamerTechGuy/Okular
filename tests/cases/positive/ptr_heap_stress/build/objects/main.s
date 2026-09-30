# Okular 0.3 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_run
ok_main_run:
    push rbp
    mov rbp, rsp
    sub rsp, 256
    xor eax, eax
    push rax
    pop rax
    mov [rbp-8], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-16], rax
    mov eax, 200
    push rax
    pop rax
    mov [rbp-24], rax
.L0_0:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
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
    mov eax, 4
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
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_0
    call rt_null_trap
.Lpnk_0_0:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_1
    call rt_null_trap
.Lpnk_0_1:
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    mov rax, [rbp-16]
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
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_2
    call rt_null_trap
.Lpnk_0_2:
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_3
    call rt_null_trap
.Lpnk_0_3:
    push rax
    mov eax, 3
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov eax, 3
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov eax, 8
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
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_4
    call rt_null_trap
.Lpnk_0_4:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_5
    call rt_null_trap
.Lpnk_0_5:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_6
    call rt_null_trap
.Lpnk_0_6:
    push rax
    mov eax, 3
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
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
    mov rax, [rbp-40]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_7
    call rt_null_trap
.Lpnk_0_7:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-8], rax
    mov rax, [rbp-32]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_release
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-40]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_release
    mov rsp, rbx
    pop rbx
.L0_1:
    mov rax, [rbp-16]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-16], rax
    jmp .L0_0
.L0_2:
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
    mov eax, 2
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
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_8
    call rt_null_trap
.Lpnk_0_8:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    mov eax, 7
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-48]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_release
    mov rsp, rbx
    pop rbx
    mov eax, 2
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
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_9
    call rt_null_trap
.Lpnk_0_9:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    mov eax, 9
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-56]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_10
    call rt_null_trap
.Lpnk_0_10:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
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
    mov rax, [rbp-56]
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
