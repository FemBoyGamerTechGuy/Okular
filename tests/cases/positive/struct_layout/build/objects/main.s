# Okular 0.4 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_run
ok_main_run:
    push rbp
    mov rbp, rsp
    sub rsp, 272
    lea rax, [rbp-16]
    push rax
    mov eax, 1
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-12]
    push rax
    mov eax, 2000000000
    push rax
    pop rax
    pop rcx
    mov DWORD PTR [rcx], eax
    lea rax, [rbp-8]
    push rax
    mov rax, 18446744073709551316
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-16]
    push rax
    pop rax
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
    lea rax, [rbp-16]
    push rax
    pop rax
    add rax, 4
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
    lea rax, [rbp-16]
    push rax
    pop rax
    add rax, 8
    push rax
    pop rax
    movsx rax, WORD PTR [rax]
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
    lea rax, [rbp-16]
    push rax
    pop rax
    push rax
    mov rax, 18446744073709551488
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-16]
    push rax
    pop rax
    add rax, 4
    push rax
    mov rax, 18446744073709551615
    push rax
    pop rax
    pop rcx
    mov DWORD PTR [rcx], eax
    lea rax, [rbp-16]
    push rax
    pop rax
    add rax, 8
    push rax
    mov eax, 32767
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-16]
    push rax
    pop rax
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
    lea rax, [rbp-16]
    push rax
    pop rax
    add rax, 4
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
    lea rax, [rbp-16]
    push rax
    pop rax
    add rax, 8
    push rax
    pop rax
    movsx rax, WORD PTR [rax]
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
    lea rax, [rbp-24]
    push rax
    mov eax, 17
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-23]
    push rax
    mov eax, 239
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-24]
    push rax
    pop rax
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
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
    lea rax, [rbp-24]
    push rax
    pop rax
    add rax, 1
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
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
    lea rax, [rbp-40]
    push rax
    mov rax, 18446744073709551615
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rbp-32]
    push rax
    mov eax, 9
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-40]
    push rax
    pop rax
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_uint
    mov rsp, rbx
    pop rbx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    lea rax, [rbp-40]
    push rax
    pop rax
    add rax, 8
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
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
    lea rax, [rbp-48]
    push rax
    mov eax, 1
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-47]
    push rax
    mov eax, 2
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-46]
    push rax
    mov eax, 3
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-45]
    push rax
    mov eax, 4
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-44]
    push rax
    mov eax, 5
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-43]
    push rax
    mov eax, 6
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-48]
    push rax
    mov eax, 2
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
    lea rax, [rax + rcx*2]
    push rax
    pop rax
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
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
    lea rax, [rbp-48]
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
    lea rax, [rax + rcx*2]
    push rax
    pop rax
    add rax, 1
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
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
    lea rax, [rbp-48]
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
    lea rax, [rax + rcx*2]
    push rax
    pop rax
    push rax
    mov eax, 100
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-48]
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
    lea rax, [rax + rcx*2]
    push rax
    pop rax
    add rax, 1
    push rax
    mov eax, 200
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-48]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_0_4
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_4:
    lea rax, [rax + rcx*2]
    push rax
    pop rax
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
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
    lea rax, [rbp-48]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_0_5
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_5:
    lea rax, [rax + rcx*2]
    push rax
    pop rax
    add rax, 1
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
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
    lea rax, [rbp-48]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_0_6
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_6:
    lea rax, [rax + rcx*2]
    push rax
    pop rax
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
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
    lea rax, [rbp-72]
    push rax
    mov eax, 1
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-68]
    push rax
    mov eax, 2
    push rax
    pop rax
    pop rcx
    mov DWORD PTR [rcx], eax
    lea rax, [rbp-64]
    push rax
    mov eax, 3
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-60]
    push rax
    mov eax, 4
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-56]
    push rax
    mov eax, 5
    push rax
    pop rax
    pop rcx
    mov DWORD PTR [rcx], eax
    lea rax, [rbp-52]
    push rax
    mov eax, 6
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-72]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_7
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_7:
    imul rcx, rcx, 12
    add rax, rcx
    push rax
    pop rax
    add rax, 4
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
    lea rax, [rbp-72]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_0_8
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_8:
    imul rcx, rcx, 12
    add rax, rcx
    push rax
    pop rax
    add rax, 8
    push rax
    pop rax
    movsx rax, WORD PTR [rax]
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
