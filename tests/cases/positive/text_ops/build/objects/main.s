# Okular 0.1 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl __ok_entry
__ok_entry:
    push rbp
    mov rbp, rsp
    sub rsp, 96
    mov rax, [rip+ok_main_a]
    mov rdx, [rip+ok_main_a+8]
    push rdx
    push rax
    mov rax, [rip+ok_main_b]
    mov rdx, [rip+ok_main_b+8]
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
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_bool
    mov rsp, rbx
    pop rbx
    lea rax, [rip+.Lstr0]
    mov rdx, 1
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
    mov rax, [rip+ok_main_a]
    mov rdx, [rip+ok_main_a+8]
    push rdx
    push rax
    lea rax, [rip+.Lstr1]
    mov rdx, 5
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
    xor eax, 1
    movzx rax, al
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_bool
    mov rsp, rbx
    pop rbx
    lea rax, [rip+.Lstr0]
    mov rdx, 1
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
    lea rax, [rip+.Lstr2]
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
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    xor eax, eax
    leave
    ret

    .section .rodata
.Lstr0:
    .byte 32
.Lstr1:
    .byte 111, 116, 104, 101, 114
.Lstr2:
    .byte 116, 97, 98, 9, 110, 108, 10, 101, 110, 100

    .section .rodata
.Lgstr0:
    .byte 79, 107, 117, 108, 97, 114
.Lgstr1:
    .byte 79, 107, 117, 108, 97, 114

    .section .data
ok_main_a: .quad .Lgstr0, 6
ok_main_b: .quad .Lgstr1, 6
