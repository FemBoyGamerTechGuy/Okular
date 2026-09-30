# Okular 0.2 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_run
ok_main_run:
    push rbp
    mov rbp, rsp
    sub rsp, 240
    mov eax, 100
    push rax
    mov rax, 18446744073709551516
    push rax
    mov eax, 50
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
    call ok_math_clamp_int8
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-8], rax
    mov rax, [rbp-8]
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
    mov eax, 100
    push rax
    mov rax, 18446744073709551516
    push rax
    mov rax, 18446744073709551517
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
    call ok_math_clamp_int8
    mov rsp, rbx
    pop rbx
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
    call rt_write_number
    mov rsp, rbx
    pop rbx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov eax, 100
    push rax
    mov rax, 18446744073709551516
    push rax
    mov eax, 42
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
    call ok_math_clamp_int8
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-24], rax
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
    mov rax, 5000000000
    push rax
    mov eax, 2000000000
    push rax
    mov eax, 65000
    push rax
    mov eax, 100
    push rax
    mov rax, [rsp+0]
    mov [rbp-144], rax
    mov rax, [rsp+8]
    mov [rbp-128], rax
    mov rax, [rsp+16]
    mov [rbp-112], rax
    mov rax, [rsp+24]
    mov [rbp-96], rax
    add rsp, 32
    mov rdi, [rbp-144]
    mov rsi, [rbp-128]
    mov rdx, [rbp-112]
    mov rcx, [rbp-96]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_math_mix
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
    call rt_write_number
    mov rsp, rbx
    pop rbx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    mov eax, 20000
    push rax
    mov rax, [rsp+0]
    mov [rbp-144], rax
    add rsp, 8
    mov rdi, [rbp-144]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_math_wrap16
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
    mov rax, 18446744073709531616
    push rax
    mov rax, [rsp+0]
    mov [rbp-144], rax
    add rsp, 8
    mov rdi, [rbp-144]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_math_wrap16
    mov rsp, rbx
    pop rbx
    push rax
    pop rax
    mov [rbp-48], rax
    mov rax, [rbp-48]
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
