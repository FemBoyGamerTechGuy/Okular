# Okular 0.6 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_main
ok_main_main:
    push rbp
    mov rbp, rsp
    sub rsp, 336
    mov eax, 2
    push rax
    pop rax
    imul rax, 56
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
    xor eax, eax
    push rax
    pop rcx
    pop rax
    imul rcx, rcx, 56
    add rax, rcx
    push rax
    pop rax
    push rax
    mov eax, 33
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_1
    call rt_null_trap
.Lpnk_0_1:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    imul rcx, rcx, 56
    add rax, rcx
    push rax
    pop rax
    add rax, 8
    push rax
    mov eax, 10
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-8]
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
    imul rcx, rcx, 56
    add rax, rcx
    push rax
    pop rax
    add rax, 16
    push rax
    mov eax, 4
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_3
    call rt_null_trap
.Lpnk_0_3:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    imul rcx, rcx, 56
    add rax, rcx
    push rax
    pop rax
    add rax, 24
    push rax
    mov eax, 100
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-8]
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
    imul rcx, rcx, 56
    add rax, rcx
    push rax
    pop rax
    add rax, 32
    push rax
    mov eax, 5
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-8]
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
    imul rcx, rcx, 56
    add rax, rcx
    push rax
    pop rax
    add rax, 40
    push rax
    lea rax, [rip+.Lstr0]
    mov rdx, 2
    push rdx
    push rax
    pop rax
    pop rdx
    pop rcx
    mov [rcx], rax
    mov [rcx+8], rdx
    mov eax, 4
    push rax
    pop rax
    imul rax, 56
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
    xor eax, eax
    push rax
    pop rax
    mov [rbp-24], rax
    mov eax, 1
    push rax
    pop rax
    mov [rbp-32], rax
.L0_0:
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
    jz .L0_2
    mov rax, [rbp-16]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_6
    call rt_null_trap
.Lpnk_0_6:
    push rax
    mov rax, [rbp-24]
    push rax
    pop rcx
    pop rax
    imul rcx, rcx, 56
    add rax, rcx
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_7
    call rt_null_trap
.Lpnk_0_7:
    push rax
    mov rax, [rbp-24]
    push rax
    pop rcx
    pop rax
    imul rcx, rcx, 56
    add rax, rcx
    push rax
    pop rsi
    pop rdi
    mov rcx, 56
    rep movsb
.L0_1:
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
    jmp .L0_0
.L0_2:
    mov rax, [rbp-16]
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
    imul rcx, rcx, 56
    add rax, rcx
    push rax
    pop rax
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov eax, 33
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
    mov rax, [rbp-16]
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
    imul rcx, rcx, 56
    add rax, rcx
    push rax
    pop rax
    add rax, 8
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
    jmp .L0_9
.L0_10:
    mov eax, 0
    push rax
.L0_9:
    pop rax
    test rax, rax
    jz .L0_11
    mov rax, [rbp-16]
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
    imul rcx, rcx, 56
    add rax, rcx
    push rax
    pop rax
    add rax, 16
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov eax, 4
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    jmp .L0_8
.L0_11:
    mov eax, 0
    push rax
.L0_8:
    pop rax
    test rax, rax
    jz .L0_12
    mov rax, [rbp-16]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_11
    call rt_null_trap
.Lpnk_0_11:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    imul rcx, rcx, 56
    add rax, rcx
    push rax
    pop rax
    add rax, 24
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
    jmp .L0_7
.L0_12:
    mov eax, 0
    push rax
.L0_7:
    pop rax
    test rax, rax
    jz .L0_13
    mov rax, [rbp-16]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_12
    call rt_null_trap
.Lpnk_0_12:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    imul rcx, rcx, 56
    add rax, rcx
    push rax
    pop rax
    add rax, 32
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
    jmp .L0_6
.L0_13:
    mov eax, 0
    push rax
.L0_6:
    pop rax
    test rax, rax
    jz .L0_14
    mov rax, [rbp-16]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_13
    call rt_null_trap
.Lpnk_0_13:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    imul rcx, rcx, 56
    add rax, rcx
    push rax
    pop rax
    add rax, 40
    push rax
    pop rax
    mov rdx, [rax+8]
    mov rax, [rax]
    push rdx
    push rax
    lea rax, [rip+.Lstr0]
    mov rdx, 2
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
    jmp .L0_5
.L0_14:
    mov eax, 0
    push rax
.L0_5:
    pop rax
    test rax, rax
    jz .L0_3
    lea rax, [rip+.Lstr1]
    mov rdx, 11
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
.L0_3:
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
    jnz .Lpnk_0_14
    call rt_null_trap
.Lpnk_0_14:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    imul rcx, rcx, 56
    add rax, rcx
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
    mov rax, [rbp-16]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_15
    call rt_null_trap
.Lpnk_0_15:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    imul rcx, rcx, 56
    add rax, rcx
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
    mov rax, [rbp-16]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_16
    call rt_null_trap
.Lpnk_0_16:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    imul rcx, rcx, 56
    add rax, rcx
    push rax
    pop rax
    add rax, 40
    push rax
    pop rax
    mov rdx, [rax+8]
    mov rax, [rax]
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
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    lea rax, [rbp-64]
    push rax
    mov eax, 7
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-56]
    push rax
    mov rax, 0x3fe0000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-48]
    push rax
    lea rax, [rip+.Lstr2]
    mov rdx, 4
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
    imul rax, 32
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_alloc
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_17
    call rt_null_trap
.Lpnk_0_17:
    push rax
    lea rax, [rbp-64]
    push rax
    pop rsi
    pop rdi
    mov rcx, 32
    rep movsb
    mov rax, [rbp-72]
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
    mov eax, 7
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_19
    mov rax, [rbp-72]
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
    mov rax, QWORD PTR [rax]
    push rax
    mov rax, 0x3fe0000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    ucomisd xmm0, xmm1
    sete al
    setnp cl
    and al, cl
    movzx rax, al
    push rax
    jmp .L0_18
.L0_19:
    mov eax, 0
    push rax
.L0_18:
    pop rax
    test rax, rax
    jz .L0_20
    mov rax, [rbp-72]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_20
    call rt_null_trap
.Lpnk_0_20:
    push rax
    pop rax
    add rax, 16
    push rax
    pop rax
    mov rdx, [rax+8]
    mov rax, [rax]
    push rdx
    push rax
    lea rax, [rip+.Lstr2]
    mov rdx, 4
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
    jmp .L0_17
.L0_20:
    mov eax, 0
    push rax
.L0_17:
    pop rax
    test rax, rax
    jz .L0_15
    lea rax, [rip+.Lstr3]
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
.L0_15:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    lea rax, [rbp-136]
    push rax
    mov eax, 1
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-128]
    push rax
    mov rax, 0x3ff8000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-120]
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
    lea rax, [rbp-104]
    push rax
    mov eax, 2
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-96]
    push rax
    mov rax, 0x4004000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-88]
    push rax
    lea rax, [rip+.Lstr5]
    mov rdx, 1
    push rdx
    push rax
    pop rax
    pop rdx
    pop rcx
    mov [rcx], rax
    mov [rcx+8], rdx
    lea rax, [rbp-136]
    push rax
    xor eax, eax
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
    imul rcx, rcx, 32
    add rax, rcx
    push rax
    lea rax, [rbp-136]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_1
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_1:
    imul rcx, rcx, 32
    add rax, rcx
    push rax
    pop rsi
    pop rdi
    mov rcx, 32
    rep movsb
    lea rax, [rbp-136]
    push rax
    xor eax, eax
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
    imul rcx, rcx, 32
    add rax, rcx
    push rax
    pop rax
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_25
    lea rax, [rbp-136]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_3
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_3:
    imul rcx, rcx, 32
    add rax, rcx
    push rax
    pop rax
    add rax, 8
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov rax, 0x4004000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    ucomisd xmm0, xmm1
    sete al
    setnp cl
    and al, cl
    movzx rax, al
    push rax
    jmp .L0_24
.L0_25:
    mov eax, 0
    push rax
.L0_24:
    pop rax
    test rax, rax
    jz .L0_26
    lea rax, [rbp-136]
    push rax
    xor eax, eax
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
    imul rcx, rcx, 32
    add rax, rcx
    push rax
    pop rax
    add rax, 16
    push rax
    pop rax
    mov rdx, [rax+8]
    mov rax, [rax]
    push rdx
    push rax
    lea rax, [rip+.Lstr5]
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
    jmp .L0_23
.L0_26:
    mov eax, 0
    push rax
.L0_23:
    pop rax
    test rax, rax
    jz .L0_21
    lea rax, [rip+.Lstr6]
    mov rdx, 15
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
.L0_21:
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
    mov rax, [rbp-72]
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
    .byte 107, 119
.Lstr1:
    .byte 114, 101, 99, 111, 114, 100, 45, 99, 111, 112, 121
.Lstr2:
    .byte 112, 97, 105, 114
.Lstr3:
    .byte 100, 101, 114, 101, 102, 45, 99, 111, 112, 121
.Lstr4:
    .byte 120
.Lstr5:
    .byte 121
.Lstr6:
    .byte 97, 114, 114, 97, 121, 45, 101, 108, 101, 109, 45, 99, 111, 112, 121
