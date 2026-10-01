# Okular 0.6 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_check
ok_main_check:
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
    mov rax, [r11]
    mov rdx, [r11+8]
    mov [rbp-24], rax
    mov [rbp-16], rdx
    add rsp, 48
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jz .L0_0
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
    jmp .L0_1
.L0_0:
    lea rax, [rip+.Lstr1]
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
.L0_1:
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
    xor eax, eax
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
    sub rsp, 288
    mov eax, 12345
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_number_to_text
    mov rsp, rbx
    pop rbx
    push rdx
    push rax
    pop rax
    pop rdx
    mov [rbp-16], rax
    mov [rbp-8], rdx
    lea rax, [rip+.Lstr2]
    mov rdx, 14
    push rdx
    push rax
    lea rax, [rip+.Lstr3]
    mov rdx, 5
    push rdx
    push rax
    mov rax, [rbp-16]
    mov rdx, [rbp-8]
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_eq
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr4]
    mov rdx, 4
    push rdx
    push rax
    lea rax, [rip+.Lstr5]
    mov rdx, 1
    push rdx
    push rax
    xor eax, eax
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_number_to_text
    mov rsp, rbx
    pop rbx
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_eq
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr6]
    mov rdx, 8
    push rdx
    push rax
    lea rax, [rip+.Lstr7]
    mov rdx, 4
    push rdx
    push rax
    mov rax, 18446744073709550629
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_number_to_text
    mov rsp, rbx
    pop rbx
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_eq
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr8]
    mov rdx, 11
    push rdx
    push rax
    lea rax, [rip+.Lstr9]
    mov rdx, 20
    push rdx
    push rax
    mov rax, 9223372036854775809
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_number_to_text
    mov rsp, rbx
    pop rbx
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_eq
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr10]
    mov rdx, 12
    push rdx
    push rax
    lea rax, [rip+.Lstr11]
    mov rdx, 2
    push rdx
    push rax
    mov eax, 42
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_uint_to_text
    mov rsp, rbx
    pop rbx
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_eq
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr12]
    mov rdx, 15
    push rdx
    push rax
    lea rax, [rip+.Lstr13]
    mov rdx, 8
    push rdx
    push rax
    mov rax, 0x3ff8000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_decimal_to_text
    mov rsp, rbx
    pop rbx
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_eq
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr14]
    mov rdx, 12
    push rdx
    push rax
    lea rax, [rip+.Lstr15]
    mov rdx, 8
    push rdx
    push rax
    mov rax, 0x3fd0000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_decimal_to_text
    mov rsp, rbx
    pop rbx
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_eq
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr16]
    mov rdx, 11
    push rdx
    push rax
    lea rax, [rip+.Lstr17]
    mov rdx, 9
    push rdx
    push rax
    mov rax, 0xc006000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_decimal_to_text
    mov rsp, rbx
    pop rbx
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_eq
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr18]
    mov rdx, 9
    push rdx
    push rax
    lea rax, [rip+.Lstr19]
    mov rdx, 4
    push rdx
    push rax
    mov eax, 1
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_bool_to_text
    mov rsp, rbx
    pop rbx
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_eq
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr20]
    mov rdx, 10
    push rdx
    push rax
    lea rax, [rip+.Lstr21]
    mov rdx, 5
    push rdx
    push rax
    xor eax, eax
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_bool_to_text
    mov rsp, rbx
    pop rbx
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_eq
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr22]
    mov rdx, 14
    push rdx
    push rax
    lea rax, [rip+.Lstr3]
    mov rdx, 5
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    add rsp, 16
    lea rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_to_number
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 12345
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr23]
    mov rdx, 14
    push rdx
    push rax
    lea rax, [rip+.Lstr24]
    mov rdx, 3
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    add rsp, 16
    lea rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_to_number
    mov rsp, rbx
    pop rbx
    push rax
    mov rax, 18446744073709551574
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr25]
    mov rdx, 15
    push rdx
    push rax
    lea rax, [rip+.Lstr26]
    mov rdx, 3
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    add rsp, 16
    lea rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_to_decimal
    mov rsp, rbx
    pop rbx
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    mov rax, 0x3ff8000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
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
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr27]
    mov rdx, 17
    push rdx
    push rax
    lea rax, [rip+.Lstr28]
    mov rdx, 5
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    add rsp, 16
    lea rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_to_decimal
    mov rsp, rbx
    pop rbx
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    mov rax, 0xbfd0000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
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
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr29]
    mov rdx, 1
    push rdx
    push rax
    lea rax, [rip+.Lstr30]
    mov rdx, 1
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_eq
    mov rsp, rbx
    pop rbx
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
    jz .L1_0
.L1_0:
    lea rax, [rip+.Lstr31]
    mov rdx, 7
    push rdx
    push rax
    lea rax, [rip+.Lstr32]
    mov rdx, 3
    push rdx
    push rax
    lea rax, [rip+.Lstr32]
    mov rdx, 3
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_eq
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr33]
    mov rdx, 10
    push rdx
    push rax
    lea rax, [rip+.Lstr34]
    mov rdx, 3
    push rdx
    push rax
    lea rax, [rip+.Lstr32]
    mov rdx, 3
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_eq
    mov rsp, rbx
    pop rbx
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr35]
    mov rdx, 6
    push rdx
    push rax
    lea rax, [rip+.Lstr36]
    mov rdx, 6
    push rdx
    push rax
    lea rax, [rip+.Lstr37]
    mov rdx, 3
    push rdx
    push rax
    lea rax, [rip+.Lstr38]
    mov rdx, 3
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_concat
    mov rsp, rbx
    pop rbx
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_eq
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr39]
    mov rdx, 12
    push rdx
    push rax
    lea rax, [rip+.Lstr40]
    mov rdx, 1
    push rdx
    push rax
    lea rax, [rip+.Lstr40]
    mov rdx, 1
    push rdx
    push rax
    lea rax, [rip+.Lstr41]
    mov rdx, 0
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_concat
    mov rsp, rbx
    pop rbx
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_eq
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 16
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_mem_alloc
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-24], rax
    lea rax, [rip+.Lstr42]
    mov rdx, 8
    push rdx
    push rax
    mov rax, [rbp-24]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setne al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-24]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_1_0
    call rt_null_trap
.Lpnk_1_0:
    push rax
    xor eax, eax
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
    mov rax, [rbp-24]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_1_1
    call rt_null_trap
.Lpnk_1_1:
    push rax
    mov eax, 15
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
    mov eax, 32
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_mem_alloc
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_1_2
    call rt_null_trap
.Lpnk_1_2:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov eax, 3
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rip+.Lstr43]
    mov rdx, 10
    push rdx
    push rax
    mov rax, [rbp-24]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_1_3
    call rt_null_trap
.Lpnk_1_3:
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
    jz .L1_4
    mov rax, [rbp-24]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_1_4
    call rt_null_trap
.Lpnk_1_4:
    push rax
    mov eax, 15
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    jmp .L1_3
.L1_4:
    mov eax, 0
    push rax
.L1_3:
    pop rax
    test rax, rax
    jz .L1_5
    mov rax, [rbp-32]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_1_5
    call rt_null_trap
.Lpnk_1_5:
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
    mov eax, 3
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    jmp .L1_2
.L1_5:
    mov eax, 0
    push rax
.L1_2:
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-32]
    push rax
    pop rax
    push rax
    pop rax
    mov [rbp-40], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_mem_release
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 32
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_mem_alloc
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-48], rax
    lea rax, [rip+.Lstr44]
    mov rdx, 11
    push rdx
    push rax
    mov rax, [rbp-48]
    push rax
    pop rax
    push rax
    mov rax, [rbp-40]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-24]
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_mem_release
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov rax, [rbp-48]
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_mem_release
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    xor eax, eax
    push rax
    pop rax
    mov [rbp-56], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-64], rax
    mov eax, 64
    push rax
    pop rax
    mov [rbp-72], rax
.L1_6:
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
    jz .L1_8
    mov eax, 64
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_mem_alloc
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-80], rax
    mov rax, [rbp-80]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_1_6
    call rt_null_trap
.Lpnk_1_6:
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    mov rax, [rbp-64]
    push rax
    pop rax
    shl rax, 56
    shr rax, 56
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-80]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_1_7
    call rt_null_trap
.Lpnk_1_7:
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
    pop rax
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-56], rax
.L1_7:
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
    jmp .L1_6
.L1_8:
    lea rax, [rip+.Lstr45]
    mov rdx, 12
    push rdx
    push rax
    mov rax, [rbp-56]
    push rax
    mov eax, 2016
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr46]
    mov rdx, 20
    push rdx
    push rax
    lea rax, [rip+.Lstr47]
    mov rdx, 20
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_fs_save
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr47]
    mov rdx, 20
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    add rsp, 16
    lea rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_fs_read
    mov rsp, rbx
    pop rbx
    push rdx
    push rax
    pop rax
    pop rdx
    mov [rbp-96], rax
    mov [rbp-88], rdx
    lea rax, [rip+.Lstr48]
    mov rdx, 12
    push rdx
    push rax
    lea rax, [rip+.Lstr46]
    mov rdx, 20
    push rdx
    push rax
    mov rax, [rbp-96]
    mov rdx, [rbp-88]
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    mov rax, [rsp+16]
    mov [rbp-176], rax
    mov rdx, [rsp+24]
    mov [rbp-168], rdx
    add rsp, 32
    lea rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_text_eq
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr49]
    mov rdx, 9
    push rdx
    push rax
    lea rax, [rip+.Lstr47]
    mov rdx, 20
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    add rsp, 16
    lea rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_fs_exists
    mov rsp, rbx
    pop rbx
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr50]
    mov rdx, 12
    push rdx
    push rax
    lea rax, [rip+.Lstr51]
    mov rdx, 22
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    add rsp, 16
    lea rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_fs_exists
    mov rsp, rbx
    pop rbx
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rax, [rsp+8]
    mov [rbp-176], rax
    mov rdx, [rsp+16]
    mov [rbp-168], rdx
    add rsp, 24
    mov rdi, [rbp-192]
    lea rsi, [rbp-176]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_check
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    lea rax, [rip+.Lstr52]
    mov rdx, 29
    push rdx
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    mov rdx, [rsp+8]
    mov [rbp-184], rdx
    add rsp, 16
    lea rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_text
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_print_flush
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    mov eax, 42
    push rax
    mov rax, [rsp+0]
    mov [rbp-192], rax
    add rsp, 8
    mov rdi, [rbp-192]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_write_number
    mov rsp, rbx
    pop rbx
    push rax
    add rsp, 8
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_rt_print_flush
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
    .byte 111, 107, 32
.Lstr1:
    .byte 70, 65, 73, 76, 32
.Lstr2:
    .byte 110, 117, 109, 98, 101, 114, 95, 116, 111, 95, 116, 101, 120, 116
.Lstr3:
    .byte 49, 50, 51, 52, 53
.Lstr4:
    .byte 122, 101, 114, 111
.Lstr5:
    .byte 48
.Lstr6:
    .byte 110, 101, 103, 97, 116, 105, 118, 101
.Lstr7:
    .byte 45, 57, 56, 55
.Lstr8:
    .byte 105, 110, 116, 54, 52, 45, 109, 105, 110, 43, 49
.Lstr9:
    .byte 45, 57, 50, 50, 51, 51, 55, 50, 48, 51, 54, 56, 53, 52, 55, 55, 53, 56, 48, 55
.Lstr10:
    .byte 117, 105, 110, 116, 95, 116, 111, 95, 116, 101, 120, 116
.Lstr11:
    .byte 52, 50
.Lstr12:
    .byte 100, 101, 99, 105, 109, 97, 108, 95, 116, 111, 95, 116, 101, 120, 116
.Lstr13:
    .byte 49, 46, 53, 48, 48, 48, 48, 48
.Lstr14:
    .byte 100, 101, 99, 105, 109, 97, 108, 45, 102, 114, 97, 99
.Lstr15:
    .byte 48, 46, 50, 53, 48, 48, 48, 48
.Lstr16:
    .byte 100, 101, 99, 105, 109, 97, 108, 45, 110, 101, 103
.Lstr17:
    .byte 45, 50, 46, 55, 53, 48, 48, 48, 48
.Lstr18:
    .byte 98, 111, 111, 108, 45, 116, 114, 117, 101
.Lstr19:
    .byte 116, 114, 117, 101
.Lstr20:
    .byte 98, 111, 111, 108, 45, 102, 97, 108, 115, 101
.Lstr21:
    .byte 102, 97, 108, 115, 101
.Lstr22:
    .byte 116, 101, 120, 116, 95, 116, 111, 95, 110, 117, 109, 98, 101, 114
.Lstr23:
    .byte 112, 97, 114, 115, 101, 45, 110, 101, 103, 97, 116, 105, 118, 101
.Lstr24:
    .byte 45, 52, 50
.Lstr25:
    .byte 116, 101, 120, 116, 95, 116, 111, 95, 100, 101, 99, 105, 109, 97, 108
.Lstr26:
    .byte 49, 46, 53
.Lstr27:
    .byte 112, 97, 114, 115, 101, 45, 100, 101, 99, 105, 109, 97, 108, 45, 110, 101, 103
.Lstr28:
    .byte 45, 48, 46, 50, 53
.Lstr29:
    .byte 98
.Lstr30:
    .byte 97
.Lstr31:
    .byte 116, 101, 120, 116, 95, 101, 113
.Lstr32:
    .byte 97, 98, 99
.Lstr33:
    .byte 116, 101, 120, 116, 95, 101, 113, 45, 110, 101
.Lstr34:
    .byte 97, 98, 100
.Lstr35:
    .byte 99, 111, 110, 99, 97, 116
.Lstr36:
    .byte 102, 111, 111, 98, 97, 114
.Lstr37:
    .byte 98, 97, 114
.Lstr38:
    .byte 102, 111, 111
.Lstr39:
    .byte 99, 111, 110, 99, 97, 116, 45, 101, 109, 112, 116, 121
.Lstr40:
    .byte 120
.Lstr41:
    .byte 
.Lstr42:
    .byte 97, 108, 108, 111, 99, 45, 49, 54
.Lstr43:
    .byte 110, 111, 45, 111, 118, 101, 114, 108, 97, 112
.Lstr44:
    .byte 114, 101, 117, 115, 101, 45, 98, 108, 111, 99, 107
.Lstr45:
    .byte 115, 101, 113, 45, 99, 111, 110, 116, 101, 110, 116, 115
.Lstr46:
    .byte 114, 117, 110, 116, 105, 109, 101, 45, 102, 115, 45, 114, 111, 117, 110, 100, 116, 114, 105, 112
.Lstr47:
    .byte 114, 117, 110, 116, 105, 109, 101, 95, 115, 101, 108, 102, 116, 101, 115, 116, 46, 116, 109, 112
.Lstr48:
    .byte 102, 115, 45, 114, 111, 117, 110, 100, 116, 114, 105, 112
.Lstr49:
    .byte 102, 115, 45, 101, 120, 105, 115, 116, 115
.Lstr50:
    .byte 102, 115, 45, 101, 120, 105, 115, 116, 115, 45, 110, 111
.Lstr51:
    .byte 110, 111, 95, 115, 117, 99, 104, 95, 102, 105, 108, 101, 95, 104, 111, 112, 101, 102, 117, 108, 108, 121
.Lstr52:
    .byte 119, 114, 105, 116, 116, 101, 110, 32, 98, 121, 32, 116, 104, 101, 32, 79, 107, 117, 108, 97, 114, 32, 114, 117, 110, 116, 105, 109, 101
