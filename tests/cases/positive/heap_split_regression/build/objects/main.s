# Okular 0.6 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_main
ok_main_main:
    push rbp
    mov rbp, rsp
    sub rsp, 304
    mov eax, 1
    push rax
    pop rax
    imul rax, 24
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_alloc
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-8], rax
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_0
    call rt_null_trap
.Lpnk_0_0:
    push rax
    pop rax
    push rax
    mov eax, 42
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
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
    mov [rbp-16], rax
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_1
    call rt_null_trap
.Lpnk_0_1:
    push rax
    pop rax
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov eax, 42
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
    lea rax, [rip+.Lstr0]
    mov rdx, 4
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
.L0_0:
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
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_2
    call rt_null_trap
.Lpnk_0_2:
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
    mov rax, [rbp-24]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_3
    call rt_null_trap
.Lpnk_0_3:
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    mov eax, 8
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
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
    mov [rbp-32], rax
    mov rax, [rbp-32]
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
    mov eax, 9
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_5
    call rt_null_trap
.Lpnk_0_5:
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    mov eax, 10
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-24]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_6
    call rt_null_trap
.Lpnk_0_6:
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
    mov eax, 7
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rbp-24]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_7
    call rt_null_trap
.Lpnk_0_7:
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov eax, 8
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rcx
    pop rax
    and rax, rcx
    push rax
    mov rax, [rbp-32]
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
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov eax, 9
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rcx
    pop rax
    and rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_9
    call rt_null_trap
.Lpnk_0_9:
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov eax, 10
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rcx
    pop rax
    and rax, rcx
    push rax
    pop rax
    test rax, rax
    jz .L0_2
    lea rax, [rip+.Lstr1]
    mov rdx, 7
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
.L0_2:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov eax, 1
    push rax
    pop rax
    imul rax, 24
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
    jnz .Lpnk_0_10
    call rt_null_trap
.Lpnk_0_10:
    push rax
    pop rax
    push rax
    mov eax, 100
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-40]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_11
    call rt_null_trap
.Lpnk_0_11:
    push rax
    pop rax
    add rax, 8
    push rax
    lea rax, [rip+.Lstr2]
    mov rdx, 1
    push rdx
    push rax
    pop rax
    pop rdx
    pop rcx
    mov [rcx], rax
    mov [rcx+8], rdx
    mov eax, 1
    push rax
    pop rax
    imul rax, 24
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
    jnz .Lpnk_0_12
    call rt_null_trap
.Lpnk_0_12:
    push rax
    pop rax
    push rax
    mov eax, 200
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-48]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_13
    call rt_null_trap
.Lpnk_0_13:
    push rax
    pop rax
    add rax, 8
    push rax
    lea rax, [rip+.Lstr3]
    mov rdx, 1
    push rdx
    push rax
    pop rax
    pop rdx
    pop rcx
    mov [rcx], rax
    mov [rcx+8], rdx
    mov eax, 1
    push rax
    pop rax
    imul rax, 24
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
    jnz .Lpnk_0_14
    call rt_null_trap
.Lpnk_0_14:
    push rax
    pop rax
    push rax
    mov eax, 300
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-56]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_15
    call rt_null_trap
.Lpnk_0_15:
    push rax
    pop rax
    add rax, 8
    push rax
    lea rax, [rip+.Lstr4]
    mov rdx, 1
    push rdx
    push rax
    pop rax
    pop rdx
    pop rcx
    mov [rcx], rax
    mov [rcx+8], rdx
    mov rax, [rbp-40]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_16
    call rt_null_trap
.Lpnk_0_16:
    push rax
    pop rax
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov eax, 100
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rbp-48]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_17
    call rt_null_trap
.Lpnk_0_17:
    push rax
    pop rax
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov eax, 200
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rcx
    pop rax
    and rax, rcx
    push rax
    mov rax, [rbp-56]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_18
    call rt_null_trap
.Lpnk_0_18:
    push rax
    pop rax
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov eax, 300
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rcx
    pop rax
    and rax, rcx
    push rax
    pop rax
    test rax, rax
    jz .L0_4
    lea rax, [rip+.Lstr5]
    mov rdx, 10
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
.L0_4:
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
    jnz .Lpnk_0_19
    call rt_null_trap
.Lpnk_0_19:
    push rax
    pop rax
    add rax, 8
    push rax
    pop rax
    mov rdx, [rax+8]
    mov rax, [rax]
    push rdx
    push rax
    lea rax, [rip+.Lstr2]
    mov rdx, 1
    push rdx
    push rax
    pop rax
    pop rdx
    mov r9, rax
    mov r10, rdx
    pop rax
    pop rdx
    mov rsi, rdx
    mov rdi, rax
    mov rdx, r9
    mov rcx, r10
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_eq
    mov rsp, rbx
    pop rbx
    movzx rax, al
    push rax
    mov rax, [rbp-48]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_20
    call rt_null_trap
.Lpnk_0_20:
    push rax
    pop rax
    add rax, 8
    push rax
    pop rax
    mov rdx, [rax+8]
    mov rax, [rax]
    push rdx
    push rax
    lea rax, [rip+.Lstr3]
    mov rdx, 1
    push rdx
    push rax
    pop rax
    pop rdx
    mov r9, rax
    mov r10, rdx
    pop rax
    pop rdx
    mov rsi, rdx
    mov rdi, rax
    mov rdx, r9
    mov rcx, r10
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_eq
    mov rsp, rbx
    pop rbx
    movzx rax, al
    push rax
    pop rcx
    pop rax
    and rax, rcx
    push rax
    mov rax, [rbp-56]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_21
    call rt_null_trap
.Lpnk_0_21:
    push rax
    pop rax
    add rax, 8
    push rax
    pop rax
    mov rdx, [rax+8]
    mov rax, [rax]
    push rdx
    push rax
    lea rax, [rip+.Lstr4]
    mov rdx, 1
    push rdx
    push rax
    pop rax
    pop rdx
    mov r9, rax
    mov r10, rdx
    pop rax
    pop rdx
    mov rsi, rdx
    mov rdi, rax
    mov rdx, r9
    mov rcx, r10
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_eq
    mov rsp, rbx
    pop rbx
    movzx rax, al
    push rax
    pop rcx
    pop rax
    and rax, rcx
    push rax
    pop rax
    test rax, rax
    jz .L0_6
    lea rax, [rip+.Lstr6]
    mov rdx, 4
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
.L0_6:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
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
    mov [rbp-64], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-72], rax
    mov eax, 8
    push rax
    pop rax
    mov [rbp-80], rax
.L0_8:
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-80]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_10
    mov rax, [rbp-64]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_22
    call rt_null_trap
.Lpnk_0_22:
    push rax
    mov rax, [rbp-72]
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
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
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-64]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_23
    call rt_null_trap
.Lpnk_0_23:
    push rax
    mov rax, [rbp-72]
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_24
    call rt_null_trap
.Lpnk_0_24:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    mov rax, [rbp-72]
    push rax
    mov eax, 11
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
.L0_9:
    mov rax, [rbp-72]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-72], rax
    jmp .L0_8
.L0_10:
    xor eax, eax
    push rax
    pop rax
    mov [rbp-88], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-96], rax
    mov eax, 8
    push rax
    pop rax
    mov [rbp-104], rax
.L0_11:
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-104]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_13
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-64]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_25
    call rt_null_trap
.Lpnk_0_25:
    push rax
    mov rax, [rbp-96]
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_26
    call rt_null_trap
.Lpnk_0_26:
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
    mov [rbp-88], rax
.L0_12:
    mov rax, [rbp-96]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-96], rax
    jmp .L0_11
.L0_13:
    mov rax, [rbp-88]
    push rax
    mov eax, 308
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_14
    lea rax, [rip+.Lstr7]
    mov rdx, 3
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
.L0_14:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-24]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_release
    mov rsp, rbx
    pop rbx
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
    mov [rbp-112], rax
    mov rax, [rbp-112]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_27
    call rt_null_trap
.Lpnk_0_27:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    mov eax, 5
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-112]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_28
    call rt_null_trap
.Lpnk_0_28:
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    mov eax, 6
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-112]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_29
    call rt_null_trap
.Lpnk_0_29:
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
    mov eax, 5
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rbp-112]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_30
    call rt_null_trap
.Lpnk_0_30:
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov eax, 6
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rcx
    pop rax
    and rax, rcx
    push rax
    mov rax, [rbp-64]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_31
    call rt_null_trap
.Lpnk_0_31:
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
    test rax, rax
    jnz .Lpnk_0_32
    call rt_null_trap
.Lpnk_0_32:
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
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rcx
    pop rax
    and rax, rcx
    push rax
    mov rax, [rbp-64]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_33
    call rt_null_trap
.Lpnk_0_33:
    push rax
    mov eax, 7
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_34
    call rt_null_trap
.Lpnk_0_34:
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
    mov eax, 77
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rcx
    pop rax
    and rax, rcx
    push rax
    pop rax
    test rax, rax
    jz .L0_16
    lea rax, [rip+.Lstr8]
    mov rdx, 5
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
.L0_16:
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
    mov rax, [rbp-64]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_release
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-112]
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
    call ok_main_main
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    leave
    ret

    .section .rodata
.Lstr0:
    .byte 107, 101, 101, 112
.Lstr1:
    .byte 110, 111, 100, 101, 108, 97, 121
.Lstr2:
    .byte 112
.Lstr3:
    .byte 113
.Lstr4:
    .byte 114
.Lstr5:
    .byte 105, 110, 116, 101, 114, 108, 101, 97, 118, 101
.Lstr6:
    .byte 116, 97, 103, 115
.Lstr7:
    .byte 115, 101, 113
.Lstr8:
    .byte 114, 101, 117, 115, 101
