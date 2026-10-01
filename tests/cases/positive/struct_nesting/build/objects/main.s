# Okular 0.4 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_run
ok_main_run:
    push rbp
    mov rbp, rsp
    sub rsp, 304
    lea rax, [rbp-8]
    push rax
    mov eax, 1
    push rax
    pop rax
    pop rcx
    mov DWORD PTR [rcx], eax
    lea rax, [rbp-4]
    push rax
    mov rax, 18446744073709551614
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-8]
    push rax
    pop rax
    push rax
    pop rax
    movsxd rax, DWORD PTR [rax]
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
    lea rax, [rbp-8]
    push rax
    pop rax
    add rax, 4
    push rax
    pop rax
    movsx rax, BYTE PTR [rax]
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
    lea rax, [rbp-32]
    push rax
    mov eax, 10
    push rax
    pop rax
    pop rcx
    mov DWORD PTR [rcx], eax
    lea rax, [rbp-28]
    push rax
    mov eax, 20
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-24]
    push rax
    mov eax, 30
    push rax
    pop rax
    pop rcx
    mov DWORD PTR [rcx], eax
    lea rax, [rbp-20]
    push rax
    mov eax, 40
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-16]
    push rax
    mov eax, 65000
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-32]
    push rax
    pop rax
    push rax
    pop rax
    push rax
    pop rax
    movsxd rax, DWORD PTR [rax]
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
    lea rax, [rbp-32]
    push rax
    pop rax
    add rax, 8
    push rax
    pop rax
    add rax, 4
    push rax
    pop rax
    movsx rax, BYTE PTR [rax]
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
    lea rax, [rbp-32]
    push rax
    pop rax
    add rax, 16
    push rax
    pop rax
    movzx rax, WORD PTR [rax]
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
    lea rax, [rbp-32]
    push rax
    pop rax
    add rax, 8
    push rax
    pop rax
    push rax
    mov eax, 99
    push rax
    pop rax
    pop rcx
    mov DWORD PTR [rcx], eax
    lea rax, [rbp-32]
    push rax
    pop rax
    add rax, 8
    push rax
    pop rax
    push rax
    pop rax
    movsxd rax, DWORD PTR [rax]
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
    lea rax, [rbp-88]
    push rax
    mov eax, 1
    push rax
    pop rax
    pop rcx
    mov DWORD PTR [rcx], eax
    lea rax, [rbp-84]
    push rax
    mov eax, 2
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-80]
    push rax
    mov eax, 3
    push rax
    pop rax
    pop rcx
    mov DWORD PTR [rcx], eax
    lea rax, [rbp-76]
    push rax
    mov eax, 4
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-72]
    push rax
    mov eax, 500
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-64]
    push rax
    mov eax, 7
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-56]
    push rax
    mov eax, 8
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-48]
    push rax
    mov eax, 9
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-40]
    push rax
    mov rax, 0x3fe0000000000000
    movq xmm0, rax
    sub rsp, 8
    movsd QWORD PTR [rsp], xmm0
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-88]
    push rax
    pop rax
    push rax
    pop rax
    push rax
    pop rax
    push rax
    pop rax
    movsxd rax, DWORD PTR [rax]
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
    lea rax, [rbp-88]
    push rax
    pop rax
    push rax
    pop rax
    add rax, 8
    push rax
    pop rax
    add rax, 4
    push rax
    pop rax
    movsx rax, BYTE PTR [rax]
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
    lea rax, [rbp-88]
    push rax
    pop rax
    push rax
    pop rax
    add rax, 16
    push rax
    pop rax
    movzx rax, WORD PTR [rax]
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
    lea rax, [rbp-88]
    push rax
    pop rax
    add rax, 24
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_0_0
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_0:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
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
    lea rax, [rbp-88]
    push rax
    pop rax
    add rax, 24
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_0_1
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_1:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
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
    lea rax, [rbp-88]
    push rax
    pop rax
    add rax, 48
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
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
    lea rax, [rbp-88]
    push rax
    pop rax
    add rax, 24
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_0_2
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_2:
    lea rax, [rax + rcx*8]
    push rax
    mov eax, 80
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-88]
    push rax
    pop rax
    add rax, 24
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_0_3
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_3:
    lea rax, [rax + rcx*8]
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
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
    lea rax, [rbp-88]
    push rax
    pop rax
    push rax
    pop rax
    push rax
    lea rax, [rbp-32]
    push rax
    pop rax
    push rax
    pop rsi
    pop rdi
    mov rcx, 8
    rep movsb
    lea rax, [rbp-88]
    push rax
    pop rax
    push rax
    pop rax
    push rax
    pop rax
    push rax
    pop rax
    movsxd rax, DWORD PTR [rax]
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
    lea rax, [rbp-112]
    push rax
    lea rax, [rbp-32]
    push rax
    pop rsi
    pop rdi
    mov rcx, 20
    rep movsb
    lea rax, [rbp-112]
    push rax
    pop rax
    push rax
    pop rax
    push rax
    mov eax, 777
    push rax
    pop rax
    pop rcx
    mov DWORD PTR [rcx], eax
    lea rax, [rbp-32]
    push rax
    pop rax
    push rax
    pop rax
    push rax
    pop rax
    movsxd rax, DWORD PTR [rax]
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
