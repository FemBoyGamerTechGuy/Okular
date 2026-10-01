# Okular 0.6 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_main
ok_main_main:
    push rbp
    mov rbp, rsp
    sub rsp, 272
    lea rax, [rip+.Lstr0]
    mov rdx, 19
    push rdx
    push rax
    pop rax
    pop rdx
    mov [rbp-16], rax
    mov [rbp-8], rdx
    lea rax, [rip+.Lstr1]
    mov rdx, 13
    push rdx
    push rax
    pop rax
    pop rdx
    mov [rbp-32], rax
    mov [rbp-24], rdx
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    pop rax
    pop rdx
    mov rax, rdx
    push rax
    mov rax, [rbp-32]
    mov rdx, [rbp-24]
    push rdx
    push rax
    pop rax
    pop rdx
    mov rax, rdx
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-40], rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_reset
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
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
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_sym_def_
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 1
    push rax
    mov eax, 7
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
    call ok_elf_mov_imm32
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 2
    push rax
    mov eax, 6
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
    call ok_elf_mov_imm32_sym
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-40]
    push rax
    mov eax, 2
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
    call ok_elf_mov_imm32
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 1
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    add rsp, 8
    mov rdi, [rbp-168]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_call_sym
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    mov eax, 7
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
    call ok_elf_mov_imm32
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 60
    push rax
    xor eax, eax
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
    call ok_elf_mov_imm32
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_syscall
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
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
    mov [rbp-168], rax
    mov rax, [rsp+8]
    mov [rbp-152], rax
    add rsp, 16
    mov rdi, [rbp-168]
    mov rsi, [rbp-152]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_sym_def_
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 1
    push rax
    xor eax, eax
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
    call ok_elf_mov_imm32
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_syscall
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_ret
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_here
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 2
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
    call ok_elf_sym_def_
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    mov [rbp-48], rax
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    pop rax
    pop rdx
    mov rax, rdx
    push rax
    pop rax
    mov [rbp-56], rax
.L0_0:
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
    jz .L0_2
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rbp-48]
    push rax
    pop r11
    pop rax
    pop rdx
    cmp r11, rdx
    jb .Lbok_0_0
    mov rdi, r11
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_0:
    movzx rax, BYTE PTR [rax + r11]
    push rax
    pop rax
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    add rsp, 8
    mov rdi, [rbp-168]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_put
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L0_1:
    mov rax, [rbp-48]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-48], rax
    jmp .L0_0
.L0_2:
    xor eax, eax
    push rax
    pop rax
    mov [rbp-64], rax
    mov rax, [rbp-32]
    mov rdx, [rbp-24]
    push rdx
    push rax
    pop rax
    pop rdx
    mov rax, rdx
    push rax
    pop rax
    mov [rbp-72], rax
.L0_3:
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
    jz .L0_5
    mov rax, [rbp-32]
    mov rdx, [rbp-24]
    push rdx
    push rax
    mov rax, [rbp-64]
    push rax
    pop r11
    pop rax
    pop rdx
    cmp r11, rdx
    jb .Lbok_0_1
    mov rdi, r11
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_1:
    movzx rax, BYTE PTR [rax + r11]
    push rax
    pop rax
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    add rsp, 8
    mov rdi, [rbp-168]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_put
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
.L0_4:
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
    jmp .L0_3
.L0_5:
    lea rax, [rip+.Lstr2]
    mov rdx, 16
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-168], rax
    mov rdx, [rsp+8]
    mov [rbp-160], rdx
    add rsp, 16
    lea rdi, [rbp-168]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_elf_emit_elf
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr3]
    mov rdx, 26
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
    mov rax, QWORD PTR [rip+ok_elf_blen]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_number
    mov rsp, rbx
    pop rbx
    lea rax, [rip+.Lstr4]
    mov rdx, 16
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
    .byte 110, 97, 116, 105, 118, 101, 32, 102, 114, 111, 109, 32, 79, 107, 117, 108, 97, 114, 10
.Lstr1:
    .byte 110, 111, 32, 97, 115, 44, 32, 110, 111, 32, 108, 100, 10
.Lstr2:
    .byte 111, 107, 117, 108, 97, 114, 45, 97, 115, 115, 101, 109, 98, 108, 101, 100
.Lstr3:
    .byte 101, 109, 105, 116, 116, 101, 100, 32, 111, 107, 117, 108, 97, 114, 45, 97, 115, 115, 101, 109, 98, 108, 101, 100, 58, 32
.Lstr4:
    .byte 32, 99, 111, 100, 101, 43, 100, 97, 116, 97, 32, 98, 121, 116, 101, 115
