# Okular 0.4 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_run
ok_main_run:
    push rbp
    mov rbp, rsp
    sub rsp, 432
    lea rax, [rbp-48]
    push rax
    mov eax, 1
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-40]
    push rax
    mov eax, 2
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-32]
    push rax
    mov eax, 3
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-24]
    push rax
    mov eax, 4
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-16]
    push rax
    mov eax, 5
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-8]
    push rax
    mov eax, 6
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-48]
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
    imul rcx, rcx, 16
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
    lea rax, [rbp-48]
    push rax
    mov eax, 1
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
    imul rcx, rcx, 16
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
    lea rax, [rbp-48]
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_0_2
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_2:
    imul rcx, rcx, 16
    add rax, rcx
    push rax
    pop rax
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    lea rax, [rbp-48]
    push rax
    mov eax, 2
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
    imul rcx, rcx, 16
    add rax, rcx
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
    lea rax, [rbp-48]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_0_4
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_4:
    imul rcx, rcx, 16
    add rax, rcx
    push rax
    pop rax
    push rax
    mov eax, 30
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-48]
    push rax
    mov eax, 1
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
    imul rcx, rcx, 16
    add rax, rcx
    push rax
    pop rax
    add rax, 8
    push rax
    mov eax, 40
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-48]
    push rax
    mov eax, 1
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
    pop rax
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    lea rax, [rbp-48]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_0_7
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_7:
    imul rcx, rcx, 16
    add rax, rcx
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
    xor eax, eax
    push rax
    pop rax
    mov [rbp-56], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-64], rax
    mov eax, 3
    push rax
    pop rax
    mov [rbp-72], rax
.L0_0:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-72]
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
    mov rax, [rbp-56]
    push rax
    lea rax, [rbp-48]
    push rax
    mov rax, [rbp-64]
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
    pop rax
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-56], rax
.L0_1:
    mov rax, [rbp-64]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-64], rax
    jmp .L0_0
.L0_2:
    mov rax, [rbp-56]
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
    lea rax, [rbp-104]
    push rax
    mov eax, 10
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-96]
    push rax
    mov eax, 20
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-88]
    push rax
    mov eax, 30
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-80]
    push rax
    mov eax, 40
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-136]
    push rax
    lea rax, [rbp-104]
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
    imul rcx, rcx, 16
    add rax, rcx
    push rax
    pop rax
    push rax
    mov eax, 999
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-104]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_10
    mov rdi, rcx
    mov rsi, 2
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
    lea rax, [rbp-144]
    push rax
    mov eax, 1
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-143]
    push rax
    mov eax, 2
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-142]
    push rax
    mov eax, 3
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-141]
    push rax
    mov eax, 4
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-140]
    push rax
    mov eax, 5
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-139]
    push rax
    mov eax, 6
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-138]
    push rax
    mov eax, 7
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-137]
    push rax
    mov eax, 8
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    xor eax, eax
    push rax
    pop rax
    mov [rbp-152], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-160], rax
    mov eax, 4
    push rax
    pop rax
    mov [rbp-168], rax
.L0_3:
    mov rax, [rbp-160]
    push rax
    mov rax, [rbp-168]
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
    mov rax, [rbp-152]
    push rax
    lea rax, [rbp-144]
    push rax
    mov rax, [rbp-160]
    push rax
    pop rcx
    pop rax
    cmp rcx, 4
    jb .Lbok_0_11
    mov rdi, rcx
    mov rsi, 4
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_11:
    lea rax, [rax + rcx*2]
    push rax
    pop rax
    push rax
    pop rax
    movsx rax, BYTE PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 56
    sar rax, 56
    push rax
    lea rax, [rbp-144]
    push rax
    mov rax, [rbp-160]
    push rax
    pop rcx
    pop rax
    cmp rcx, 4
    jb .Lbok_0_12
    mov rdi, rcx
    mov rsi, 4
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_12:
    lea rax, [rax + rcx*2]
    push rax
    pop rax
    add rax, 1
    push rax
    pop rax
    movsx rax, BYTE PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 56
    sar rax, 56
    push rax
    pop rax
    mov [rbp-152], rax
.L0_4:
    mov rax, [rbp-160]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-160], rax
    jmp .L0_3
.L0_5:
    mov rax, [rbp-152]
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
    lea rax, [rbp-232]
    push rax
    mov eax, 1
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-224]
    push rax
    mov eax, 2
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-216]
    push rax
    mov eax, 3
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-208]
    push rax
    mov eax, 4
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-200]
    push rax
    mov eax, 5
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-192]
    push rax
    mov eax, 6
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-184]
    push rax
    mov eax, 7
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-176]
    push rax
    mov eax, 8
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-232]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_13
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_13:
    imul rcx, rcx, 32
    add rax, rcx
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_14
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_14:
    imul rcx, rcx, 16
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
    lea rax, [rbp-232]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_15
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_15:
    imul rcx, rcx, 32
    add rax, rcx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_16
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_16:
    imul rcx, rcx, 16
    add rax, rcx
    push rax
    pop rax
    add rax, 8
    push rax
    mov eax, 99
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-232]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_17
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_17:
    imul rcx, rcx, 32
    add rax, rcx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_18
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_18:
    imul rcx, rcx, 16
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
    mov [rbp-240], rax
    mov rax, [rbp-240]
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
    imul rcx, rcx, 32
    add rax, rcx
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_19
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_19:
    imul rcx, rcx, 16
    add rax, rcx
    push rax
    pop rax
    push rax
    mov eax, 111
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-240]
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
    imul rcx, rcx, 32
    add rax, rcx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_20
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_20:
    imul rcx, rcx, 16
    add rax, rcx
    push rax
    pop rax
    add rax, 8
    push rax
    mov eax, 222
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-240]
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
    imul rcx, rcx, 32
    add rax, rcx
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_21
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_21:
    imul rcx, rcx, 16
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
    mov rax, [rbp-240]
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
    imul rcx, rcx, 32
    add rax, rcx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_22
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_22:
    imul rcx, rcx, 16
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
    mov rax, [rbp-240]
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
