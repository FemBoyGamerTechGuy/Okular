# Okular 0.6 bootstrap — x86-64 Linux assembly
# module: rt
    .intel_syntax noprefix

    .text

    .globl ok_rt_rd64
ok_rt_rd64:
    push rbp
    mov rbp, rsp
    sub rsp, 240
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    mov r11, [rsp+32]
    mov [rbp-16], r11
    add rsp, 48
    xor eax, eax
    push rax
    pop rax
    mov [rbp-24], rax
    mov eax, 1
    push rax
    pop rax
    mov [rbp-32], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-40], rax
    mov eax, 8
    push rax
    pop rax
    mov [rbp-48], rax
.L0_0:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
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
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_0
    call rt_null_trap
.Lpnk_0_0:
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-40]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
    push rax
    pop rax
    push rax
    mov rax, [rbp-32]
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-24], rax
    mov rax, [rbp-32]
    push rax
    mov eax, 256
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    pop rax
    mov [rbp-32], rax
.L0_1:
    mov rax, [rbp-40]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-40], rax
    jmp .L0_0
.L0_2:
    mov rax, [rbp-24]
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_wr64
ok_rt_wr64:
    push rbp
    mov rbp, rsp
    sub rsp, 240
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    mov r11, [rsp+32]
    mov [rbp-16], r11
    mov r11, [rsp+24]
    mov [rbp-24], r11
    add rsp, 48
    mov eax, 1
    push rax
    pop rax
    mov [rbp-32], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-40], rax
    mov eax, 8
    push rax
    pop rax
    mov [rbp-48], rax
.L1_0:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
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
    mov rax, [rbp-40]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_1_1
    call rt_div_trap
.Ldvk_1_1:
    cmp rcx, -1
    jne .Ldvo_1_1
    neg rax
    jmp .Ldvd_1_1
.Ldvo_1_1:
    cqo
    idiv rcx
.Ldvd_1_1:
    push rax
    pop rax
    shl rax, 56
    shr rax, 56
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, [rbp-32]
    push rax
    mov eax, 256
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    pop rax
    mov [rbp-32], rax
.L1_1:
    mov rax, [rbp-40]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-40], rax
    jmp .L1_0
.L1_2:
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_pot
ok_rt_pot:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
    mov eax, 1
    push rax
    pop rax
    mov [rbp-16], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-24], rax
    mov rax, [rbp-8]
    push rax
    pop rax
    mov [rbp-32], rax
.L2_0:
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
    jz .L2_2
    mov rax, [rbp-16]
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    pop rax
    mov [rbp-16], rax
.L2_1:
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
    jmp .L2_0
.L2_2:
    mov rax, [rbp-16]
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_wr_byte
ok_rt_wr_byte:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    mov r11, [rsp+32]
    mov [rbp-16], r11
    mov r11, [rsp+24]
    mov [rbp-24], r11
    add rsp, 48
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_3_0
    call rt_null_trap
.Lpnk_3_0:
    push rax
    mov rax, [rbp-16]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    pop rax
    shl rax, 56
    shr rax, 56
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_out_ensure
ok_rt_out_ensure:
    push rbp
    mov rbp, rsp
    sub rsp, 192
    mov rax, QWORD PTR [rip+ok_rt_out_buf]
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
    jz .L4_0
    mov eax, 65536
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_mmap
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_out_buf], rax
    mov rax, QWORD PTR [rip+ok_rt_out_buf]
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
    jz .L4_2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_raw_die
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L4_2:
    xor eax, eax
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_out_len], rax
.L4_0:
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_out_reserve
ok_rt_out_reserve:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
    mov rax, QWORD PTR [rip+ok_rt_out_len]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov eax, 65536
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L5_0
    mov eax, 75
    push rax
    lea rax, [rip+.Lstr0]
    mov rdx, 79
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    mov rdx, [rsp+8]
    mov [rbp-96], rdx
    mov rax, [rsp+16]
    mov [rbp-88], rax
    add rsp, 24
    lea rdi, [rbp-104]
    mov rsi, [rbp-88]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_trap
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L5_0:
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_put_byte
ok_rt_put_byte:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_out_ensure
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, QWORD PTR [rip+ok_rt_out_buf]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_6_0
    call rt_null_trap
.Lpnk_6_0:
    push rax
    mov rax, QWORD PTR [rip+ok_rt_out_len]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    shl rax, 56
    shr rax, 56
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, QWORD PTR [rip+ok_rt_out_len]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_out_len], rax
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_put_dec_digits
ok_rt_put_dec_digits:
    push rbp
    mov rbp, rsp
    sub rsp, 384
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
    lea rax, [rbp-168]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-160]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-152]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-144]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-136]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-128]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-120]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-112]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-104]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-96]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-88]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-80]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
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
    lea rax, [rbp-48]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-40]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-32]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-24]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-16]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-176], rax
.L7_0:
    mov rax, [rbp-8]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L7_2
    lea rax, [rbp-168]
    push rax
    mov rax, [rbp-176]
    push rax
    pop rcx
    pop rax
    cmp rcx, 20
    jb .Lbok_7_0
    mov rdi, rcx
    mov rsi, 20
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_7_0:
    lea rax, [rax + rcx*8]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-8]
    push rax
    mov eax, 10
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_7_0
    call rt_div_trap
.Ldvk_7_0:
    cmp rcx, -1
    jne .Ldvo_7_0
    neg rax
    jmp .Ldvd_7_0
.Ldvo_7_0:
    cqo
    idiv rcx
.Ldvd_7_0:
    push rax
    mov eax, 10
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-8]
    push rax
    mov eax, 10
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_7_1
    call rt_div_trap
.Ldvk_7_1:
    cmp rcx, -1
    jne .Ldvo_7_1
    neg rax
    jmp .Ldvd_7_1
.Ldvo_7_1:
    cqo
    idiv rcx
.Ldvd_7_1:
    push rax
    pop rax
    mov [rbp-8], rax
    mov rax, [rbp-176]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-176], rax
.L7_1:
    jmp .L7_0
.L7_2:
    mov rax, [rbp-176]
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
    jz .L7_3
    mov eax, 48
    push rax
    mov rax, [rsp+0]
    mov [rbp-288], rax
    add rsp, 8
    mov rdi, [rbp-288]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_put_byte
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L7_3:
    xor eax, eax
    push rax
    pop rax
    mov [rbp-184], rax
    mov rax, [rbp-176]
    push rax
    pop rax
    mov [rbp-192], rax
.L7_5:
    mov rax, [rbp-184]
    push rax
    mov rax, [rbp-192]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L7_7
    mov eax, 48
    push rax
    lea rax, [rbp-168]
    push rax
    mov rax, [rbp-176]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rbp-184]
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    pop rcx
    pop rax
    cmp rcx, 20
    jb .Lbok_7_1
    mov rdi, rcx
    mov rsi, 20
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_7_1:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rsp+0]
    mov [rbp-288], rax
    add rsp, 8
    mov rdi, [rbp-288]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_put_byte
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L7_6:
    mov rax, [rbp-184]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-184], rax
    jmp .L7_5
.L7_7:
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_write_number
ok_rt_write_number:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_out_ensure
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-8]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L8_0
    mov eax, 1
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    add rsp, 8
    mov rdi, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_out_reserve
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 45
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    add rsp, 8
    mov rdi, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_put_byte
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    mov rax, [rbp-8]
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L8_2
    lea rax, [rip+.Lstr1]
    mov rdx, 19
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    mov rdx, [rsp+8]
    mov [rbp-96], rdx
    add rsp, 16
    lea rdi, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_text
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    leave
    ret
.L8_2:
    xor eax, eax
    push rax
    mov rax, [rbp-8]
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    pop rax
    mov [rbp-8], rax
.L8_0:
    mov eax, 20
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    add rsp, 8
    mov rdi, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_out_reserve
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    add rsp, 8
    mov rdi, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_put_dec_digits
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_write_uint
ok_rt_write_uint:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_out_ensure
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 20
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    add rsp, 8
    mov rdi, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_out_reserve
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    add rsp, 8
    mov rdi, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_put_dec_digits
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_write_text
ok_rt_write_text:
    push rbp
    mov rbp, rsp
    sub rsp, 240
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov rax, [r11]
    mov rdx, [r11+8]
    mov [rbp-16], rax
    mov [rbp-8], rdx
    add rsp, 48
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_out_ensure
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    pop rax
    pop rdx
    mov rax, rdx
    push rax
    pop rax
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rsp+0]
    mov [rbp-136], rax
    add rsp, 8
    mov rdi, [rbp-136]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_out_reserve
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    pop rax
    mov [rbp-40], rax
.L10_0:
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
    jz .L10_2
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rbp-32]
    push rax
    pop r11
    pop rax
    pop rdx
    cmp r11, rdx
    jb .Lbok_10_0
    mov rdi, r11
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_10_0:
    movzx rax, BYTE PTR [rax + r11]
    push rax
    pop rax
    push rax
    mov rax, [rsp+0]
    mov [rbp-136], rax
    add rsp, 8
    mov rdi, [rbp-136]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_put_byte
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L10_1:
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
    jmp .L10_0
.L10_2:
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_write_bool
ok_rt_write_bool:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
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
    jz .L11_0
    lea rax, [rip+.Lstr2]
    mov rdx, 4
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    mov rdx, [rsp+8]
    mov [rbp-96], rdx
    add rsp, 16
    lea rdi, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_text
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    jmp .L11_1
.L11_0:
    lea rax, [rip+.Lstr3]
    mov rdx, 5
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    mov rdx, [rsp+8]
    mov [rbp-96], rdx
    add rsp, 16
    lea rdi, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_text
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L11_1:
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_write_decimal
ok_rt_write_decimal:
    push rbp
    mov rbp, rsp
    sub rsp, 304
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-8]
    push rax
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    ucomisd xmm0, xmm1
    setne al
    setp cl
    or al, cl
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L12_0
    lea rax, [rip+.Lstr4]
    mov rdx, 3
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rdx, [rsp+8]
    mov [rbp-200], rdx
    add rsp, 16
    lea rdi, [rbp-208]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_text
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    leave
    ret
.L12_0:
    mov rax, [rbp-8]
    push rax
    mov rax, 0x0000000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    ucomisd xmm1, xmm0
    seta al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L12_2
    lea rax, [rip+.Lstr5]
    mov rdx, 1
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rdx, [rsp+8]
    mov [rbp-200], rdx
    add rsp, 16
    lea rdi, [rbp-208]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_text
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, 0x0000000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    mov rax, [rbp-8]
    push rax
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    subsd xmm0, xmm1
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    pop rax
    mov [rbp-8], rax
.L12_2:
    mov rax, [rbp-8]
    push rax
    mov rax, 0x0000000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    ucomisd xmm0, xmm1
    setne al
    setp cl
    or al, cl
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L12_7
    mov rax, [rbp-8]
    push rax
    mov rax, 0x4000000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    mulsd xmm0, xmm1
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    mov rax, [rbp-8]
    push rax
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
    jmp .L12_6
.L12_7:
    mov eax, 0
    push rax
.L12_6:
    pop rax
    test rax, rax
    jz .L12_4
    lea rax, [rip+.Lstr6]
    mov rdx, 3
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rdx, [rsp+8]
    mov [rbp-200], rdx
    add rsp, 16
    lea rdi, [rbp-208]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_text
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    leave
    ret
.L12_4:
    mov rax, [rbp-8]
    push rax
    mov rax, 0x430c6bf526340000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    ucomisd xmm0, xmm1
    setae al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L12_8
    mov rax, [rbp-8]
    push rax
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    cvttsd2si rax, xmm0
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    add rsp, 8
    mov rdi, [rbp-208]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_number
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    leave
    ret
.L12_8:
    mov rax, [rbp-8]
    push rax
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    cvttsd2si rax, xmm0
    push rax
    pop rax
    mov [rbp-16], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rax
    cvtsi2sd xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    subsd xmm0, xmm1
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    pop rax
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0x412e848000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    mulsd xmm0, xmm1
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    mov rax, 0x3fe0000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
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
    cvttsd2si rax, xmm0
    push rax
    pop rax
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov eax, 1000000
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L12_10
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
    xor eax, eax
    push rax
    pop rax
    mov [rbp-32], rax
.L12_10:
    mov rax, [rbp-16]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    add rsp, 8
    mov rdi, [rbp-208]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_number
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr7]
    mov rdx, 1
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rdx, [rsp+8]
    mov [rbp-200], rdx
    add rsp, 16
    lea rdi, [rbp-208]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_text
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rbp-80]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
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
    lea rax, [rbp-48]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-40]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-88], rax
    mov eax, 6
    push rax
    pop rax
    mov [rbp-96], rax
.L12_12:
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-96]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L12_14
    lea rax, [rbp-80]
    push rax
    mov eax, 5
    push rax
    mov rax, [rbp-88]
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    pop rcx
    pop rax
    cmp rcx, 6
    jb .Lbok_12_0
    mov rdi, rcx
    mov rsi, 6
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_12_0:
    lea rax, [rax + rcx*8]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-32]
    push rax
    mov eax, 10
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_12_0
    call rt_div_trap
.Ldvk_12_0:
    cmp rcx, -1
    jne .Ldvo_12_0
    neg rax
    jmp .Ldvd_12_0
.Ldvo_12_0:
    cqo
    idiv rcx
.Ldvd_12_0:
    push rax
    mov eax, 10
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-32]
    push rax
    mov eax, 10
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_12_1
    call rt_div_trap
.Ldvk_12_1:
    cmp rcx, -1
    jne .Ldvo_12_1
    neg rax
    jmp .Ldvd_12_1
.Ldvo_12_1:
    cqo
    idiv rcx
.Ldvd_12_1:
    push rax
    pop rax
    mov [rbp-32], rax
.L12_13:
    mov rax, [rbp-88]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-88], rax
    jmp .L12_12
.L12_14:
    mov eax, 6
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    add rsp, 8
    mov rdi, [rbp-208]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_out_reserve
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    mov [rbp-104], rax
    mov eax, 6
    push rax
    pop rax
    mov [rbp-112], rax
.L12_15:
    mov rax, [rbp-104]
    push rax
    mov rax, [rbp-112]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L12_17
    mov eax, 48
    push rax
    lea rax, [rbp-80]
    push rax
    mov rax, [rbp-104]
    push rax
    pop rcx
    pop rax
    cmp rcx, 6
    jb .Lbok_12_1
    mov rdi, rcx
    mov rsi, 6
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_12_1:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    add rsp, 8
    mov rdi, [rbp-208]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_put_byte
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L12_16:
    mov rax, [rbp-104]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-104], rax
    jmp .L12_15
.L12_17:
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_print_flush
ok_rt_print_flush:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_out_ensure
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, QWORD PTR [rip+ok_rt_out_len]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L13_0
    mov eax, 1
    push rax
    mov rax, [rsp+0]
    mov [rbp-112], rax
    add rsp, 8
    mov rdi, [rbp-112]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_out_reserve
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 10
    push rax
    mov rax, [rsp+0]
    mov [rbp-112], rax
    add rsp, 8
    mov rdi, [rbp-112]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_put_byte
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, QWORD PTR [rip+ok_rt_out_buf]
    push rax
    mov rax, QWORD PTR [rip+ok_rt_out_len]
    push rax
    pop rdx
    pop rax
    push rdx
    push rax
    pop rax
    pop rdx
    mov [rbp-16], rax
    mov [rbp-8], rdx
    mov eax, 1
    push rax
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    pop rax
    pop rdx
    mov r9, rax
    mov r10, rdx
    pop rax
    mov rdi, rax
    mov rsi, r9
    mov rdx, r10
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_write
    mov rsp, rbx
    pop rbx
    push rax
    xor eax, eax
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_out_len], rax
.L13_0:
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_arena_ensure
ok_rt_arena_ensure:
    push rbp
    mov rbp, rsp
    sub rsp, 192
    mov rax, QWORD PTR [rip+ok_rt_arena]
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
    jz .L14_0
    mov eax, 1048576
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_mmap
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_arena], rax
    mov rax, QWORD PTR [rip+ok_rt_arena]
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
    jz .L14_2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_raw_die
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L14_2:
.L14_0:
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_arena_take
ok_rt_arena_take:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_arena_ensure
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, QWORD PTR [rip+ok_rt_arena_used]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov eax, 1048576
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L15_0
    mov eax, 62
    push rax
    lea rax, [rip+.Lstr8]
    mov rdx, 44
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-112], rax
    mov rdx, [rsp+8]
    mov [rbp-104], rdx
    mov rax, [rsp+16]
    mov [rbp-96], rax
    add rsp, 24
    lea rdi, [rbp-112]
    mov rsi, [rbp-96]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_trap
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L15_0:
    mov rax, QWORD PTR [rip+ok_rt_arena]
    push rax
    mov rax, QWORD PTR [rip+ok_rt_arena_used]
    push rax
    pop rcx
    pop rax
    imul rcx, 1
    add rax, rcx
    push rax
    pop rax
    mov [rbp-16], rax
    mov rax, QWORD PTR [rip+ok_rt_arena_used]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_arena_used], rax
    mov rax, [rbp-16]
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_number_to_text
ok_rt_number_to_text:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
    mov rax, QWORD PTR [rip+ok_rt_out_len]
    push rax
    pop rax
    mov [rbp-16], rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_out_ensure
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_out_len], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-128], rax
    add rsp, 8
    mov rdi, [rbp-128]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_number
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, QWORD PTR [rip+ok_rt_out_buf]
    push rax
    mov rax, QWORD PTR [rip+ok_rt_out_len]
    push rax
    pop rdx
    pop rax
    push rdx
    push rax
    pop rax
    pop rdx
    mov [rbp-32], rax
    mov [rbp-24], rdx
    mov rax, [rbp-16]
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_out_len], rax
    mov rax, [rbp-32]
    mov rdx, [rbp-24]
    push rdx
    push rax
    pop rax
    pop rdx
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_uint_to_text
ok_rt_uint_to_text:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
    mov rax, QWORD PTR [rip+ok_rt_out_len]
    push rax
    pop rax
    mov [rbp-16], rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_out_ensure
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_out_len], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-128], rax
    add rsp, 8
    mov rdi, [rbp-128]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_uint
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, QWORD PTR [rip+ok_rt_out_buf]
    push rax
    mov rax, QWORD PTR [rip+ok_rt_out_len]
    push rax
    pop rdx
    pop rax
    push rdx
    push rax
    pop rax
    pop rdx
    mov [rbp-32], rax
    mov [rbp-24], rdx
    mov rax, [rbp-16]
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_out_len], rax
    mov rax, [rbp-32]
    mov rdx, [rbp-24]
    push rdx
    push rax
    pop rax
    pop rdx
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_decimal_to_text
ok_rt_decimal_to_text:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
    mov rax, QWORD PTR [rip+ok_rt_out_len]
    push rax
    pop rax
    mov [rbp-16], rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_out_ensure
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_out_len], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-128], rax
    add rsp, 8
    mov rdi, [rbp-128]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_decimal
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, QWORD PTR [rip+ok_rt_out_buf]
    push rax
    mov rax, QWORD PTR [rip+ok_rt_out_len]
    push rax
    pop rdx
    pop rax
    push rdx
    push rax
    pop rax
    pop rdx
    mov [rbp-32], rax
    mov [rbp-24], rdx
    mov rax, [rbp-16]
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_out_len], rax
    mov rax, [rbp-32]
    mov rdx, [rbp-24]
    push rdx
    push rax
    pop rax
    pop rdx
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_bool_to_text
ok_rt_bool_to_text:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
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
    jz .L19_0
    lea rax, [rip+.Lstr2]
    mov rdx, 4
    push rdx
    push rax
    pop rax
    pop rdx
    leave
    ret
.L19_0:
    lea rax, [rip+.Lstr3]
    mov rdx, 5
    push rdx
    push rax
    pop rax
    pop rdx
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_digit
ok_rt_digit:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
    mov rax, [rbp-8]
    push rax
    mov eax, 48
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L20_3
    mov rax, [rbp-8]
    push rax
    mov eax, 57
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    push rax
    jmp .L20_2
.L20_3:
    mov eax, 0
    push rax
.L20_2:
    pop rax
    test rax, rax
    jz .L20_0
    mov rax, [rbp-8]
    push rax
    mov eax, 48
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    pop rax
    leave
    ret
.L20_0:
    mov rax, 18446744073709551615
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_text_to_number
ok_rt_text_to_number:
    push rbp
    mov rbp, rsp
    sub rsp, 288
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov rax, [r11]
    mov rdx, [r11+8]
    mov [rbp-16], rax
    mov [rbp-8], rdx
    add rsp, 48
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    pop rax
    pop rdx
    mov rax, rdx
    push rax
    pop rax
    mov [rbp-24], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-32], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-40], rax
    mov rax, [rbp-32]
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
    jz .L21_0
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rbp-32]
    push rax
    pop r11
    pop rax
    pop rdx
    cmp r11, rdx
    jb .Lbok_21_0
    mov rdi, r11
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_21_0:
    movzx rax, BYTE PTR [rax + r11]
    push rax
    pop rax
    push rax
    pop rax
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov eax, 45
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L21_2
    mov eax, 1
    push rax
    pop rax
    mov [rbp-40], rax
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
    jmp .L21_3
.L21_2:
    mov rax, [rbp-48]
    push rax
    mov eax, 43
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L21_4
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
.L21_4:
.L21_3:
.L21_0:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L21_6
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-184], rax
    mov rdx, [rsp+8]
    mov [rbp-176], rdx
    add rsp, 16
    lea rdi, [rbp-184]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_number_trap
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L21_6:
    xor eax, eax
    push rax
    pop rax
    mov [rbp-56], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-64], rax
    mov rax, [rbp-32]
    push rax
    pop rax
    mov [rbp-72], rax
    mov rax, [rbp-24]
    push rax
    pop rax
    mov [rbp-80], rax
.L21_8:
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
    jz .L21_10
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rbp-72]
    push rax
    pop r11
    pop rax
    pop rdx
    cmp r11, rdx
    jb .Lbok_21_1
    mov rdi, r11
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_21_1:
    movzx rax, BYTE PTR [rax + r11]
    push rax
    pop rax
    push rax
    mov rax, [rsp+0]
    mov [rbp-184], rax
    add rsp, 8
    mov rdi, [rbp-184]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_digit
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-88], rax
    mov rax, [rbp-88]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L21_11
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-184], rax
    mov rdx, [rsp+8]
    mov [rbp-176], rdx
    add rsp, 16
    lea rdi, [rbp-184]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_number_trap
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L21_11:
    mov rax, [rbp-56]
    push rax
    mov eax, 10
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    mov rax, [rbp-88]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-56], rax
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
.L21_9:
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
    jmp .L21_8
.L21_10:
    mov rax, [rbp-64]
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
    jz .L21_16
    mov eax, 1
    push rax
    jmp .L21_15
.L21_16:
    mov rax, [rbp-64]
    push rax
    mov eax, 19
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    push rax
.L21_15:
    pop rax
    test rax, rax
    jz .L21_13
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-184], rax
    mov rdx, [rsp+8]
    mov [rbp-176], rdx
    add rsp, 16
    lea rdi, [rbp-184]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_number_trap
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L21_13:
    mov rax, [rbp-40]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L21_17
    xor eax, eax
    push rax
    mov rax, [rbp-56]
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    pop rax
    leave
    ret
.L21_17:
    mov rax, [rbp-56]
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_text_to_decimal
ok_rt_text_to_decimal:
    push rbp
    mov rbp, rsp
    sub rsp, 304
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov rax, [r11]
    mov rdx, [r11+8]
    mov [rbp-16], rax
    mov [rbp-8], rdx
    add rsp, 48
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    pop rax
    pop rdx
    mov rax, rdx
    push rax
    pop rax
    mov [rbp-24], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-32], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-40], rax
    mov rax, [rbp-32]
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
    jz .L22_0
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rbp-32]
    push rax
    pop r11
    pop rax
    pop rdx
    cmp r11, rdx
    jb .Lbok_22_0
    mov rdi, r11
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_22_0:
    movzx rax, BYTE PTR [rax + r11]
    push rax
    pop rax
    push rax
    pop rax
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov eax, 45
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L22_2
    mov eax, 1
    push rax
    pop rax
    mov [rbp-40], rax
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
    jmp .L22_3
.L22_2:
    mov rax, [rbp-48]
    push rax
    mov eax, 43
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L22_4
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
.L22_4:
.L22_3:
.L22_0:
    mov rax, 0x0000000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    pop rax
    mov [rbp-56], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-64], rax
.L22_6:
    mov rax, [rbp-32]
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
    jz .L22_8
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rbp-32]
    push rax
    pop r11
    pop rax
    pop rdx
    cmp r11, rdx
    jb .Lbok_22_1
    mov rdi, r11
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_22_1:
    movzx rax, BYTE PTR [rax + r11]
    push rax
    pop rax
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    add rsp, 8
    mov rdi, [rbp-208]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_digit
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L22_9
    jmp .L22_8
.L22_9:
    mov rax, [rbp-56]
    push rax
    mov rax, 0x4024000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    mulsd xmm0, xmm1
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    mov rax, [rbp-72]
    push rax
    pop rax
    cvtsi2sd xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    addsd xmm0, xmm1
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    pop rax
    mov [rbp-56], rax
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
.L22_7:
    jmp .L22_6
.L22_8:
    mov rax, [rbp-64]
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
    jz .L22_11
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rdx, [rsp+8]
    mov [rbp-200], rdx
    add rsp, 16
    lea rdi, [rbp-208]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_number_trap
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L22_11:
    mov rax, 0x0000000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    pop rax
    mov [rbp-80], rax
    mov rax, 0x3fb999999999999a
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    pop rax
    mov [rbp-88], rax
    mov rax, [rbp-32]
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
    jz .L22_16
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rbp-32]
    push rax
    pop r11
    pop rax
    pop rdx
    cmp r11, rdx
    jb .Lbok_22_2
    mov rdi, r11
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_22_2:
    movzx rax, BYTE PTR [rax + r11]
    push rax
    mov eax, 46
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    jmp .L22_15
.L22_16:
    mov eax, 0
    push rax
.L22_15:
    pop rax
    test rax, rax
    jz .L22_13
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
    xor eax, eax
    push rax
    pop rax
    mov [rbp-96], rax
.L22_17:
    mov rax, [rbp-32]
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
    jz .L22_19
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rbp-32]
    push rax
    pop r11
    pop rax
    pop rdx
    cmp r11, rdx
    jb .Lbok_22_3
    mov rdi, r11
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_22_3:
    movzx rax, BYTE PTR [rax + r11]
    push rax
    pop rax
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    add rsp, 8
    mov rdi, [rbp-208]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_digit
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-104], rax
    mov rax, [rbp-104]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L22_20
    jmp .L22_19
.L22_20:
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-104]
    push rax
    pop rax
    cvtsi2sd xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    mov rax, [rbp-88]
    push rax
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    mulsd xmm0, xmm1
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    addsd xmm0, xmm1
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    pop rax
    mov [rbp-80], rax
    mov rax, [rbp-88]
    push rax
    mov rax, 0x3fb999999999999a
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    mulsd xmm0, xmm1
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    pop rax
    mov [rbp-88], rax
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
.L22_18:
    jmp .L22_17
.L22_19:
    mov rax, [rbp-96]
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
    jz .L22_22
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rdx, [rsp+8]
    mov [rbp-200], rdx
    add rsp, 16
    lea rdi, [rbp-208]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_number_trap
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L22_22:
.L22_13:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L22_24
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rdx, [rsp+8]
    mov [rbp-200], rdx
    add rsp, 16
    lea rdi, [rbp-208]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_number_trap
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L22_24:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-80]
    push rax
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    addsd xmm0, xmm1
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    pop rax
    mov [rbp-112], rax
    mov rax, [rbp-40]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L22_26
    mov rax, 0x0000000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    mov rax, [rbp-112]
    push rax
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movsd xmm1, xmm0
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    subsd xmm0, xmm1
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    pop rax
    mov [rbp-112], rax
.L22_26:
    mov rax, [rbp-112]
    push rax
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movq rax, xmm0
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_text_number_trap
ok_rt_text_number_trap:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov rax, [r11]
    mov rdx, [r11+8]
    mov [rbp-16], rax
    mov [rbp-8], rdx
    add rsp, 48
    lea rax, [rip+.Lstr9]
    mov rdx, 45
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-112], rax
    mov rdx, [rsp+8]
    mov [rbp-104], rdx
    add rsp, 16
    lea rdi, [rbp-112]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_err
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-112], rax
    mov rdx, [rsp+8]
    mov [rbp-104], rdx
    add rsp, 16
    lea rdi, [rbp-112]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_err
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr10]
    mov rdx, 2
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-112], rax
    mov rdx, [rsp+8]
    mov [rbp-104], rdx
    add rsp, 16
    lea rdi, [rbp-112]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_err
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 76
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_exit
    mov rsp, rbx
    pop rbx
    hlt
    push rax
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_text_eq
ok_rt_text_eq:
    push rbp
    mov rbp, rsp
    sub rsp, 256
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov rax, [r11]
    mov rdx, [r11+8]
    mov [rbp-16], rax
    mov [rbp-8], rdx
    mov r11, [rsp+32]
    mov rax, [r11]
    mov rdx, [r11+8]
    mov [rbp-32], rax
    mov [rbp-24], rdx
    add rsp, 48
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    pop rax
    pop rdx
    mov rax, rdx
    push rax
    pop rax
    mov [rbp-40], rax
    mov rax, [rbp-32]
    mov rdx, [rbp-24]
    push rdx
    push rax
    pop rax
    pop rdx
    mov rax, rdx
    push rax
    pop rax
    mov [rbp-48], rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L24_0
    xor eax, eax
    push rax
    pop rax
    leave
    ret
.L24_0:
    xor eax, eax
    push rax
    pop rax
    mov [rbp-56], rax
    mov rax, [rbp-40]
    push rax
    pop rax
    mov [rbp-64], rax
.L24_2:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L24_4
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rbp-56]
    push rax
    pop r11
    pop rax
    pop rdx
    cmp r11, rdx
    jb .Lbok_24_0
    mov rdi, r11
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_24_0:
    movzx rax, BYTE PTR [rax + r11]
    push rax
    mov rax, [rbp-32]
    mov rdx, [rbp-24]
    push rdx
    push rax
    mov rax, [rbp-56]
    push rax
    pop r11
    pop rax
    pop rdx
    cmp r11, rdx
    jb .Lbok_24_1
    mov rdi, r11
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_24_1:
    movzx rax, BYTE PTR [rax + r11]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L24_5
    xor eax, eax
    push rax
    pop rax
    leave
    ret
.L24_5:
.L24_3:
    mov rax, [rbp-56]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-56], rax
    jmp .L24_2
.L24_4:
    mov eax, 1
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_concat
ok_rt_concat:
    push rbp
    mov rbp, rsp
    sub rsp, 288
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov rax, [r11]
    mov rdx, [r11+8]
    mov [rbp-16], rax
    mov [rbp-8], rdx
    mov r11, [rsp+32]
    mov rax, [r11]
    mov rdx, [r11+8]
    mov [rbp-32], rax
    mov [rbp-24], rdx
    add rsp, 48
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    pop rax
    pop rdx
    mov rax, rdx
    push rax
    pop rax
    mov [rbp-40], rax
    mov rax, [rbp-32]
    mov rdx, [rbp-24]
    push rdx
    push rax
    pop rax
    pop rdx
    mov rax, rdx
    push rax
    pop rax
    mov [rbp-48], rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rsp+0]
    mov [rbp-184], rax
    add rsp, 8
    mov rdi, [rbp-184]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_arena_take
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-56], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-64], rax
    mov rax, [rbp-40]
    push rax
    pop rax
    mov [rbp-72], rax
.L25_0:
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
    jz .L25_2
    mov rax, [rbp-56]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_25_0
    call rt_null_trap
.Lpnk_25_0:
    push rax
    mov rax, [rbp-64]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rbp-64]
    push rax
    pop r11
    pop rax
    pop rdx
    cmp r11, rdx
    jb .Lbok_25_0
    mov rdi, r11
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_25_0:
    movzx rax, BYTE PTR [rax + r11]
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
.L25_1:
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
    jmp .L25_0
.L25_2:
    xor eax, eax
    push rax
    pop rax
    mov [rbp-80], rax
    mov rax, [rbp-48]
    push rax
    pop rax
    mov [rbp-88], rax
.L25_3:
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-88]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L25_5
    mov rax, [rbp-56]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_25_1
    call rt_null_trap
.Lpnk_25_1:
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-80]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    mov rdx, [rbp-24]
    push rdx
    push rax
    mov rax, [rbp-80]
    push rax
    pop r11
    pop rax
    pop rdx
    cmp r11, rdx
    jb .Lbok_25_1
    mov rdi, r11
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_25_1:
    movzx rax, BYTE PTR [rax + r11]
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
.L25_4:
    mov rax, [rbp-80]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-80], rax
    jmp .L25_3
.L25_5:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rdx
    pop rax
    push rdx
    push rax
    pop rax
    pop rdx
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_write_err
ok_rt_write_err:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov rax, [r11]
    mov rdx, [r11+8]
    mov [rbp-16], rax
    mov [rbp-8], rdx
    add rsp, 48
    mov eax, 2
    push rax
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    pop rax
    pop rdx
    mov r9, rax
    mov r10, rdx
    pop rax
    mov rdi, rax
    mov rsi, r9
    mov rdx, r10
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_write
    mov rsp, rbx
    pop rbx
    push rax
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_trap
ok_rt_trap:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov rax, [r11]
    mov rdx, [r11+8]
    mov [rbp-16], rax
    mov [rbp-8], rdx
    mov r11, [rsp+32]
    mov [rbp-24], r11
    add rsp, 48
    lea rax, [rip+.Lstr11]
    mov rdx, 22
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-120], rax
    mov rdx, [rsp+8]
    mov [rbp-112], rdx
    add rsp, 16
    lea rdi, [rbp-120]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_err
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-120], rax
    mov rdx, [rsp+8]
    mov [rbp-112], rdx
    add rsp, 16
    lea rdi, [rbp-120]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_err
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr12]
    mov rdx, 1
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-120], rax
    mov rdx, [rsp+8]
    mov [rbp-112], rdx
    add rsp, 16
    lea rdi, [rbp-120]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_err
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-24]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_exit
    mov rsp, rbx
    pop rbx
    hlt
    push rax
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_raw_die
ok_rt_raw_die:
    push rbp
    mov rbp, rsp
    sub rsp, 192
    mov eax, 2
    push rax
    lea rax, [rip+.Lstr13]
    mov rdx, 33
    push rdx
    push rax
    pop rax
    pop rdx
    mov r9, rax
    mov r10, rdx
    pop rax
    mov rdi, rax
    mov rsi, r9
    mov rdx, r10
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_write
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 2
    push rax
    lea rax, [rip+.Lstr12]
    mov rdx, 1
    push rdx
    push rax
    pop rax
    pop rdx
    mov r9, rax
    mov r10, rdx
    pop rax
    mov rdi, rax
    mov rsi, r9
    mov rdx, r10
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_write
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 74
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_exit
    mov rsp, rbx
    pop rbx
    hlt
    push rax
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_block_hdr
ok_rt_block_hdr:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
    mov rax, [rbp-8]
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    imul rcx, 1
    sub rax, rcx
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_hdr_size
ok_rt_hdr_size:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
    xor eax, eax
    push rax
    mov rax, [rbp-8]
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    imul rcx, 1
    sub rax, rcx
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    mov rax, [rsp+8]
    mov [rbp-88], rax
    add rsp, 16
    mov rdi, [rbp-104]
    mov rsi, [rbp-88]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_rd64
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_set_hdr_size
ok_rt_set_hdr_size:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    mov r11, [rsp+32]
    mov [rbp-16], r11
    add rsp, 48
    mov rax, [rbp-16]
    push rax
    xor eax, eax
    push rax
    mov rax, [rbp-8]
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    imul rcx, 1
    sub rax, rcx
    push rax
    mov rax, [rsp+0]
    mov [rbp-112], rax
    mov rax, [rsp+8]
    mov [rbp-96], rax
    mov rax, [rsp+16]
    mov [rbp-80], rax
    add rsp, 24
    mov rdi, [rbp-112]
    mov rsi, [rbp-96]
    mov rdx, [rbp-80]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_wr64
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_next_free
ok_rt_next_free:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
    mov eax, 8
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    mov rax, [rsp+8]
    mov [rbp-88], rax
    add rsp, 16
    mov rdi, [rbp-104]
    mov rsi, [rbp-88]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_rd64
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_set_next_free
ok_rt_set_next_free:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    mov r11, [rsp+32]
    mov [rbp-16], r11
    add rsp, 48
    mov rax, [rbp-16]
    push rax
    pop rax
    push rax
    mov eax, 8
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-112], rax
    mov rax, [rsp+8]
    mov [rbp-96], rax
    mov rax, [rsp+16]
    mov [rbp-80], rax
    add rsp, 24
    mov rdi, [rbp-112]
    mov rsi, [rbp-96]
    mov rdx, [rbp-80]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_wr64
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_round16
ok_rt_round16:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
    mov rax, [rbp-8]
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_34_0
    call rt_div_trap
.Ldvk_34_0:
    cmp rcx, -1
    jne .Ldvo_34_0
    neg rax
    jmp .Ldvd_34_0
.Ldvo_34_0:
    cqo
    idiv rcx
.Ldvd_34_0:
    push rax
    pop rax
    mov [rbp-16], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    pop rax
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L34_0
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
.L34_0:
    mov rax, [rbp-16]
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_heap_grow
ok_rt_heap_grow:
    push rbp
    mov rbp, rsp
    sub rsp, 240
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
    mov rax, [rbp-8]
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov eax, 1048576
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    pop rax
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov eax, 1048576
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_35_0
    call rt_div_trap
.Ldvk_35_0:
    cmp rcx, -1
    jne .Ldvo_35_0
    neg rax
    jmp .Ldvd_35_0
.Ldvo_35_0:
    cqo
    idiv rcx
.Ldvd_35_0:
    push rax
    mov eax, 1048576
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    pop rax
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_mmap
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-24], rax
    mov rax, [rbp-24]
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
    jz .L35_0
    mov eax, 29
    push rax
    lea rax, [rip+.Lstr14]
    mov rdx, 28
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-144], rax
    mov rdx, [rsp+8]
    mov [rbp-136], rdx
    mov rax, [rsp+16]
    mov [rbp-128], rax
    add rsp, 24
    lea rdi, [rbp-144]
    mov rsi, [rbp-128]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_trap
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L35_0:
    mov rax, [rbp-16]
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    pop rax
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    imul rcx, 1
    add rax, rcx
    push rax
    pop rax
    mov [rbp-40], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
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
    call ok_rt_set_hdr_size
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-32]
    push rax
    xor eax, eax
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rsp+0]
    mov [rbp-144], rax
    mov rax, [rsp+8]
    mov [rbp-128], rax
    mov rax, [rsp+16]
    mov [rbp-112], rax
    add rsp, 24
    mov rdi, [rbp-144]
    mov rsi, [rbp-128]
    mov rdx, [rbp-112]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_wr64
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    push rax
    mov rax, [rbp-40]
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
    call ok_rt_set_next_free
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, QWORD PTR [rip+ok_rt_heap_free]
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
    jz .L35_2
    mov rax, [rbp-40]
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_heap_free], rax
    jmp .L35_3
.L35_2:
    mov rax, QWORD PTR [rip+ok_rt_heap_free]
    push rax
    pop rax
    mov [rbp-48], rax
.L35_4:
    mov rax, [rbp-48]
    push rax
    mov rax, [rsp+0]
    mov [rbp-144], rax
    add rsp, 8
    mov rdi, [rbp-144]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_next_free
    mov rsp, rbx
    pop rbx
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
    jz .L35_6
    mov rax, [rbp-48]
    push rax
    mov rax, [rsp+0]
    mov [rbp-144], rax
    add rsp, 8
    mov rdi, [rbp-144]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_next_free
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-48], rax
.L35_5:
    jmp .L35_4
.L35_6:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
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
    call ok_rt_set_next_free
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L35_3:
    mov rax, QWORD PTR [rip+ok_rt_heap_total]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_heap_total], rax
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_mem_alloc
ok_rt_mem_alloc:
    push rbp
    mov rbp, rsp
    sub rsp, 272
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
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
    jz .L36_0
    mov eax, 25
    push rax
    lea rax, [rip+.Lstr15]
    mov rdx, 24
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rdx, [rsp+8]
    mov [rbp-160], rdx
    mov rax, [rsp+16]
    mov [rbp-152], rax
    add rsp, 24
    lea rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_trap
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L36_0:
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    add rsp, 8
    mov rdi, [rbp-168]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_round16
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-16], rax
    xor eax, eax
    push rax
    pop rax
    push rax
    pop rax
    mov [rbp-24], rax
    mov rax, QWORD PTR [rip+ok_rt_heap_free]
    push rax
    pop rax
    mov [rbp-32], rax
.L36_2:
    mov rax, [rbp-32]
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
    jz .L36_4
    xor eax, eax
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_rd64
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L36_5
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    pop rax
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov eax, 32
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L36_7
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rcx
    pop rax
    imul rcx, 1
    add rax, rcx
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    imul rcx, 1
    add rax, rcx
    push rax
    pop rax
    mov [rbp-56], rax
    mov rax, [rbp-48]
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    pop rax
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_set_hdr_size
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-64]
    push rax
    xor eax, eax
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    mov rax, [rsp+16]
    mov [rbp-136], rax
    add rsp, 24
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    mov rdx, [rbp-136]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_wr64
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    add rsp, 8
    mov rdi, [rbp-168]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_next_free
    mov rsp, rbx
    pop rbx
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_set_next_free
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-24]
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
    jz .L36_9
    mov rax, [rbp-56]
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_heap_free], rax
    jmp .L36_10
.L36_9:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_set_next_free
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L36_10:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_set_hdr_size
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-32]
    push rax
    pop rax
    leave
    ret
.L36_7:
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    add rsp, 8
    mov rdi, [rbp-168]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_next_free
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-72], rax
    mov rax, [rbp-24]
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
    jz .L36_11
    mov rax, [rbp-72]
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_heap_free], rax
    jmp .L36_12
.L36_11:
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_set_next_free
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L36_12:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_set_hdr_size
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-32]
    push rax
    pop rax
    leave
    ret
.L36_5:
    mov rax, [rbp-32]
    push rax
    pop rax
    mov [rbp-24], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    add rsp, 8
    mov rdi, [rbp-168]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_next_free
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-32], rax
.L36_3:
    jmp .L36_2
.L36_4:
    mov rax, [rbp-16]
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    add rsp, 8
    mov rdi, [rbp-168]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_heap_grow
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    add rsp, 8
    mov rdi, [rbp-168]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_mem_alloc
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_mem_release
ok_rt_mem_release:
    push rbp
    mov rbp, rsp
    sub rsp, 272
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov [rbp-8], r11
    add rsp, 48
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
    jz .L37_0
    xor eax, eax
    push rax
    pop rax
    leave
    ret
.L37_0:
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    add rsp, 8
    mov rdi, [rbp-168]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_hdr_size
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
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L37_5
    mov eax, 1
    push rax
    jmp .L37_4
.L37_5:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-16]
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_37_0
    call rt_div_trap
.Ldvk_37_0:
    cmp rcx, -1
    jne .Ldvo_37_0
    neg rax
    jmp .Ldvd_37_0
.Ldvo_37_0:
    cqo
    idiv rcx
.Ldvd_37_0:
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    push rax
.L37_4:
    pop rax
    test rax, rax
    jz .L37_2
    mov eax, 47
    push rax
    lea rax, [rip+.Lstr16]
    mov rdx, 54
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rdx, [rsp+8]
    mov [rbp-160], rdx
    mov rax, [rsp+16]
    mov [rbp-152], rax
    add rsp, 24
    lea rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_trap
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L37_2:
    mov eax, 1
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_set_hdr_size
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-16]
    push rax
    xor eax, eax
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    mov rax, [rsp+16]
    mov [rbp-136], rax
    add rsp, 24
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    mov rdx, [rbp-136]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_wr64
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    push rax
    pop rax
    mov [rbp-24], rax
    mov rax, QWORD PTR [rip+ok_rt_heap_free]
    push rax
    pop rax
    mov [rbp-32], rax
.L37_6:
    mov rax, [rbp-32]
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
    jz .L37_10
    mov rax, [rbp-32]
    push rax
    pop rax
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    jmp .L37_9
.L37_10:
    mov eax, 0
    push rax
.L37_9:
    pop rax
    test rax, rax
    jz .L37_8
    mov rax, [rbp-32]
    push rax
    pop rax
    mov [rbp-24], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    add rsp, 8
    mov rdi, [rbp-168]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_next_free
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-32], rax
.L37_7:
    jmp .L37_6
.L37_8:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_set_next_free
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-24]
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
    jz .L37_11
    mov rax, [rbp-8]
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_heap_free], rax
    jmp .L37_12
.L37_11:
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_set_next_free
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L37_12:
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    add rsp, 8
    mov rdi, [rbp-168]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_next_free
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-40], rax
    mov rax, [rbp-40]
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
    jz .L37_16
    mov rax, [rbp-8]
    push rax
    pop rax
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-16]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-40]
    push rax
    pop rax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    jmp .L37_15
.L37_16:
    mov eax, 0
    push rax
.L37_15:
    pop rax
    test rax, rax
    jz .L37_13
    mov rax, [rbp-16]
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    xor eax, eax
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_rd64
    mov rsp, rbx
    pop rbx
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    xor eax, eax
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    mov rax, [rsp+16]
    mov [rbp-136], rax
    add rsp, 24
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    mov rdx, [rbp-136]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_wr64
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-40]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    add rsp, 8
    mov rdi, [rbp-168]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_next_free
    mov rsp, rbx
    pop rbx
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_set_next_free
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L37_13:
    xor eax, eax
    push rax
    pop rax
    push rax
    pop rax
    mov [rbp-56], rax
    mov rax, QWORD PTR [rip+ok_rt_heap_free]
    push rax
    pop rax
    mov [rbp-64], rax
.L37_17:
    mov rax, [rbp-64]
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
    jz .L37_21
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    push rax
    jmp .L37_20
.L37_21:
    mov eax, 0
    push rax
.L37_20:
    pop rax
    test rax, rax
    jz .L37_19
    mov rax, [rbp-64]
    push rax
    pop rax
    mov [rbp-56], rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    add rsp, 8
    mov rdi, [rbp-168]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_next_free
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-64], rax
.L37_18:
    jmp .L37_17
.L37_19:
    mov rax, [rbp-56]
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
    jz .L37_25
    mov rax, [rbp-56]
    push rax
    pop rax
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    xor eax, eax
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_rd64
    mov rsp, rbx
    pop rbx
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    jmp .L37_24
.L37_25:
    mov eax, 0
    push rax
.L37_24:
    pop rax
    test rax, rax
    jz .L37_22
    xor eax, eax
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_rd64
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 16
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    xor eax, eax
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_rd64
    mov rsp, rbx
    pop rbx
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    xor eax, eax
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    mov rax, [rsp+16]
    mov [rbp-136], rax
    add rsp, 24
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    mov rdx, [rbp-136]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_wr64
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-8]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    add rsp, 8
    mov rdi, [rbp-168]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_next_free
    mov rsp, rbx
    pop rbx
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_set_next_free
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L37_22:
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_fs_read
ok_rt_fs_read:
    push rbp
    mov rbp, rsp
    sub rsp, 256
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov rax, [r11]
    mov rdx, [r11+8]
    mov [rbp-16], rax
    mov [rbp-8], rdx
    add rsp, 48
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    xor eax, eax
    push rax
    xor eax, eax
    push rax
    pop rax
    mov r9, rax
    pop rax
    mov r10, rax
    pop rax
    pop rdx
    mov rdi, rax
    mov rsi, rdx
    mov rdx, r10
    mov rcx, r9
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_open
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L38_0
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    lea rax, [rip+.Lstr17]
    mov rdx, 18
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-152], rax
    mov rdx, [rsp+8]
    mov [rbp-144], rdx
    mov rax, [rsp+16]
    mov [rbp-136], rax
    mov rdx, [rsp+24]
    mov [rbp-128], rdx
    mov rax, [rsp+32]
    mov [rbp-120], rax
    add rsp, 40
    lea rdi, [rbp-152]
    lea rsi, [rbp-136]
    mov rdx, [rbp-120]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_fs_trap
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L38_0:
    mov rax, [rbp-24]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_size
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L38_2
    mov rax, [rbp-24]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_close
    mov rsp, rbx
    pop rbx
    push rax
    mov rax, 18446744073709551615
    push rax
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    lea rax, [rip+.Lstr18]
    mov rdx, 18
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-152], rax
    mov rdx, [rsp+8]
    mov [rbp-144], rdx
    mov rax, [rsp+16]
    mov [rbp-136], rax
    mov rdx, [rsp+24]
    mov [rbp-128], rdx
    mov rax, [rsp+32]
    mov [rbp-120], rax
    add rsp, 40
    lea rdi, [rbp-152]
    lea rsi, [rbp-136]
    mov rdx, [rbp-120]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_fs_trap
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L38_2:
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-152], rax
    add rsp, 8
    mov rdi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_arena_take
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-40], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-48], rax
.L38_4:
    mov rax, [rbp-48]
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
    jz .L38_6
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    push rax
    pop rcx
    pop rax
    imul rcx, 1
    add rax, rcx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-48]
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    pop rax
    mov r9, rax
    pop rax
    mov r10, rax
    pop rax
    mov rdi, rax
    mov rsi, r10
    mov rdx, r9
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_read
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L38_7
    mov rax, [rbp-24]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_close
    mov rsp, rbx
    pop rbx
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    lea rax, [rip+.Lstr19]
    mov rdx, 18
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-152], rax
    mov rdx, [rsp+8]
    mov [rbp-144], rdx
    mov rax, [rsp+16]
    mov [rbp-136], rax
    mov rdx, [rsp+24]
    mov [rbp-128], rdx
    mov rax, [rsp+32]
    mov [rbp-120], rax
    add rsp, 40
    lea rdi, [rbp-152]
    lea rsi, [rbp-136]
    mov rdx, [rbp-120]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_fs_trap
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L38_7:
    mov rax, [rbp-56]
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
    jz .L38_9
    jmp .L38_6
.L38_9:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-48], rax
.L38_5:
    jmp .L38_4
.L38_6:
    mov rax, [rbp-24]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_close
    mov rsp, rbx
    pop rbx
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    push rax
    pop rdx
    pop rax
    push rdx
    push rax
    pop rax
    pop rdx
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_fs_save
ok_rt_fs_save:
    push rbp
    mov rbp, rsp
    sub rsp, 272
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov rax, [r11]
    mov rdx, [r11+8]
    mov [rbp-16], rax
    mov [rbp-8], rdx
    mov r11, [rsp+32]
    mov rax, [r11]
    mov rdx, [r11+8]
    mov [rbp-32], rax
    mov [rbp-24], rdx
    add rsp, 48
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov eax, 577
    push rax
    mov eax, 420
    push rax
    pop rax
    mov r9, rax
    pop rax
    mov r10, rax
    pop rax
    pop rdx
    mov rdi, rax
    mov rsi, rdx
    mov rdx, r10
    mov rcx, r9
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_open
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L39_0
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    lea rax, [rip+.Lstr20]
    mov rdx, 20
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-176], rax
    mov rdx, [rsp+8]
    mov [rbp-168], rdx
    mov rax, [rsp+16]
    mov [rbp-160], rax
    mov rdx, [rsp+24]
    mov [rbp-152], rdx
    mov rax, [rsp+32]
    mov [rbp-144], rax
    add rsp, 40
    lea rdi, [rbp-176]
    lea rsi, [rbp-160]
    mov rdx, [rbp-144]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_fs_trap
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L39_0:
    xor eax, eax
    push rax
    pop rax
    mov [rbp-48], rax
    mov rax, [rbp-32]
    mov rdx, [rbp-24]
    push rdx
    push rax
    pop rax
    pop rdx
    mov rax, rdx
    push rax
    pop rax
    mov [rbp-56], rax
.L39_2:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L39_4
    mov rax, [rbp-32]
    mov rdx, [rbp-24]
    push rdx
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-56]
    push rax
    pop r10
    pop r11
    pop rax
    pop rdx
    cmp r11, r10
    jbe .Lsok_39_0
    mov rdi, r11
    mov rsi, r10
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lsok_39_0:
    cmp r10, rdx
    jbe .Lsok_39_1
    mov rdi, r10
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lsok_39_1:
    add rax, r11
    sub r10, r11
    mov rdx, r10
    push rdx
    push rax
    pop rax
    pop rdx
    mov [rbp-72], rax
    mov [rbp-64], rdx
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-72]
    mov rdx, [rbp-64]
    push rdx
    push rax
    pop rax
    pop rdx
    mov r9, rax
    mov r10, rdx
    pop rax
    mov rdi, rax
    mov rsi, r9
    mov rdx, r10
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_write
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-80], rax
    mov rax, [rbp-80]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L39_5
    mov rax, [rbp-40]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_close
    mov rsp, rbx
    pop rbx
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    lea rax, [rip+.Lstr21]
    mov rdx, 19
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-176], rax
    mov rdx, [rsp+8]
    mov [rbp-168], rdx
    mov rax, [rsp+16]
    mov [rbp-160], rax
    mov rdx, [rsp+24]
    mov [rbp-152], rdx
    mov rax, [rsp+32]
    mov [rbp-144], rax
    add rsp, 40
    lea rdi, [rbp-176]
    lea rsi, [rbp-160]
    mov rdx, [rbp-144]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_fs_trap
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L39_5:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-80]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-48], rax
.L39_3:
    jmp .L39_2
.L39_4:
    mov rax, [rbp-40]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_close
    mov rsp, rbx
    pop rbx
    push rax
    mov rax, [rbp-48]
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_fs_exists
ok_rt_fs_exists:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov rax, [r11]
    mov rdx, [r11+8]
    mov [rbp-16], rax
    mov [rbp-8], rdx
    add rsp, 48
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    xor eax, eax
    push rax
    xor eax, eax
    push rax
    pop rax
    mov r9, rax
    pop rax
    mov r10, rax
    pop rax
    pop rdx
    mov rdi, rax
    mov rsi, rdx
    mov rdx, r10
    mov rcx, r9
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_open
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setge al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L40_0
    mov rax, [rbp-24]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_close
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 1
    push rax
    pop rax
    leave
    ret
.L40_0:
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_rt_fs_trap
ok_rt_fs_trap:
    push rbp
    mov rbp, rsp
    sub rsp, 256
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    mov r11, [rsp+40]
    mov rax, [r11]
    mov rdx, [r11+8]
    mov [rbp-16], rax
    mov [rbp-8], rdx
    mov r11, [rsp+32]
    mov rax, [r11]
    mov rdx, [r11+8]
    mov [rbp-32], rax
    mov [rbp-24], rdx
    mov r11, [rsp+24]
    mov [rbp-40], r11
    add rsp, 48
    lea rax, [rip+.Lstr11]
    mov rdx, 22
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-160], rax
    mov rdx, [rsp+8]
    mov [rbp-152], rdx
    add rsp, 16
    lea rdi, [rbp-160]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_err
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-160], rax
    mov rdx, [rsp+8]
    mov [rbp-152], rdx
    add rsp, 16
    lea rdi, [rbp-160]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_err
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-32]
    mov rdx, [rbp-24]
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-160], rax
    mov rdx, [rsp+8]
    mov [rbp-152], rdx
    add rsp, 16
    lea rdi, [rbp-160]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_err
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr22]
    mov rdx, 2
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-160], rax
    mov rdx, [rsp+8]
    mov [rbp-152], rdx
    add rsp, 16
    lea rdi, [rbp-160]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_err
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, QWORD PTR [rip+ok_rt_out_len]
    push rax
    pop rax
    mov [rbp-48], rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_out_ensure
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_out_len], rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rsp+0]
    mov [rbp-160], rax
    add rsp, 8
    mov rdi, [rbp-160]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_number
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, QWORD PTR [rip+ok_rt_out_buf]
    push rax
    mov rax, QWORD PTR [rip+ok_rt_out_len]
    push rax
    pop rdx
    pop rax
    push rdx
    push rax
    pop rax
    pop rdx
    mov [rbp-64], rax
    mov [rbp-56], rdx
    mov rax, [rbp-48]
    push rax
    pop rax
    mov QWORD PTR [rip+ok_rt_out_len], rax
    mov rax, [rbp-64]
    mov rdx, [rbp-56]
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-160], rax
    mov rdx, [rsp+8]
    mov [rbp-152], rdx
    add rsp, 16
    lea rdi, [rbp-160]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_err
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr23]
    mov rdx, 2
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-160], rax
    mov rdx, [rsp+8]
    mov [rbp-152], rdx
    add rsp, 16
    lea rdi, [rbp-160]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_err
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 77
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_exit
    mov rsp, rbx
    pop rbx
    hlt
    push rax
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .section .rodata
.Lstr0:
    .byte 111, 117, 116, 112, 117, 116, 32, 98, 117, 102, 102, 101, 114, 32, 111, 118, 101, 114, 102, 108, 111, 119, 32, 40, 54, 53, 53, 51, 54, 32, 98, 121, 116, 101, 115, 32, 112, 101, 114, 32, 108, 105, 110, 101, 41, 32, 226, 128, 148, 32, 102, 108, 117, 115, 104, 32, 119, 105, 116, 104, 32, 96, 112, 114, 105, 110, 116, 96, 32, 109, 111, 114, 101, 32, 111, 102, 116, 101, 110
.Lstr1:
    .byte 57, 50, 50, 51, 51, 55, 50, 48, 51, 54, 56, 53, 52, 55, 55, 53, 56, 48, 56
.Lstr2:
    .byte 116, 114, 117, 101
.Lstr3:
    .byte 102, 97, 108, 115, 101
.Lstr4:
    .byte 110, 97, 110
.Lstr5:
    .byte 45
.Lstr6:
    .byte 105, 110, 102
.Lstr7:
    .byte 46
.Lstr8:
    .byte 116, 101, 120, 116, 32, 97, 114, 101, 110, 97, 32, 101, 120, 104, 97, 117, 115, 116, 101, 100, 32, 40, 49, 32, 77, 105, 66, 32, 111, 102, 32, 116, 101, 120, 116, 32, 112, 101, 114, 32, 114, 117, 110, 41
.Lstr9:
    .byte 111, 107, 117, 108, 97, 114, 32, 114, 117, 110, 116, 105, 109, 101, 32, 101, 114, 114, 111, 114, 58, 32, 116, 101, 120, 116, 32, 105, 115, 32, 110, 111, 116, 32, 97, 32, 110, 117, 109, 98, 101, 114, 58, 32, 34
.Lstr10:
    .byte 34, 10
.Lstr11:
    .byte 111, 107, 117, 108, 97, 114, 32, 114, 117, 110, 116, 105, 109, 101, 32, 101, 114, 114, 111, 114, 58, 32
.Lstr12:
    .byte 10
.Lstr13:
    .byte 111, 107, 117, 108, 97, 114, 32, 114, 117, 110, 116, 105, 109, 101, 32, 101, 114, 114, 111, 114, 58, 32, 109, 109, 97, 112, 32, 102, 97, 105, 108, 101, 100
.Lstr14:
    .byte 104, 101, 97, 112, 32, 101, 120, 104, 97, 117, 115, 116, 101, 100, 32, 40, 109, 109, 97, 112, 32, 102, 97, 105, 108, 101, 100, 41
.Lstr15:
    .byte 97, 108, 108, 111, 99, 97, 116, 105, 111, 110, 32, 111, 102, 32, 122, 101, 114, 111, 32, 98, 121, 116, 101, 115
.Lstr16:
    .byte 114, 101, 108, 101, 97, 115, 101, 32, 111, 102, 32, 97, 110, 32, 105, 110, 118, 97, 108, 105, 100, 32, 111, 114, 32, 97, 108, 114, 101, 97, 100, 121, 45, 114, 101, 108, 101, 97, 115, 101, 100, 32, 104, 101, 97, 112, 32, 112, 111, 105, 110, 116, 101, 114
.Lstr17:
    .byte 99, 97, 110, 110, 111, 116, 32, 111, 112, 101, 110, 32, 102, 105, 108, 101, 58, 32
.Lstr18:
    .byte 99, 97, 110, 110, 111, 116, 32, 115, 116, 97, 116, 32, 102, 105, 108, 101, 58, 32
.Lstr19:
    .byte 99, 97, 110, 110, 111, 116, 32, 114, 101, 97, 100, 32, 102, 105, 108, 101, 58, 32
.Lstr20:
    .byte 99, 97, 110, 110, 111, 116, 32, 99, 114, 101, 97, 116, 101, 32, 102, 105, 108, 101, 58, 32
.Lstr21:
    .byte 99, 97, 110, 110, 111, 116, 32, 119, 114, 105, 116, 101, 32, 102, 105, 108, 101, 58, 32
.Lstr22:
    .byte 32, 40
.Lstr23:
    .byte 41, 10

    .section .data
    .globl ok_rt_out_buf
    .balign 8
ok_rt_out_buf:
    .quad 0
    .globl ok_rt_out_len
    .balign 8
ok_rt_out_len:
    .quad 0
    .globl ok_rt_arena
    .balign 8
ok_rt_arena:
    .quad 0
    .globl ok_rt_arena_used
    .balign 8
ok_rt_arena_used:
    .quad 0
    .globl ok_rt_err_buf
    .balign 8
ok_rt_err_buf:
    .quad 0
    .globl ok_rt_heap_free
    .balign 8
ok_rt_heap_free:
    .quad 0
    .globl ok_rt_heap_total
    .balign 8
ok_rt_heap_total:
    .quad 0
