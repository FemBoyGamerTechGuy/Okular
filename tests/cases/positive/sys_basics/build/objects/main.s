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
    lea rax, [rip+.Lstr0]
    mov rdx, 16
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
    mov [rbp-8], rax
    mov rax, [rbp-8]
    push rax
    mov eax, 16
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
    lea rax, [rip+.Lstr1]
    mov rdx, 8
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
.L0_0:
    lea rax, [rip+.Lstr2]
    mov rdx, 14
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
    mov [rbp-16], rax
    mov rax, [rbp-16]
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
    jz .L0_2
    mov rax, [rbp-16]
    push rax
    lea rax, [rip+.Lstr3]
    mov rdx, 9
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
    mov [rbp-24], rax
    mov rax, [rbp-16]
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
    mov rax, [rbp-24]
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
    lea rax, [rip+.Lstr2]
    mov rdx, 14
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
    mov [rbp-32], rax
    mov rax, [rbp-32]
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
    mov [rbp-40], rax
    mov rax, [rbp-40]
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
    mov eax, 64
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
    mov [rbp-48], rax
    mov rax, [rbp-48]
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
    jz .L0_4
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-40]
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
    lea rax, [rip+.Lstr4]
    mov rdx, 11
    push rdx
    push rax
    mov eax, 1
    push rax
    mov eax, 10
    push rax
    pop r10
    pop r11
    pop rax
    pop rdx
    cmp r11, r10
    jbe .Lsok_0_0
    mov rdi, r11
    mov rsi, r10
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lsok_0_0:
    cmp r10, rdx
    jbe .Lsok_0_1
    mov rdi, r10
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lsok_0_1:
    add rax, r11
    sub r10, r11
    mov rdx, r10
    push rdx
    push rax
    pop rax
    pop rdx
    mov [rbp-72], rax
    mov [rbp-64], rdx
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-40]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_6
    lea rax, [rip+.Lstr5]
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
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
.L0_6:
    mov eax, 1
    push rax
    pop rax
    mov [rbp-80], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-88], rax
    mov eax, 9
    push rax
    pop rax
    mov [rbp-96], rax
.L0_8:
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
    jz .L0_10
    mov rax, [rbp-48]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_0
    call rt_null_trap
.Lpnk_0_0:
    push rax
    mov rax, [rbp-88]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
    push rax
    mov rax, [rbp-72]
    mov rdx, [rbp-64]
    push rdx
    push rax
    mov rax, [rbp-88]
    push rax
    pop r11
    pop rax
    pop rdx
    cmp r11, rdx
    jb .Lbok_0_2
    mov rdi, r11
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_2:
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
    jz .L0_11
    xor eax, eax
    push rax
    pop rax
    mov [rbp-80], rax
.L0_11:
.L0_9:
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
    jmp .L0_8
.L0_10:
    mov rax, [rbp-80]
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
    jz .L0_13
    lea rax, [rip+.Lstr6]
    mov rdx, 8
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
.L0_13:
.L0_4:
    mov rax, [rbp-32]
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
.L0_2:
    mov eax, 4096
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
    mov [rbp-104], rax
    mov rax, [rbp-104]
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
    jz .L0_15
    mov rax, [rbp-104]
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
    add rax, rcx
    push rax
    mov eax, 65
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, [rbp-104]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_2
    call rt_null_trap
.Lpnk_0_2:
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov eax, 66
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, [rbp-104]
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
    add rax, rcx
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
    push rax
    mov eax, 65
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_20
    mov rax, [rbp-104]
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
    add rax, rcx
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
    push rax
    mov eax, 66
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    jmp .L0_19
.L0_20:
    mov eax, 0
    push rax
.L0_19:
    pop rax
    test rax, rax
    jz .L0_17
    lea rax, [rip+.Lstr7]
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
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
.L0_17:
.L0_15:
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
    .byte 115, 121, 115, 46, 119, 114, 105, 116, 101, 32, 119, 111, 114, 107, 115, 10
.Lstr1:
    .byte 99, 111, 117, 110, 116, 45, 111, 107
.Lstr2:
    .byte 115, 121, 115, 95, 98, 97, 115, 105, 99, 115, 46, 116, 109, 112
.Lstr3:
    .byte 114, 111, 117, 110, 100, 116, 114, 105, 112
.Lstr4:
    .byte 120, 114, 111, 117, 110, 100, 116, 114, 105, 112, 120
.Lstr5:
    .byte 114, 101, 97, 100, 45, 108, 101, 110, 45, 111, 107
.Lstr6:
    .byte 98, 121, 116, 101, 115, 45, 111, 107
.Lstr7:
    .byte 109, 109, 97, 112, 45, 111, 107
