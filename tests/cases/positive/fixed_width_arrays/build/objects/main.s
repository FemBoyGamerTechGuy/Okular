# Okular 0.2 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_sum
ok_main_sum:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    mov rsi, rdi
    lea rdi, [rbp-8]
    mov rcx, 5
    rep movsb
    xor eax, eax
    push rax
    pop rax
    mov [rbp-16], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-24], rax
    mov eax, 5
    push rax
    pop rax
    mov [rbp-32], rax
.L0_0:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L0_2
    mov rax, [rbp-16]
    push rax
    lea rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rcx
    pop rax
    cmp rcx, 5
    jb .Lbok_0_0
    mov rdi, rcx
    mov rsi, 5
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_0_0:
    lea rax, [rax + rcx*1]
    push rax
    pop rax
    movsx rax, BYTE PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 56
    sar rax, 56
    push rax
    pop rax
    mov [rbp-16], rax
.L0_1:
    mov rax, [rbp-24]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-24], rax
    jmp .L0_0
.L0_2:
    mov rax, [rbp-16]
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_main_run
ok_main_run:
    push rbp
    mov rbp, rsp
    sub rsp, 288
    lea rax, [rbp-8]
    push rax
    mov eax, 1
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-7]
    push rax
    mov eax, 2
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-6]
    push rax
    mov eax, 3
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-5]
    push rax
    mov eax, 4
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-8]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 4
    jb .Lbok_1_0
    mov rdi, rcx
    mov rsi, 4
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_0:
    lea rax, [rax + rcx*1]
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
    lea rax, [rbp-8]
    push rax
    mov eax, 3
    push rax
    pop rcx
    pop rax
    cmp rcx, 4
    jb .Lbok_1_1
    mov rdi, rcx
    mov rsi, 4
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_1:
    lea rax, [rax + rcx*1]
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
    lea rax, [rbp-8]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 4
    jb .Lbok_1_2
    mov rdi, rcx
    mov rsi, 4
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_2:
    lea rax, [rax + rcx*1]
    push rax
    mov rax, 18446744073709551516
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-8]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 4
    jb .Lbok_1_3
    mov rdi, rcx
    mov rsi, 4
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_3:
    lea rax, [rax + rcx*1]
    push rax
    mov eax, 100
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-8]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 4
    jb .Lbok_1_4
    mov rdi, rcx
    mov rsi, 4
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_4:
    lea rax, [rax + rcx*1]
    push rax
    pop rax
    movsx rax, BYTE PTR [rax]
    push rax
    lea rax, [rbp-8]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 4
    jb .Lbok_1_5
    mov rdi, rcx
    mov rsi, 4
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_5:
    lea rax, [rax + rcx*1]
    push rax
    pop rax
    movsx rax, BYTE PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
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
    lea rax, [rbp-16]
    push rax
    mov eax, 80
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-14]
    push rax
    mov eax, 443
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-12]
    push rax
    mov eax, 8080
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-16]
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_1_6
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_6:
    lea rax, [rax + rcx*2]
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
    lea rax, [rbp-16]
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_1_7
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_7:
    lea rax, [rax + rcx*2]
    push rax
    lea rax, [rbp-16]
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_1_8
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_8:
    lea rax, [rax + rcx*2]
    push rax
    pop rax
    movzx rax, WORD PTR [rax]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 48
    shr rax, 48
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-16]
    push rax
    mov eax, 2
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_1_9
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_9:
    lea rax, [rax + rcx*2]
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
    lea rax, [rbp-24]
    push rax
    mov eax, 1000
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-22]
    push rax
    mov eax, 2000
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-20]
    push rax
    mov rax, 18446744073709548616
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-18]
    push rax
    mov eax, 4000
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-24]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_1_10
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_10:
    lea rax, [rax + rcx*4]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_1_11
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_11:
    lea rax, [rax + rcx*2]
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
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_1_12
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_12:
    lea rax, [rax + rcx*4]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_1_13
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_13:
    lea rax, [rax + rcx*2]
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
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_1_14
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_14:
    lea rax, [rax + rcx*4]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_1_15
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_15:
    lea rax, [rax + rcx*2]
    push rax
    mov eax, 32767
    push rax
    pop rax
    pop rcx
    mov WORD PTR [rcx], ax
    lea rax, [rbp-24]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_1_16
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_16:
    lea rax, [rax + rcx*4]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_1_17
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_17:
    lea rax, [rax + rcx*2]
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
    lea rax, [rbp-32]
    push rax
    mov eax, 200
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-31]
    push rax
    mov eax, 150
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-30]
    push rax
    mov eax, 100
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-40]
    push rax
    lea rax, [rbp-32]
    push rax
    pop rsi
    pop rdi
    mov rcx, 3
    rep movsb
    lea rax, [rbp-40]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_1_18
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_18:
    lea rax, [rax + rcx*1]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-32]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_1_19
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_19:
    lea rax, [rax + rcx*1]
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
    lea rax, [rbp-40]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_1_20
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_20:
    lea rax, [rax + rcx*1]
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
    lea rax, [rip+ok_main_gdata]
    push rax
    mov rax, [rsp+0]
    mov rsi, rax
    lea rdi, [rbp-280]
    mov rcx, 5
    rep movsb
    add rsp, 8
    lea rdi, [rbp-280]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_sum
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
    lea rax, [rip+ok_main_gports]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 3
    jb .Lbok_1_21
    mov rdi, rcx
    mov rsi, 3
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_21:
    lea rax, [rax + rcx*2]
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
    lea rax, [rbp-24]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_1_22
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_22:
    lea rax, [rax + rcx*4]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_1_23
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_23:
    lea rax, [rax + rcx*2]
    push rax
    pop rax
    movsx rax, WORD PTR [rax]
    push rax
    lea rax, [rbp-24]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_1_24
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_24:
    lea rax, [rax + rcx*4]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rcx, 2
    jb .Lbok_1_25
    mov rdi, rcx
    mov rsi, 2
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_25:
    lea rax, [rax + rcx*2]
    push rax
    pop rax
    movsx rax, WORD PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 48
    sar rax, 48
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
    lea rax, [rbp-64]
    push rax
    xor eax, eax
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-63]
    push rax
    mov eax, 128
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-62]
    push rax
    mov eax, 200
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    lea rax, [rbp-61]
    push rax
    mov eax, 255
    push rax
    pop rax
    pop rcx
    mov BYTE PTR [rcx], al
    xor eax, eax
    push rax
    pop rax
    mov [rbp-72], rax
    xor eax, eax
    push rax
    pop rax
    mov [rbp-80], rax
    mov eax, 3
    push rax
    pop rax
    mov [rbp-88], rax
.L1_0:
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-88]
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setle al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L1_2
    mov rax, [rbp-72]
    push rax
    lea rax, [rbp-64]
    push rax
    mov rax, [rbp-80]
    push rax
    pop rcx
    pop rax
    cmp rcx, 4
    jb .Lbok_1_26
    mov rdi, rcx
    mov rsi, 4
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_bounds_trap
    mov rsp, rbx
    pop rbx
.Lbok_1_26:
    lea rax, [rax + rcx*1]
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 56
    shr rax, 56
    push rax
    pop rax
    mov [rbp-72], rax
.L1_1:
    mov rax, [rbp-80]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    mov [rbp-80], rax
    jmp .L1_0
.L1_2:
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
    .byte 32

    .section .data
    .globl ok_main_gdata
    .balign 8
ok_main_gdata:
    .byte 10
    .byte 236
    .byte 30
    .byte 216
    .byte 50
    .globl ok_main_gports
    .balign 8
ok_main_gports:
    .value 80
    .value 443
    .value 8080
