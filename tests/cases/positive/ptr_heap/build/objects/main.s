# Okular 0.3 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_run
ok_main_run:
    push rbp
    mov rbp, rsp
    sub rsp, 272
    mov eax, 3
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
    lea rax, [rax + rcx*8]
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
    mov eax, 20
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
    mov eax, 2
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    mov eax, 30
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
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_4
    call rt_null_trap
.Lpnk_0_4:
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
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_5
    call rt_null_trap
.Lpnk_0_5:
    push rax
    mov eax, 2
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
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_6
    call rt_null_trap
.Lpnk_0_6:
    push rax
    mov eax, 5
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-16]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    imul rcx, 8
    add rax, rcx
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_7
    call rt_null_trap
.Lpnk_0_7:
    push rax
    mov eax, 7
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-16]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_8
    call rt_null_trap
.Lpnk_0_8:
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov rax, [rbp-16]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    imul rcx, 8
    add rax, rcx
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_9
    call rt_null_trap
.Lpnk_0_9:
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
    mov eax, 4
    push rax
    pop rax
    imul rax, 4
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
    jnz .Lpnk_0_10
    call rt_null_trap
.Lpnk_0_10:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*4]
    push rax
    mov rax, 18446744073709551615
    push rax
    pop rax
    pop rcx
    mov DWORD PTR [rcx], eax
    mov rax, [rbp-24]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_11
    call rt_null_trap
.Lpnk_0_11:
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*4]
    push rax
    mov rax, 18446744073709551614
    push rax
    pop rax
    pop rcx
    mov DWORD PTR [rcx], eax
    mov rax, [rbp-24]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_12
    call rt_null_trap
.Lpnk_0_12:
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*4]
    push rax
    mov rax, 18446744073709551613
    push rax
    pop rax
    pop rcx
    mov DWORD PTR [rcx], eax
    mov rax, [rbp-24]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_13
    call rt_null_trap
.Lpnk_0_13:
    push rax
    mov eax, 3
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*4]
    push rax
    mov rax, 18446744073709551612
    push rax
    pop rax
    pop rcx
    mov DWORD PTR [rcx], eax
    mov rax, [rbp-24]
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
    lea rax, [rax + rcx*4]
    push rax
    pop rax
    movsxd rax, DWORD PTR [rax]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_15
    call rt_null_trap
.Lpnk_0_15:
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*4]
    push rax
    pop rax
    movsxd rax, DWORD PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 32
    sar rax, 32
    push rax
    mov rax, [rbp-24]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_16
    call rt_null_trap
.Lpnk_0_16:
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*4]
    push rax
    pop rax
    movsxd rax, DWORD PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 32
    sar rax, 32
    push rax
    mov rax, [rbp-24]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_17
    call rt_null_trap
.Lpnk_0_17:
    push rax
    mov eax, 3
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*4]
    push rax
    pop rax
    movsxd rax, DWORD PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 32
    sar rax, 32
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
    mov eax, 4
    push rax
    pop rax
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
    jnz .Lpnk_0_18
    call rt_null_trap
.Lpnk_0_18:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov eax, 200
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_19
    call rt_null_trap
.Lpnk_0_19:
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov eax, 100
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_20
    call rt_null_trap
.Lpnk_0_20:
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov eax, 50
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_21
    call rt_null_trap
.Lpnk_0_21:
    push rax
    mov eax, 3
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov eax, 6
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_22
    call rt_null_trap
.Lpnk_0_22:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_23
    call rt_null_trap
.Lpnk_0_23:
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 56
    shr rax, 56
    push rax
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_24
    call rt_null_trap
.Lpnk_0_24:
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 56
    shr rax, 56
    push rax
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_25
    call rt_null_trap
.Lpnk_0_25:
    push rax
    mov eax, 3
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 56
    shr rax, 56
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
    mov [rbp-40], rax
    mov rax, [rbp-40]
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
    mov rax, 0x3ff8000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-40]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_27
    call rt_null_trap
.Lpnk_0_27:
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    lea rax, [rax + rcx*8]
    push rax
    mov rax, 0x4002000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-40]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_28
    call rt_null_trap
.Lpnk_0_28:
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
    mov rax, [rbp-40]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_29
    call rt_null_trap
.Lpnk_0_29:
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
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    addsd xmm0, xmm1
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_decimal
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
    jnz .Lpnk_0_30
    call rt_null_trap
.Lpnk_0_30:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov eax, 1
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, [rbp-48]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_31
    call rt_null_trap
.Lpnk_0_31:
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov eax, 0
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, [rbp-48]
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
    add rax, rcx
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
.L0_0:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
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
    mov eax, 2
    push rax
    pop rax
    imul rax, 16
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
    jnz .Lpnk_0_33
    call rt_null_trap
.Lpnk_0_33:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    imul rcx, rcx, 16
    add rax, rcx
    push rax
    lea rax, [rip+.Lstr0]
    mov rdx, 4
    push rdx
    push rax
    pop rax
    pop rdx
    pop rcx
    mov [rcx], rax
    mov [rcx+8], rdx
    mov rax, [rbp-56]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_34
    call rt_null_trap
.Lpnk_0_34:
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    imul rcx, rcx, 16
    add rax, rcx
    push rax
    lea rax, [rip+.Lstr1]
    mov rdx, 4
    push rdx
    push rax
    pop rax
    pop rdx
    pop rcx
    mov [rcx], rax
    mov [rcx+8], rdx
    mov rax, [rbp-56]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_35
    call rt_null_trap
.Lpnk_0_35:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    imul rcx, rcx, 16
    add rax, rcx
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
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_36
    call rt_null_trap
.Lpnk_0_36:
    push rax
    lea rax, [rip+ok_main_source]
    push rax
    pop rsi
    pop rdi
    mov rcx, 24
    rep movsb
    mov rax, [rbp-64]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_37
    call rt_null_trap
.Lpnk_0_37:
    push rax
    xor eax, eax
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
    mov rax, [rbp-64]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_38
    call rt_null_trap
.Lpnk_0_38:
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
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_39
    call rt_null_trap
.Lpnk_0_39:
    push rax
    mov eax, 42
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-72]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_40
    call rt_null_trap
.Lpnk_0_40:
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
    call ok_main_run
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    leave
    ret

    .section .rodata
.Lstr0:
    .byte 104, 101, 97, 112
.Lstr1:
    .byte 116, 101, 120, 116

    .section .data
    .globl ok_main_source
    .balign 8
ok_main_source:
    .quad 7
    .quad 8
    .quad 9
