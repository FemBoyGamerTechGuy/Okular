# Okular 0.2 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_run
ok_main_run:
    push rbp
    mov rbp, rsp
    sub rsp, 304
    mov rax, 18446744073709551611
    push rax
    pop rax
    mov [rbp-8], rax
    mov eax, 5
    push rax
    pop rax
    mov [rbp-16], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
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
    call rt_write_number
    mov rsp, rbx
    pop rbx
.L0_0:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-8]
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
    jz .L0_2
    mov eax, 1
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_number
    mov rsp, rbx
    pop rbx
    jmp .L0_3
.L0_2:
    xor eax, eax
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_number
    mov rsp, rbx
    pop rbx
.L0_3:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov eax, 200
    push rax
    pop rax
    mov [rbp-24], rax
    mov eax, 100
    push rax
    pop rax
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    seta al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_4
    mov eax, 1
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_number
    mov rsp, rbx
    pop rbx
.L0_4:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    xor eax, eax
    push rax
    pop rax
    mov [rbp-40], rax
    mov eax, 255
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
    setb al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_6
    mov eax, 1
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_number
    mov rsp, rbx
    pop rbx
.L0_6:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov rax, 18446744071709551616
    push rax
    pop rax
    mov [rbp-56], rax
    mov eax, 2000000000
    push rax
    pop rax
    mov [rbp-64], rax
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
    jz .L0_8
    mov eax, 1
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_number
    mov rsp, rbx
    pop rbx
.L0_8:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov rax, 4000000000
    push rax
    pop rax
    mov [rbp-72], rax
    mov eax, 500000000
    push rax
    pop rax
    mov [rbp-80], rax
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-80]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    seta al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_10
    mov eax, 1
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_number
    mov rsp, rbx
    pop rbx
.L0_10:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov rax, 18446744073709551615
    push rax
    pop rax
    mov [rbp-88], rax
    mov rax, [rbp-88]
    push rax
    mov rax, 18000000000000000000
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    seta al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_12
    mov eax, 1
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_number
    mov rsp, rbx
    pop rbx
.L0_12:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov rax, 18446744073709551615
    push rax
    pop rax
    mov [rbp-96], rax
    mov rax, [rbp-96]
    push rax
    mov rax, 18446744073709551615
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_14
    mov eax, 1
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_number
    mov rsp, rbx
    pop rbx
.L0_14:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-96]
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
    jz .L0_16
    mov eax, 1
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_number
    mov rsp, rbx
    pop rbx
.L0_16:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov eax, 5
    push rax
    pop rax
    mov [rbp-104], rax
    mov rax, [rbp-104]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 56
    shr rax, 56
    push rax
    pop rax
    shl rax, 48
    sar rax, 48
    push rax
    pop rax
    mov [rbp-112], rax
    mov rax, [rbp-112]
    push rax
    mov eax, 5
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    sete al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_18
    mov eax, 1
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_number
    mov rsp, rbx
    pop rbx
.L0_18:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-8]
    push rax
    mov rax, 18446744073709551611
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_20
    mov eax, 1
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_number
    mov rsp, rbx
    pop rbx
.L0_20:
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov rax, [rbp-48]
    push rax
    mov eax, 255
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setae al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_22
    mov eax, 1
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_number
    mov rsp, rbx
    pop rbx
.L0_22:
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
