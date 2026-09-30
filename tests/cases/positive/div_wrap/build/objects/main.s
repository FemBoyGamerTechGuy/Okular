# Okular 0.2 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_run
ok_main_run:
    push rbp
    mov rbp, rsp
    sub rsp, 272
    mov rax, 9223372036854775808
    push rax
    pop rax
    mov [rbp-8], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 18446744073709551615
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_0_0
    call rt_div_trap
.Ldvk_0_0:
    cmp rcx, -1
    jne .Ldvo_0_0
    neg rax
    jmp .Ldvd_0_0
.Ldvo_0_0:
    cqo
    idiv rcx
.Ldvd_0_0:
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
    mov rax, [rbp-8]
    push rax
    mov rax, 18446744073709551615
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_0_1
    call rt_div_trap
.Ldvk_0_1:
    cmp rcx, -1
    jne .Ldvo_0_1
    xor eax, eax
    jmp .Ldvd_0_1
.Ldvo_0_1:
    cqo
    idiv rcx
    mov rax, rdx
.Ldvd_0_1:
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
    mov rax, 18446744073709551609
    push rax
    pop rax
    mov [rbp-16], rax
    mov eax, 2
    push rax
    pop rax
    mov [rbp-24], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_0_2
    call rt_div_trap
.Ldvk_0_2:
    cmp rcx, -1
    jne .Ldvo_0_2
    neg rax
    jmp .Ldvd_0_2
.Ldvo_0_2:
    cqo
    idiv rcx
.Ldvd_0_2:
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
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_0_3
    call rt_div_trap
.Ldvk_0_3:
    cmp rcx, -1
    jne .Ldvo_0_3
    xor eax, eax
    jmp .Ldvd_0_3
.Ldvo_0_3:
    cqo
    idiv rcx
    mov rax, rdx
.Ldvd_0_3:
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
    mov rax, 18446744073709551609
    push rax
    pop rax
    mov [rbp-32], rax
    mov eax, 2
    push rax
    pop rax
    mov [rbp-40], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_0_4
    call rt_div_trap
.Ldvk_0_4:
    cmp rcx, -1
    jne .Ldvo_0_4
    neg rax
    jmp .Ldvd_0_4
.Ldvo_0_4:
    cqo
    idiv rcx
.Ldvd_0_4:
    shl rax, 56
    sar rax, 56
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
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_0_5
    call rt_div_trap
.Ldvk_0_5:
    cmp rcx, -1
    jne .Ldvo_0_5
    xor eax, eax
    jmp .Ldvd_0_5
.Ldvo_0_5:
    cqo
    idiv rcx
    mov rax, rdx
.Ldvd_0_5:
    shl rax, 56
    sar rax, 56
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
    mov eax, 200
    push rax
    pop rax
    mov [rbp-48], rax
    mov eax, 3
    push rax
    pop rax
    mov [rbp-56], rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_0_6
    call rt_div_trap
.Ldvk_0_6:
    xor edx, edx
    div rcx
.Ldvd_0_6:
    shl rax, 56
    shr rax, 56
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
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_0_7
    call rt_div_trap
.Ldvk_0_7:
    xor edx, edx
    div rcx
    mov rax, rdx
.Ldvd_0_7:
    shl rax, 56
    shr rax, 56
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
    pop rax
    mov [rbp-64], rax
    mov rax, 18446744073709551613
    push rax
    pop rax
    mov [rbp-72], rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-72]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_0_8
    call rt_div_trap
.Ldvk_0_8:
    cmp rcx, -1
    jne .Ldvo_0_8
    neg rax
    jmp .Ldvd_0_8
.Ldvo_0_8:
    cqo
    idiv rcx
.Ldvd_0_8:
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
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-72]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_0_9
    call rt_div_trap
.Ldvk_0_9:
    cmp rcx, -1
    jne .Ldvo_0_9
    xor eax, eax
    jmp .Ldvd_0_9
.Ldvo_0_9:
    cqo
    idiv rcx
    mov rax, rdx
.Ldvd_0_9:
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
