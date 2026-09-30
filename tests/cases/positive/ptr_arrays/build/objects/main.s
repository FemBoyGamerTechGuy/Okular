# Okular 0.3 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_zero_via_ptr
ok_main_zero_via_ptr:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    xor eax, eax
    push rax
    pop rax
    mov [rbp-24], rax
    mov rax, [rbp-16]
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
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rcx
    pop rax
    imul rcx, 8
    add rax, rcx
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_0
    call rt_null_trap
.Lpnk_0_0:
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
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
    xor eax, eax
    leave
    ret

    .globl ok_main_sum_via_ptr
ok_main_sum_via_ptr:
    push rbp
    mov rbp, rsp
    sub rsp, 240
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    xor eax, eax
    push rax
    pop rax
    mov [rbp-24], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    pop rax
    mov [rbp-40], rax
.L1_0:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L1_2
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rcx
    pop rax
    imul rcx, 8
    add rax, rcx
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_1_0
    call rt_null_trap
.Lpnk_1_0:
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-24], rax
.L1_1:
    mov rax, [rbp-32]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-32], rax
    jmp .L1_0
.L1_2:
    mov rax, [rbp-24]
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
    sub rsp, 336
    lea rax, [rbp-24]
    push rax
    mov eax, 10
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-16]
    push rax
    mov eax, 20
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-8]
    push rax
    mov eax, 30
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-24]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_2_0
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_2_0:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov [rbp-32], rax
    mov rax, [rbp-32]
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
    test rax, rax
    jnz .Lpnk_2_1
    call rt_null_trap
.Lpnk_2_1:
    push rax
    mov eax, 200
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-24]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_2_1
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_2_1:
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
    lea rax, [rbp-24]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_2_2
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_2_2:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov [rbp-40], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    cqo
    mov rcx, 8
    idiv rcx
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
    mov eax, 3
    push rax
    lea rax, [rbp-24]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_2_3
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_2_3:
    lea rax, [rax + rcx*8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-232], rax
    mov rax, [rsp+8]
    mov [rbp-216], rax
    add rsp, 16
    mov rdi, [rbp-232]
    mov rsi, [rbp-216]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_sum_via_ptr
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-48], rax
    mov rax, [rbp-48]
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
    lea rax, [rbp-56]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov eax, 3
    push rax
    lea rax, [rbp-72]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_2_4
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_2_4:
    lea rax, [rax + rcx*8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-232], rax
    mov rax, [rsp+8]
    mov [rbp-216], rax
    add rsp, 16
    mov rdi, [rbp-232]
    mov rsi, [rbp-216]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_zero_via_ptr
    mov rsp, rbx
    pop rbx
    lea rax, [rbp-72]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_2_5
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_2_5:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    lea rax, [rbp-72]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_2_6
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_2_6:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-72]
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_2_7
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_2_7:
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
    lea rax, [rip+ok_main_data]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 4
    jb .Lbok_2_8
    mov rdi, rcx
    mov rsi, 4
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_2_8:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov [rbp-80], rax
    mov rax, [rbp-80]
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    imul rcx, 8
    add rax, rcx
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_2_2
    call rt_null_trap
.Lpnk_2_2:
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
    mov rax, [rbp-80]
    push rax
    mov eax, 3
    push rax
    pop rcx
    pop rax
    imul rcx, 8
    add rax, rcx
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_2_3
    call rt_null_trap
.Lpnk_2_3:
    push rax
    mov eax, 400
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rip+ok_main_data]
    push rax
    mov eax, 3
    push rax
    pop rcx
    pop rax
    cmp rcx, 4
    jb .Lbok_2_9
    mov rdi, rcx
    mov rsi, 4
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_2_9:
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
    lea rax, [rbp-112]
    push rax
    mov eax, 1
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-104]
    push rax
    mov eax, 2
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-96]
    push rax
    mov eax, 3
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-88]
    push rax
    mov eax, 4
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-112]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_2_10
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_2_10:
    imul rcx, rcx, 16
    add rax, rcx
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_2_11
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_2_11:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov [rbp-120], rax
    mov rax, [rbp-120]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_2_4
    call rt_null_trap
.Lpnk_2_4:
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
    mov rax, [rbp-120]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_2_5
    call rt_null_trap
.Lpnk_2_5:
    push rax
    mov eax, 30
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-112]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_2_12
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_2_12:
    imul rcx, rcx, 16
    add rax, rcx
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_2_13
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_2_13:
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
    lea rax, [rbp-128]
    push rax
    mov rax, 18446744073709551615
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-127]
    push rax
    mov rax, 18446744073709551614
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-126]
    push rax
    mov rax, 18446744073709551613
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-125]
    push rax
    mov rax, 18446744073709551612
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-128]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 4
    jb .Lbok_2_14
    mov rdi, rcx
    mov rsi, 4
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_2_14:
    lea rax, [rax + rcx*1]
    push rax
    pop rax
    mov [rbp-136], rax
    mov rax, [rbp-136]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_2_6
    call rt_null_trap
.Lpnk_2_6:
    push rax
    pop rax
    movsx rax, BYTE PTR [rax]
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
    mov rax, [rbp-136]
    push rax
    mov eax, 3
    push rax
    pop rcx
    pop rax
    imul rcx, 1
    add rax, rcx
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_2_7
    call rt_null_trap
.Lpnk_2_7:
    push rax
    mov eax, 127
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-128]
    push rax
    mov eax, 3
    push rax
    pop rcx
    pop rax
    cmp rcx, 4
    jb .Lbok_2_15
    mov rdi, rcx
    mov rsi, 4
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_2_15:
    lea rax, [rax + rcx*1]
    push rax
    pop rax
    movsx rax, BYTE PTR [rax]
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

    .section .data
    .globl ok_main_data
    .balign 8
ok_main_data:
    .quad 1
    .quad 2
    .quad 3
    .quad 4
