# Okular 0.6 bootstrap — x86-64 Linux assembly
# module: elf
    .intel_syntax noprefix

    .text

    .globl ok_elf_reserve
ok_elf_reserve:
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
    mov rax, QWORD PTR [rip+ok_elf_buf]
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
    jz .L0_0
    mov eax, 4096
    push rax
    pop rax
    mov QWORD PTR [rip+ok_elf_bcap], rax
    mov rax, QWORD PTR [rip+ok_elf_bcap]
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
    mov QWORD PTR [rip+ok_elf_buf], rax
    mov rax, QWORD PTR [rip+ok_elf_buf]
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
    jz .L0_2
    lea rax, [rip+.Lstr0]
    mov rdx, 31
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-136], rax
    mov rdx, [rsp+8]
    mov [rbp-128], rdx
    add rsp, 16
    lea rdi, [rbp-136]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_die_
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L0_2:
    xor eax, eax
    push rax
    pop rax
    mov QWORD PTR [rip+ok_elf_blen], rax
.L0_0:
    mov rax, QWORD PTR [rip+ok_elf_blen]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, QWORD PTR [rip+ok_elf_bcap]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_4
    mov rax, QWORD PTR [rip+ok_elf_bcap]
    push rax
    pop rax
    mov [rbp-16], rax
.L0_6:
    mov rax, QWORD PTR [rip+ok_elf_blen]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-16]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setg al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_8
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
.L0_7:
    jmp .L0_6
.L0_8:
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
    jz .L0_9
    lea rax, [rip+.Lstr1]
    mov rdx, 35
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-136], rax
    mov rdx, [rsp+8]
    mov [rbp-128], rdx
    add rsp, 16
    lea rdi, [rbp-136]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_die_
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L0_9:
    xor eax, eax
    push rax
    pop rax
    mov [rbp-32], rax
    mov rax, QWORD PTR [rip+ok_elf_blen]
    push rax
    pop rax
    mov [rbp-40], rax
.L0_11:
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
    jz .L0_13
    mov rax, [rbp-24]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_0
    call rt_null_trap
.Lpnk_0_0:
    push rax
    mov rax, [rbp-32]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, QWORD PTR [rip+ok_elf_buf]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_1
    call rt_null_trap
.Lpnk_0_1:
    push rax
    mov rax, [rbp-32]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
.L0_12:
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
    jmp .L0_11
.L0_13:
    mov rax, [rbp-24]
    push rax
    pop rax
    mov QWORD PTR [rip+ok_elf_buf], rax
    mov rax, [rbp-16]
    push rax
    pop rax
    mov QWORD PTR [rip+ok_elf_bcap], rax
.L0_4:
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_elf_put
ok_elf_put:
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
    mov eax, 1
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    add rsp, 8
    mov rdi, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_reserve
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, QWORD PTR [rip+ok_elf_buf]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_1_0
    call rt_null_trap
.Lpnk_1_0:
    push rax
    mov rax, QWORD PTR [rip+ok_elf_blen]
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
    mov rax, QWORD PTR [rip+ok_elf_blen]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov QWORD PTR [rip+ok_elf_blen], rax
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_elf_put32
ok_elf_put32:
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
    mov rax, [rbp-8]
    push rax
    mov eax, 256
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_2_0
    call rt_div_trap
.Ldvk_2_0:
    cmp rcx, -1
    jne .Ldvo_2_0
    neg rax
    jmp .Ldvd_2_0
.Ldvo_2_0:
    cqo
    idiv rcx
.Ldvd_2_0:
    push rax
    mov eax, 256
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    add rsp, 8
    mov rdi, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_put
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-8]
    push rax
    mov eax, 256
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_2_1
    call rt_div_trap
.Ldvk_2_1:
    cmp rcx, -1
    jne .Ldvo_2_1
    neg rax
    jmp .Ldvd_2_1
.Ldvo_2_1:
    cqo
    idiv rcx
.Ldvd_2_1:
    push rax
    mov rax, [rbp-8]
    push rax
    mov eax, 256
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_2_2
    call rt_div_trap
.Ldvk_2_2:
    cmp rcx, -1
    jne .Ldvo_2_2
    neg rax
    jmp .Ldvd_2_2
.Ldvo_2_2:
    cqo
    idiv rcx
.Ldvd_2_2:
    push rax
    mov eax, 256
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_2_3
    call rt_div_trap
.Ldvk_2_3:
    cmp rcx, -1
    jne .Ldvo_2_3
    neg rax
    jmp .Ldvd_2_3
.Ldvo_2_3:
    cqo
    idiv rcx
.Ldvd_2_3:
    push rax
    mov eax, 256
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    add rsp, 8
    mov rdi, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_put
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-8]
    push rax
    mov eax, 65536
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_2_4
    call rt_div_trap
.Ldvk_2_4:
    cmp rcx, -1
    jne .Ldvo_2_4
    neg rax
    jmp .Ldvd_2_4
.Ldvo_2_4:
    cqo
    idiv rcx
.Ldvd_2_4:
    push rax
    mov rax, [rbp-8]
    push rax
    mov eax, 65536
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_2_5
    call rt_div_trap
.Ldvk_2_5:
    cmp rcx, -1
    jne .Ldvo_2_5
    neg rax
    jmp .Ldvd_2_5
.Ldvo_2_5:
    cqo
    idiv rcx
.Ldvd_2_5:
    push rax
    mov eax, 256
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_2_6
    call rt_div_trap
.Ldvk_2_6:
    cmp rcx, -1
    jne .Ldvo_2_6
    neg rax
    jmp .Ldvd_2_6
.Ldvo_2_6:
    cqo
    idiv rcx
.Ldvd_2_6:
    push rax
    mov eax, 256
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    add rsp, 8
    mov rdi, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_put
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-8]
    push rax
    mov eax, 16777216
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_2_7
    call rt_div_trap
.Ldvk_2_7:
    cmp rcx, -1
    jne .Ldvo_2_7
    neg rax
    jmp .Ldvd_2_7
.Ldvo_2_7:
    cqo
    idiv rcx
.Ldvd_2_7:
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    add rsp, 8
    mov rdi, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_put
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

    .globl ok_elf_put64
ok_elf_put64:
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
    xor eax, eax
    push rax
    pop rax
    mov [rbp-16], rax
    mov eax, 8
    push rax
    pop rax
    mov [rbp-24], rax
.L3_0:
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
    jz .L3_2
    mov eax, 1
    push rax
    pop rax
    mov [rbp-32], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-40], rax
    mov rax, [rbp-16]
    push rax
    pop rax
    mov [rbp-48], rax
.L3_3:
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
    jz .L3_5
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
.L3_4:
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
    jmp .L3_3
.L3_5:
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_3_0
    call rt_div_trap
.Ldvk_3_0:
    cmp rcx, -1
    jne .Ldvo_3_0
    neg rax
    jmp .Ldvd_3_0
.Ldvo_3_0:
    cqo
    idiv rcx
.Ldvd_3_0:
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_3_1
    call rt_div_trap
.Ldvk_3_1:
    cmp rcx, -1
    jne .Ldvo_3_1
    neg rax
    jmp .Ldvd_3_1
.Ldvo_3_1:
    cqo
    idiv rcx
.Ldvd_3_1:
    push rax
    mov eax, 256
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_3_2
    call rt_div_trap
.Ldvk_3_2:
    cmp rcx, -1
    jne .Ldvo_3_2
    neg rax
    jmp .Ldvd_3_2
.Ldvo_3_2:
    cqo
    idiv rcx
.Ldvd_3_2:
    push rax
    mov eax, 256
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    mov rax, [rsp+0]
    mov [rbp-144], rax
    add rsp, 8
    mov rdi, [rbp-144]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_put
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L3_1:
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
    jmp .L3_0
.L3_2:
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_elf_here
ok_elf_here:
    push rbp
    mov rbp, rsp
    sub rsp, 192
    mov rax, QWORD PTR [rip+ok_elf_blen]
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_elf_sym_def_
ok_elf_sym_def_:
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
    lea rax, [rip+ok_elf_sym_off]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rcx
    pop rax
    cmp rcx, 64
    jb .Lbok_5_0
    mov rdi, rcx
    mov rsi, 64
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_5_0:
    lea rax, [rax + rcx*8]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rip+ok_elf_sym_def]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rcx
    pop rax
    cmp rcx, 64
    jb .Lbok_5_1
    mov rdi, rcx
    mov rsi, 64
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_5_1:
    lea rax, [rax + rcx*8]
    push rax
    mov eax, 1
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_elf_fixup
ok_elf_fixup:
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
    lea rax, [rip+ok_elf_fx_off]
    push rax
    mov rax, QWORD PTR [rip+ok_elf_nfx]
    push rax
    pop rcx
    pop rax
    cmp rcx, 256
    jb .Lbok_6_0
    mov rdi, rcx
    mov rsi, 256
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_6_0:
    lea rax, [rax + rcx*8]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rip+ok_elf_fx_kind]
    push rax
    mov rax, QWORD PTR [rip+ok_elf_nfx]
    push rax
    pop rcx
    pop rax
    cmp rcx, 256
    jb .Lbok_6_1
    mov rdi, rcx
    mov rsi, 256
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_6_1:
    lea rax, [rax + rcx*8]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rip+ok_elf_fx_sym]
    push rax
    mov rax, QWORD PTR [rip+ok_elf_nfx]
    push rax
    pop rcx
    pop rax
    cmp rcx, 256
    jb .Lbok_6_2
    mov rdi, rcx
    mov rsi, 256
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_6_2:
    lea rax, [rax + rcx*8]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, QWORD PTR [rip+ok_elf_nfx]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov QWORD PTR [rip+ok_elf_nfx], rax
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_elf_mov_imm32
ok_elf_mov_imm32:
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
    mov eax, 184
    push rax
    mov rax, [rbp-8]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rsp+0]
    mov [rbp-112], rax
    add rsp, 8
    mov rdi, [rbp-112]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_put
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-16]
    push rax
    mov rax, [rsp+0]
    mov [rbp-112], rax
    add rsp, 8
    mov rdi, [rbp-112]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_put32
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

    .globl ok_elf_mov_imm32_sym
ok_elf_mov_imm32_sym:
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
    mov eax, 184
    push rax
    mov rax, [rbp-8]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rsp+0]
    mov [rbp-112], rax
    add rsp, 8
    mov rdi, [rbp-112]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_put
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-16]
    push rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_here
    mov rsp, rbx
    pop rbx
    push rax
    xor eax, eax
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
    call ok_elf_fixup
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    mov rax, [rsp+0]
    mov [rbp-112], rax
    add rsp, 8
    mov rdi, [rbp-112]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_put32
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

    .globl ok_elf_call_sym
ok_elf_call_sym:
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
    mov eax, 232
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    add rsp, 8
    mov rdi, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_put
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-8]
    push rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_here
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 1
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    mov rax, [rsp+8]
    mov [rbp-88], rax
    mov rax, [rsp+16]
    mov [rbp-72], rax
    add rsp, 24
    mov rdi, [rbp-104]
    mov rsi, [rbp-88]
    mov rdx, [rbp-72]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_fixup
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    mov rax, [rsp+0]
    mov [rbp-104], rax
    add rsp, 8
    mov rdi, [rbp-104]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_put32
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

    .globl ok_elf_syscall
ok_elf_syscall:
    push rbp
    mov rbp, rsp
    sub rsp, 192
    mov eax, 15
    push rax
    mov rax, [rsp+0]
    mov [rbp-96], rax
    add rsp, 8
    mov rdi, [rbp-96]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_put
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 5
    push rax
    mov rax, [rsp+0]
    mov [rbp-96], rax
    add rsp, 8
    mov rdi, [rbp-96]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_put
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

    .globl ok_elf_ret
ok_elf_ret:
    push rbp
    mov rbp, rsp
    sub rsp, 192
    mov eax, 195
    push rax
    mov rax, [rsp+0]
    mov [rbp-96], rax
    add rsp, 8
    mov rdi, [rbp-96]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_put
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

    .globl ok_elf_nop_pad
ok_elf_nop_pad:
    push rbp
    mov rbp, rsp
    sub rsp, 192
    mov eax, 144
    push rax
    mov rax, [rsp+0]
    mov [rbp-96], rax
    add rsp, 8
    mov rdi, [rbp-96]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_put
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

    .globl ok_elf_wr16_at
ok_elf_wr16_at:
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
    jnz .Lpnk_13_0
    call rt_null_trap
.Lpnk_13_0:
    push rax
    mov rax, [rbp-16]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-24]
    push rax
    mov eax, 256
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_13_1
    call rt_div_trap
.Ldvk_13_1:
    cmp rcx, -1
    jne .Ldvo_13_1
    neg rax
    jmp .Ldvd_13_1
.Ldvo_13_1:
    cqo
    idiv rcx
.Ldvd_13_1:
    push rax
    mov eax, 256
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
    shl rax, 56
    shr rax, 56
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_13_2
    call rt_null_trap
.Lpnk_13_2:
    push rax
    mov rax, [rbp-16]
    push rax
    mov eax, 1
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
    mov eax, 256
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_13_3
    call rt_div_trap
.Ldvk_13_3:
    cmp rcx, -1
    jne .Ldvo_13_3
    neg rax
    jmp .Ldvd_13_3
.Ldvo_13_3:
    cqo
    idiv rcx
.Ldvd_13_3:
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

    .globl ok_elf_wr32_at
ok_elf_wr32_at:
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
    mov [rbp-8], r11
    mov r11, [rsp+32]
    mov [rbp-16], r11
    mov r11, [rsp+24]
    mov [rbp-24], r11
    add rsp, 48
    xor eax, eax
    push rax
    pop rax
    mov [rbp-32], rax
    mov eax, 4
    push rax
    pop rax
    mov [rbp-40], rax
.L14_0:
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
    jz .L14_2
    mov eax, 1
    push rax
    pop rax
    mov [rbp-48], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-56], rax
    mov rax, [rbp-32]
    push rax
    pop rax
    mov [rbp-64], rax
.L14_3:
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
    jz .L14_5
    mov rax, [rbp-48]
    push rax
    mov eax, 256
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    pop rax
    mov [rbp-48], rax
.L14_4:
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
    jmp .L14_3
.L14_5:
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_14_0
    call rt_null_trap
.Lpnk_14_0:
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
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
    mov rax, [rbp-48]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_14_1
    call rt_div_trap
.Ldvk_14_1:
    cmp rcx, -1
    jne .Ldvo_14_1
    neg rax
    jmp .Ldvd_14_1
.Ldvo_14_1:
    cqo
    idiv rcx
.Ldvd_14_1:
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-48]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_14_2
    call rt_div_trap
.Ldvk_14_2:
    cmp rcx, -1
    jne .Ldvo_14_2
    neg rax
    jmp .Ldvd_14_2
.Ldvo_14_2:
    cqo
    idiv rcx
.Ldvd_14_2:
    push rax
    mov eax, 256
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_14_3
    call rt_div_trap
.Ldvk_14_3:
    cmp rcx, -1
    jne .Ldvo_14_3
    neg rax
    jmp .Ldvd_14_3
.Ldvo_14_3:
    cqo
    idiv rcx
.Ldvd_14_3:
    push rax
    mov eax, 256
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
    shl rax, 56
    shr rax, 56
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
.L14_1:
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
    jmp .L14_0
.L14_2:
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_elf_wr64_at
ok_elf_wr64_at:
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
    mov [rbp-8], r11
    mov r11, [rsp+32]
    mov [rbp-16], r11
    mov r11, [rsp+24]
    mov [rbp-24], r11
    add rsp, 48
    xor eax, eax
    push rax
    pop rax
    mov [rbp-32], rax
    mov eax, 8
    push rax
    pop rax
    mov [rbp-40], rax
.L15_0:
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
    jz .L15_2
    mov eax, 1
    push rax
    pop rax
    mov [rbp-48], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-56], rax
    mov rax, [rbp-32]
    push rax
    pop rax
    mov [rbp-64], rax
.L15_3:
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
    jz .L15_5
    mov rax, [rbp-48]
    push rax
    mov eax, 256
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    push rax
    pop rax
    mov [rbp-48], rax
.L15_4:
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
    jmp .L15_3
.L15_5:
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_15_0
    call rt_null_trap
.Lpnk_15_0:
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
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
    mov rax, [rbp-48]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_15_1
    call rt_div_trap
.Ldvk_15_1:
    cmp rcx, -1
    jne .Ldvo_15_1
    neg rax
    jmp .Ldvd_15_1
.Ldvo_15_1:
    cqo
    idiv rcx
.Ldvd_15_1:
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-48]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_15_2
    call rt_div_trap
.Ldvk_15_2:
    cmp rcx, -1
    jne .Ldvo_15_2
    neg rax
    jmp .Ldvd_15_2
.Ldvo_15_2:
    cqo
    idiv rcx
.Ldvd_15_2:
    push rax
    mov eax, 256
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_15_3
    call rt_div_trap
.Ldvk_15_3:
    cmp rcx, -1
    jne .Ldvo_15_3
    neg rax
    jmp .Ldvd_15_3
.Ldvo_15_3:
    cqo
    idiv rcx
.Ldvd_15_3:
    push rax
    mov eax, 256
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
    shl rax, 56
    shr rax, 56
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
.L15_1:
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
    jmp .L15_0
.L15_2:
    xor eax, eax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_elf_emit_elf
ok_elf_emit_elf:
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
    mov eax, 120
    push rax
    mov rax, QWORD PTR [rip+ok_elf_blen]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov eax, 64
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
    call rt_sys_mmap
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
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L16_0
    lea rax, [rip+.Lstr2]
    mov rdx, 32
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
    call ok_elf_die_
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L16_0:
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_16_0
    call rt_null_trap
.Lpnk_16_0:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov eax, 127
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_16_1
    call rt_null_trap
.Lpnk_16_1:
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov eax, 69
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_16_2
    call rt_null_trap
.Lpnk_16_2:
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov eax, 76
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_16_3
    call rt_null_trap
.Lpnk_16_3:
    push rax
    mov eax, 3
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov eax, 70
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_16_4
    call rt_null_trap
.Lpnk_16_4:
    push rax
    mov eax, 4
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov eax, 2
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_16_5
    call rt_null_trap
.Lpnk_16_5:
    push rax
    mov eax, 5
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
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_16_6
    call rt_null_trap
.Lpnk_16_6:
    push rax
    mov eax, 6
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
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_16_7
    call rt_null_trap
.Lpnk_16_7:
    push rax
    mov eax, 7
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov eax, 8
    push rax
    pop rax
    mov [rbp-40], rax
    mov eax, 16
    push rax
    pop rax
    mov [rbp-48], rax
.L16_2:
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
    jz .L16_4
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_16_8
    call rt_null_trap
.Lpnk_16_8:
    push rax
    mov rax, [rbp-40]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
.L16_3:
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
    jmp .L16_2
.L16_4:
    mov eax, 2
    push rax
    mov eax, 16
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr16_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 62
    push rax
    mov eax, 18
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr16_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 1
    push rax
    mov eax, 20
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr32_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 4194424
    push rax
    mov eax, 24
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr64_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 64
    push rax
    mov eax, 32
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr64_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    mov eax, 40
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr64_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    mov eax, 48
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr32_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 64
    push rax
    mov eax, 52
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr16_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 56
    push rax
    mov eax, 54
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr16_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 1
    push rax
    mov eax, 56
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr16_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    mov eax, 58
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr16_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    mov eax, 60
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr16_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    mov eax, 62
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr16_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 1
    push rax
    mov eax, 64
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr32_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 5
    push rax
    mov eax, 68
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr32_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    mov eax, 72
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr64_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 4194304
    push rax
    mov eax, 80
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr64_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 4194304
    push rax
    mov eax, 88
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr64_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-24]
    push rax
    mov eax, 96
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr64_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-24]
    push rax
    mov eax, 104
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr64_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 4096
    push rax
    mov eax, 112
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr64_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    mov [rbp-56], rax
    mov rax, QWORD PTR [rip+ok_elf_blen]
    push rax
    pop rax
    mov [rbp-64], rax
.L16_5:
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
    jz .L16_7
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_16_9
    call rt_null_trap
.Lpnk_16_9:
    push rax
    mov eax, 120
    push rax
    mov rax, [rbp-56]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, QWORD PTR [rip+ok_elf_buf]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_16_10
    call rt_null_trap
.Lpnk_16_10:
    push rax
    mov rax, [rbp-56]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
.L16_6:
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
    jmp .L16_5
.L16_7:
    xor eax, eax
    push rax
    pop rax
    mov [rbp-72], rax
    mov rax, QWORD PTR [rip+ok_elf_nfx]
    push rax
    pop rax
    mov [rbp-80], rax
.L16_8:
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
    jz .L16_10
    mov eax, 120
    push rax
    lea rax, [rip+ok_elf_fx_off]
    push rax
    mov rax, [rbp-72]
    push rax
    pop rcx
    pop rax
    cmp rcx, 256
    jb .Lbok_16_0
    mov rdi, rcx
    mov rsi, 256
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_16_0:
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
    lea rax, [rip+ok_elf_fx_kind]
    push rax
    mov rax, [rbp-72]
    push rax
    pop rcx
    pop rax
    cmp rcx, 256
    jb .Lbok_16_1
    mov rdi, rcx
    mov rsi, 256
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_16_1:
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
    pop rax
    test rax, rax
    jz .L16_11
    mov eax, 4194424
    push rax
    lea rax, [rip+ok_elf_sym_off]
    push rax
    lea rax, [rip+ok_elf_fx_sym]
    push rax
    mov rax, [rbp-72]
    push rax
    pop rcx
    pop rax
    cmp rcx, 256
    jb .Lbok_16_2
    mov rdi, rcx
    mov rsi, 256
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_16_2:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    pop rcx
    pop rax
    cmp rcx, 64
    jb .Lbok_16_3
    mov rdi, rcx
    mov rsi, 64
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_16_3:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr32_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    jmp .L16_12
.L16_11:
    lea rax, [rip+ok_elf_sym_off]
    push rax
    lea rax, [rip+ok_elf_fx_sym]
    push rax
    mov rax, [rbp-72]
    push rax
    pop rcx
    pop rax
    cmp rcx, 256
    jb .Lbok_16_4
    mov rdi, rcx
    mov rsi, 256
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_16_4:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    pop rcx
    pop rax
    cmp rcx, 64
    jb .Lbok_16_5
    mov rdi, rcx
    mov rsi, 64
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_16_5:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    lea rax, [rip+ok_elf_fx_off]
    push rax
    mov rax, [rbp-72]
    push rax
    pop rcx
    pop rax
    cmp rcx, 256
    jb .Lbok_16_6
    mov rdi, rcx
    mov rsi, 256
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_16_6:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov eax, 4
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    push rax
    pop rax
    mov [rbp-96], rax
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-208], rax
    mov rax, [rsp+8]
    mov [rbp-192], rax
    mov rax, [rsp+16]
    mov [rbp-176], rax
    add rsp, 24
    mov rdi, [rbp-208]
    mov rsi, [rbp-192]
    mov rdx, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_wr32_at
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L16_12:
.L16_9:
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
    jmp .L16_8
.L16_10:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rdx
    pop rax
    push rdx
    push rax
    pop rax
    pop rdx
    mov [rbp-112], rax
    mov [rbp-104], rdx
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rbp-112]
    mov rdx, [rbp-104]
    push rdx
    push rax
    pop rax
    pop rdx
    mov r9, rax
    mov r10, rdx
    pop rax
    pop rdx
    mov rdi, rax
    mov rsi, rdx
    mov rdx, r9
    mov rcx, r10
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_fs_write
    mov rsp, rbx
    pop rbx
    push rax
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov eax, 448
    push rax
    pop rax
    mov r9, rax
    pop rax
    pop rdx
    mov rdi, rax
    mov rsi, rdx
    mov rdx, r9
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_sys_chmod
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

    .globl ok_elf_die_
ok_elf_die_:
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
    lea rax, [rip+.Lstr3]
    mov rdx, 18
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
    mov eax, 2
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
    mov eax, 70
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

    .globl ok_elf_reset
ok_elf_reset:
    push rbp
    mov rbp, rsp
    sub rsp, 192
    xor eax, eax
    push rax
    pop rax
    mov QWORD PTR [rip+ok_elf_blen], rax
    xor eax, eax
    push rax
    pop rax
    mov QWORD PTR [rip+ok_elf_nsym], rax
    xor eax, eax
    push rax
    pop rax
    mov QWORD PTR [rip+ok_elf_nfx], rax
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
    .byte 109, 109, 97, 112, 32, 102, 97, 105, 108, 101, 100, 32, 102, 111, 114, 32, 116, 104, 101, 32, 99, 111, 100, 101, 32, 98, 117, 102, 102, 101, 114
.Lstr1:
    .byte 109, 109, 97, 112, 32, 102, 97, 105, 108, 101, 100, 32, 103, 114, 111, 119, 105, 110, 103, 32, 116, 104, 101, 32, 99, 111, 100, 101, 32, 98, 117, 102, 102, 101, 114
.Lstr2:
    .byte 109, 109, 97, 112, 32, 102, 97, 105, 108, 101, 100, 32, 102, 111, 114, 32, 116, 104, 101, 32, 111, 117, 116, 112, 117, 116, 32, 105, 109, 97, 103, 101
.Lstr3:
    .byte 111, 107, 117, 108, 97, 114, 32, 97, 115, 115, 101, 109, 98, 108, 101, 114, 58, 32
.Lstr4:
    .byte 10

    .section .data
    .globl ok_elf_buf
    .balign 8
ok_elf_buf:
    .quad 0
    .globl ok_elf_blen
    .balign 8
ok_elf_blen:
    .quad 0
    .globl ok_elf_bcap
    .balign 8
ok_elf_bcap:
    .quad 0
    .globl ok_elf_sym_off
    .balign 8
ok_elf_sym_off:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .globl ok_elf_sym_def
    .balign 8
ok_elf_sym_def:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .globl ok_elf_nsym
    .balign 8
ok_elf_nsym:
    .quad 0
    .globl ok_elf_fx_off
    .balign 8
ok_elf_fx_off:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .globl ok_elf_fx_kind
    .balign 8
ok_elf_fx_kind:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .globl ok_elf_fx_sym
    .balign 8
ok_elf_fx_sym:
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .quad 0
    .globl ok_elf_nfx
    .balign 8
ok_elf_nfx:
    .quad 0
