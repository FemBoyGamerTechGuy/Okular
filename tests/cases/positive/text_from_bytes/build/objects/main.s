# Okular 0.6 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_main
ok_main_main:
    push rbp
    mov rbp, rsp
    sub rsp, 240
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
    mov [rbp-8], rax
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
    jz .L0_0
    lea rax, [rip+.Lstr0]
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
    mov eax, 1
    push rax
    pop rax
    leave
    ret
.L0_0:
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
    add rax, rcx
    push rax
    mov eax, 104
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
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
    add rax, rcx
    push rax
    mov eax, 105
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
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
    add rax, rcx
    push rax
    mov eax, 33
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, [rbp-8]
    push rax
    mov eax, 3
    push rax
    pop rdx
    pop rax
    push rdx
    push rax
    pop rax
    pop rdx
    mov [rbp-24], rax
    mov [rbp-16], rdx
    mov rax, [rbp-24]
    mov rdx, [rbp-16]
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
    mov rax, [rbp-24]
    mov rdx, [rbp-16]
    push rdx
    push rax
    pop rax
    pop rdx
    mov rax, rdx
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
    mov rdx, [rbp-16]
    push rdx
    push rax
    lea rax, [rip+.Lstr1]
    mov rdx, 3
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
    pop rax
    test rax, rax
    jz .L0_2
    lea rax, [rip+.Lstr2]
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
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
.L0_2:
    mov rax, [rbp-24]
    mov rdx, [rbp-16]
    push rdx
    push rax
    mov eax, 2
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
    mov rdx, [rbp-16]
    push rdx
    push rax
    mov eax, 1
    push rax
    mov eax, 3
    push rax
    pop r10
    pop r11
    pop rax
    pop rdx
    cmp r11, r10
    jbe .Lsok_0_1
    mov rdi, r11
    mov rsi, r10
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lsok_0_1:
    cmp r10, rdx
    jbe .Lsok_0_2
    mov rdi, r10
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_bounds_trap
    mov rsp, rbx
    pop rbx
.Lsok_0_2:
    add rax, r11
    sub r10, r11
    mov rdx, r10
    push rdx
    push rax
    pop rax
    pop rdx
    mov [rbp-40], rax
    mov [rbp-32], rdx
    mov rax, [rbp-40]
    mov rdx, [rbp-32]
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
    .byte 109, 109, 97, 112, 45, 102, 97, 105, 108, 101, 100
.Lstr1:
    .byte 104, 105, 33
.Lstr2:
    .byte 101, 113, 45, 111, 107
