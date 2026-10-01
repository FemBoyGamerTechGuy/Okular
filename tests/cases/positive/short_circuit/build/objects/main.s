# Okular 0.6 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_t
ok_main_t:
    push rbp
    mov rbp, rsp
    sub rsp, 192
    mov rax, QWORD PTR [rip+ok_main_calls]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov QWORD PTR [rip+ok_main_calls], rax
    mov eax, 1
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_main_f
ok_main_f:
    push rbp
    mov rbp, rsp
    sub rsp, 192
    mov rax, QWORD PTR [rip+ok_main_calls]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov QWORD PTR [rip+ok_main_calls], rax
    mov eax, 0
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_main_main
ok_main_main:
    push rbp
    mov rbp, rsp
    sub rsp, 256
    xor eax, eax
    push rax
    pop rax
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
    setne al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L2_3
    mov rax, [rbp-8]
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
    mov eax, 5
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    jmp .L2_2
.L2_3:
    mov eax, 0
    push rax
.L2_2:
    pop rax
    test rax, rax
    jz .L2_0
    lea rax, [rip+.Lstr0]
    mov rdx, 3
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
    jmp .L2_1
.L2_0:
    lea rax, [rip+.Lstr1]
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
.L2_1:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    lea rax, [rbp-32]
    push rax
    mov eax, 1
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-24]
    push rax
    mov eax, 2
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-16]
    push rax
    mov eax, 3
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov eax, 10
    push rax
    pop rax
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov eax, 3
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L2_7
    lea rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
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
    mov rax, QWORD PTR [rax]
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    jmp .L2_6
.L2_7:
    mov eax, 0
    push rax
.L2_6:
    pop rax
    test rax, rax
    jz .L2_4
    lea rax, [rip+.Lstr0]
    mov rdx, 3
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
    jmp .L2_5
.L2_4:
    lea rax, [rip+.Lstr2]
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
.L2_5:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    xor eax, eax
    push rax
    pop rax
    mov QWORD PTR [rip+ok_main_calls], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-48], rax
    mov eax, 1
    push rax
    pop rax
    test rax, rax
    jz .L2_11
    mov eax, 1
    push rax
    jmp .L2_10
.L2_11:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_t
    mov rsp, rbx
    pop rbx
    push rax
.L2_10:
    pop rax
    test rax, rax
    jz .L2_8
    lea rax, [rip+.Lstr3]
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
.L2_8:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov rax, QWORD PTR [rip+ok_main_calls]
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
    mov QWORD PTR [rip+ok_main_calls], rax
    mov eax, 0
    push rax
    pop rax
    test rax, rax
    jz .L2_15
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_t
    mov rsp, rbx
    pop rbx
    push rax
    jmp .L2_14
.L2_15:
    mov eax, 0
    push rax
.L2_14:
    pop rax
    test rax, rax
    jz .L2_12
    lea rax, [rip+.Lstr0]
    mov rdx, 3
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
    jmp .L2_13
.L2_12:
    lea rax, [rip+.Lstr4]
    mov rdx, 9
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
.L2_13:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov rax, QWORD PTR [rip+ok_main_calls]
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
    mov QWORD PTR [rip+ok_main_calls], rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_t
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    test rax, rax
    jz .L2_19
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_t
    mov rsp, rbx
    pop rbx
    push rax
    jmp .L2_18
.L2_19:
    mov eax, 0
    push rax
.L2_18:
    pop rax
    test rax, rax
    jz .L2_16
    lea rax, [rip+.Lstr5]
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
.L2_16:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov rax, QWORD PTR [rip+ok_main_calls]
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
    mov QWORD PTR [rip+ok_main_calls], rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_f
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    test rax, rax
    jz .L2_23
    mov eax, 1
    push rax
    jmp .L2_22
.L2_23:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_t
    mov rsp, rbx
    pop rbx
    push rax
.L2_22:
    pop rax
    test rax, rax
    jz .L2_20
    lea rax, [rip+.Lstr6]
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
.L2_20:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov rax, QWORD PTR [rip+ok_main_calls]
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
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_f
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    test rax, rax
    jz .L2_25
    mov eax, 1
    push rax
    jmp .L2_24
.L2_25:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_t
    mov rsp, rbx
    pop rbx
    push rax
.L2_24:
    pop rax
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    pop rax
    test rax, rax
    jz .L2_26
    lea rax, [rip+.Lstr7]
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
.L2_26:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_t
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    test rax, rax
    jz .L2_29
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_f
    mov rsp, rbx
    pop rbx
    push rax
    jmp .L2_28
.L2_29:
    mov eax, 0
    push rax
.L2_28:
    pop rax
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    pop rax
    test rax, rax
    jz .L2_30
    lea rax, [rip+.Lstr0]
    mov rdx, 3
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
    jmp .L2_31
.L2_30:
    lea rax, [rip+.Lstr8]
    mov rdx, 9
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
.L2_31:
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
    .byte 98, 97, 100
.Lstr1:
    .byte 103, 117, 97, 114, 100, 45, 110, 117, 108, 108
.Lstr2:
    .byte 103, 117, 97, 114, 100, 45, 105, 110, 100, 101, 120
.Lstr3:
    .byte 111, 114, 45, 115, 104, 111, 114, 116
.Lstr4:
    .byte 97, 110, 100, 45, 115, 104, 111, 114, 116
.Lstr5:
    .byte 97, 110, 100, 45, 98, 111, 116, 104
.Lstr6:
    .byte 111, 114, 45, 98, 111, 116, 104
.Lstr7:
    .byte 118, 97, 108, 117, 101, 45, 111, 114
.Lstr8:
    .byte 118, 97, 108, 117, 101, 45, 97, 110, 100

    .section .data
    .globl ok_main_calls
    .balign 8
ok_main_calls:
    .quad 0
