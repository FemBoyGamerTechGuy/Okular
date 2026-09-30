# Okular 0.2 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_run
ok_main_run:
    push rbp
    mov rbp, rsp
    sub rsp, 368
    mov eax, 100
    push rax
    pop rax
    mov [rbp-8], rax
    mov rax, [rbp-8]
    push rax
    pop rax
    push rax
    mov eax, 2000000000
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    pop rax
    shl rax, 32
    sar rax, 32
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
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov eax, 55
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 56
    shr rax, 56
    push rax
    pop rax
    shl rax, 48
    shr rax, 48
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
    mov eax, 65000
    push rax
    pop rax
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov eax, 5
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 48
    shr rax, 48
    push rax
    pop rax
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
    mov eax, 250
    push rax
    pop rax
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov eax, 100
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
    mov [rbp-72], rax
    mov rax, [rbp-72]
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
    mov rax, 18446744073709551611
    push rax
    pop rax
    mov [rbp-80], rax
    mov rax, 4000000000
    push rax
    pop rax
    mov [rbp-88], rax
    mov rax, [rbp-80]
    push rax
    pop rax
    push rax
    mov rax, [rbp-88]
    push rax
    pop rax
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-96], rax
    mov rax, [rbp-96]
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
    mov eax, 10
    push rax
    pop rax
    mov [rbp-104], rax
    mov eax, 3
    push rax
    pop rax
    mov [rbp-112], rax
    mov rax, [rbp-104]
    push rax
    mov rax, [rbp-112]
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
    mov rax, [rbp-104]
    push rax
    mov rax, [rbp-112]
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
    mov eax, 250
    push rax
    pop rax
    mov [rbp-120], rax
    mov eax, 10
    push rax
    pop rax
    mov [rbp-128], rax
    mov rax, [rbp-120]
    push rax
    mov rax, [rbp-128]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_0_2
    call rt_div_trap
.Ldvk_0_2:
    xor edx, edx
    div rcx
.Ldvd_0_2:
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
    mov rax, 18446744073709551609
    push rax
    pop rax
    mov [rbp-136], rax
    mov eax, 2
    push rax
    pop rax
    mov [rbp-144], rax
    mov rax, [rbp-136]
    push rax
    mov rax, [rbp-144]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_0_3
    call rt_div_trap
.Ldvk_0_3:
    cmp rcx, -1
    jne .Ldvo_0_3
    neg rax
    jmp .Ldvd_0_3
.Ldvo_0_3:
    cqo
    idiv rcx
.Ldvd_0_3:
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
    mov rax, [rbp-136]
    push rax
    mov rax, [rbp-144]
    push rax
    pop rcx
    pop rax
    test rcx, rcx
    jnz .Ldvk_0_4
    call rt_div_trap
.Ldvk_0_4:
    cmp rcx, -1
    jne .Ldvo_0_4
    xor eax, eax
    jmp .Ldvd_0_4
.Ldvo_0_4:
    cqo
    idiv rcx
    mov rax, rdx
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
    mov eax, 3
    push rax
    pop rax
    mov [rbp-152], rax
    mov rax, [rbp-152]
    push rax
    mov rax, [rbp-152]
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    shl rax, 56
    shr rax, 56
    push rax
    mov rax, [rbp-152]
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    shl rax, 56
    shr rax, 56
    push rax
    pop rax
    mov [rbp-160], rax
    mov rax, [rbp-160]
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
    mov eax, 60000
    push rax
    pop rax
    mov [rbp-168], rax
    mov rax, [rbp-168]
    push rax
    mov rax, [rbp-168]
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    shl rax, 48
    shr rax, 48
    push rax
    pop rax
    mov [rbp-176], rax
    mov rax, [rbp-176]
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
