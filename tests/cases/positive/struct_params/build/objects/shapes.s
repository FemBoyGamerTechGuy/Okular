# Okular 0.4 bootstrap — x86-64 Linux assembly
# module: shapes
    .intel_syntax noprefix

    .text

    .globl ok_shapes_area
ok_shapes_area:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_0
    call rt_null_trap
.Lpnk_0_0:
    push rax
    pop rax
    add rax, 16
    push rax
    pop rax
    movzx rax, WORD PTR [rax]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_0_1
    call rt_null_trap
.Lpnk_0_1:
    push rax
    pop rax
    add rax, 18
    push rax
    pop rax
    movzx rax, WORD PTR [rax]
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    shl rax, 48
    shr rax, 48
    push rax
    pop rax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_shapes_area_by_value
ok_shapes_area_by_value:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    mov rsi, rdi
    lea rdi, [rbp-24]
    mov rcx, 24
    rep movsb
    lea rax, [rbp-24]
    push rax
    pop rax
    add rax, 16
    push rax
    pop rax
    movzx rax, WORD PTR [rax]
    push rax
    lea rax, [rbp-24]
    push rax
    pop rax
    add rax, 18
    push rax
    pop rax
    movzx rax, WORD PTR [rax]
    push rax
    pop rcx
    pop rax
    imul rax, rcx
    shl rax, 48
    shr rax, 48
    push rax
    pop rax
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret

    .globl ok_shapes_grow
ok_shapes_grow:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_2_0
    call rt_null_trap
.Lpnk_2_0:
    push rax
    pop rax
    add rax, 16
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_2_1
    call rt_null_trap
.Lpnk_2_1:
    push rax
    pop rax
    add rax, 16
    push rax
    pop rax
    movzx rax, WORD PTR [rax]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rax
    shl rax, 48
    shr rax, 48
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
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_2_2
    call rt_null_trap
.Lpnk_2_2:
    push rax
    pop rax
    add rax, 18
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_2_3
    call rt_null_trap
.Lpnk_2_3:
    push rax
    pop rax
    add rax, 18
    push rax
    pop rax
    movzx rax, WORD PTR [rax]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rax
    shl rax, 48
    shr rax, 48
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
    xor eax, eax
    leave
    ret

    .globl ok_shapes_translate
ok_shapes_translate:
    push rbp
    mov rbp, rsp
    sub rsp, 224
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_3_0
    call rt_null_trap
.Lpnk_3_0:
    push rax
    pop rax
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_3_1
    call rt_null_trap
.Lpnk_3_1:
    push rax
    pop rax
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_3_2
    call rt_null_trap
.Lpnk_3_2:
    push rax
    pop rax
    add rax, 8
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    test rax, rax
    jnz .Lpnk_3_3
    call rt_null_trap
.Lpnk_3_3:
    push rax
    pop rax
    add rax, 8
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    xor eax, eax
    leave
    ret

    .globl ok_shapes_manhattan
ok_shapes_manhattan:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    mov rsi, rdi
    lea rdi, [rbp-16]
    mov rcx, 16
    rep movsb
    lea rax, [rbp-16]
    push rax
    pop rax
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    xor eax, eax
    push rax
    pop rcx
    pop rax
    cmp rax, rcx
    setl al
    movzx rax, al
    push rax
    pop rax
    test rax, rax
    jz .L4_0
.L4_0:
    lea rax, [rbp-16]
    push rax
    pop rax
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    lea rax, [rbp-16]
    push rax
    pop rax
    add rax, 8
    push rax
    pop rax
    mov rax, QWORD PTR [rax]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    push rax
    pop rax
    leave
    ret
    xor eax, eax
    leave
    ret
