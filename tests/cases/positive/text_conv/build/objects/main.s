# Okular 0.5 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_run
ok_main_run:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    mov eax, 42
    push rax
    lea rdi, [rbp-120]
    pop rax
    mov rsi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_number_to_text
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-120]
    mov rdx, [rbp-112]
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
    mov rax, 18446744073709551609
    push rax
    lea rdi, [rbp-120]
    pop rax
    mov rsi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_number_to_text
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-120]
    mov rdx, [rbp-112]
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
    mov rax, 18446744073709551615
    push rax
    lea rdi, [rbp-120]
    pop rax
    mov rsi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_uint_to_text
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-120]
    mov rdx, [rbp-112]
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
    mov eax, 250
    push rax
    lea rdi, [rbp-120]
    pop rax
    mov rsi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_number_to_text
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-120]
    mov rdx, [rbp-112]
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
    mov rax, 18446744071709551616
    push rax
    lea rdi, [rbp-120]
    pop rax
    mov rsi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_number_to_text
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-120]
    mov rdx, [rbp-112]
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
    mov rax, 0x400c000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    lea rdi, [rbp-120]
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movq rsi, xmm0
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_decimal_to_text
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-120]
    mov rdx, [rbp-112]
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
    mov rax, 0xbfd0000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    lea rdi, [rbp-120]
    movsd xmm0, QWORD PTR [rsp]
    add rsp, 8
    movq rsi, xmm0
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_decimal_to_text
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-120]
    mov rdx, [rbp-112]
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
    lea rdi, [rbp-120]
    pop rax
    mov rsi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bool_to_text
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-120]
    mov rdx, [rbp-112]
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
    mov eax, 0
    push rax
    lea rdi, [rbp-120]
    pop rax
    mov rsi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bool_to_text
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-120]
    mov rdx, [rbp-112]
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
    lea rax, [rip+.Lstr0]
    mov rdx, 1
    push rdx
    push rax
    lea rax, [rip+.Lstr1]
    mov rdx, 1
    push rdx
    push rax
    pop rax
    pop rdx
    mov r9, rax
    mov r10, rdx
    pop rax
    pop rdx
    lea rdi, [rbp-120]
    mov rsi, rax
    mov rcx, r9
    mov r8, r10
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_concat
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-120]
    mov rdx, [rbp-112]
    push rdx
    push rax
    mov eax, 11
    push rax
    lea rdi, [rbp-120]
    pop rax
    mov rsi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_number_to_text
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-120]
    mov rdx, [rbp-112]
    push rdx
    push rax
    pop rax
    pop rdx
    mov r9, rax
    mov r10, rdx
    pop rax
    pop rdx
    lea rdi, [rbp-120]
    mov rsi, rax
    mov rcx, r9
    mov r8, r10
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_concat
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-120]
    mov rdx, [rbp-112]
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
    lea rax, [rip+.Lstr2]
    mov rdx, 3
    push rdx
    push rax
    pop rax
    pop rdx
    mov rdi, rax
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_to_number
    mov rsp, rbx
    pop rbx
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
    lea rax, [rip+.Lstr3]
    mov rdx, 3
    push rdx
    push rax
    pop rax
    pop rdx
    mov rdi, rax
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_to_number
    mov rsp, rbx
    pop rbx
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
    mov rdx, 2
    push rdx
    push rax
    pop rax
    pop rdx
    mov rdi, rax
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_to_number
    mov rsp, rbx
    pop rbx
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
    lea rax, [rip+.Lstr5]
    mov rdx, 4
    push rdx
    push rax
    pop rax
    pop rdx
    mov rdi, rax
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_to_decimal
    mov rsp, rbx
    pop rbx
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    pop rax
    mov [rbp-8], rax
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
    lea rax, [rip+.Lstr6]
    mov rdx, 4
    push rdx
    push rax
    pop rax
    pop rdx
    mov rdi, rax
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_to_decimal
    mov rsp, rbx
    pop rbx
    movq xmm0, rax
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
    lea rax, [rip+.Lstr7]
    mov rdx, 1
    push rdx
    push rax
    pop rax
    pop rdx
    mov rdi, rax
    mov rsi, rdx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_text_to_number
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 8
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
    mov rax, [rip+ok_main_banner]
    mov rdx, [rip+ok_main_banner+8]
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
    mov rax, [rip+ok_main_label]
    mov rdx, [rip+ok_main_label+8]
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
    mov eax, 42
    push rax
    lea rdi, [rbp-120]
    pop rax
    mov rsi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_number_to_text
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-120]
    mov rdx, [rbp-112]
    push rdx
    push rax
    pop rax
    pop rdx
    mov [rbp-24], rax
    mov [rbp-32], rdx
    mov rax, [rbp-24]
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
    .byte 57
.Lstr1:
    .byte 45
.Lstr2:
    .byte 49, 50, 51
.Lstr3:
    .byte 45, 52, 53
.Lstr4:
    .byte 43, 56
.Lstr5:
    .byte 50, 46, 50, 53
.Lstr6:
    .byte 45, 48, 46, 53
.Lstr7:
    .byte 56

    .section .rodata
.Lgstr0:
    .byte 52, 50
.Lgstr1:
    .byte 110, 61, 55

    .section .data
    .globl ok_main_banner
    .balign 8
ok_main_banner:
    .quad .Lgstr0, 2
    .globl ok_main_label
    .balign 8
ok_main_label:
    .quad .Lgstr1, 3
