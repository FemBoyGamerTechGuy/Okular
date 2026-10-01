# Okular 0.2 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_stats_doubled
ok_main_stats_doubled:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 56
    sar rax, 56
    push rax
    pop rax
    shl rax, 48
    sar rax, 48
    push rax
    pop rax
    mov [rbp-16], rax
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
    sub rsp, 192
    movsx rax, BYTE PTR [rip+ok_main_gi8]
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
    movsx rax, WORD PTR [rip+ok_main_gi16]
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
    movsxd rax, DWORD PTR [rip+ok_main_gi32]
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
    movzx rax, BYTE PTR [rip+ok_main_gu8]
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
    movzx rax, WORD PTR [rip+ok_main_gu16]
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
    mov eax, DWORD PTR [rip+ok_main_gu32]
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
    mov rax, QWORD PTR [rip+ok_main_gu64]
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
    movzx rax, BYTE PTR [rip+ok_main_gbyte]
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
    movzx rax, BYTE PTR [rip+ok_main_gflag]
    push rax
    pop rax
    mov rdi, rax
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_write_bool
    mov rsp, rbx
    pop rbx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    movsx rax, BYTE PTR [rip+ok_main_stats_base]
    push rax
    mov rax, [rsp+0]
    mov [rbp-96], rax
    add rsp, 8
    mov rdi, [rbp-96]
    push rbx
    mov rbx, rsp
    and rsp, -16
    call ok_main_stats_doubled
    mov rsp, rbx
    pop rbx
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
    movzx rax, WORD PTR [rip+ok_main_stats_limit]
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
    movsx rax, BYTE PTR [rip+ok_main_gi8]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    sub rax, rcx
    shl rax, 56
    sar rax, 56
    push rax
    pop rax
    mov BYTE PTR [rip+ok_main_gi8], al
    movsx rax, BYTE PTR [rip+ok_main_gi8]
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
    movzx rax, BYTE PTR [rip+ok_main_gu8]
    push rax
    mov eax, 1
    push rax
    pop rcx
    pop rax
    add rax, rcx
    shl rax, 56
    shr rax, 56
    push rax
    pop rax
    mov BYTE PTR [rip+ok_main_gu8], al
    movzx rax, BYTE PTR [rip+ok_main_gu8]
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

    .section .data
    .globl ok_main_gi8
    .balign 8
ok_main_gi8:
    .byte 156
    .globl ok_main_gi16
    .balign 8
ok_main_gi16:
    .value 32000
    .globl ok_main_gi32
    .balign 8
ok_main_gi32:
    .long 2294967296
    .globl ok_main_gu8
    .balign 8
ok_main_gu8:
    .byte 250
    .globl ok_main_gu16
    .balign 8
ok_main_gu16:
    .value 65000
    .globl ok_main_gu32
    .balign 8
ok_main_gu32:
    .long 4000000000
    .globl ok_main_gu64
    .balign 8
ok_main_gu64:
    .quad 18446744073709551615
    .globl ok_main_gbyte
    .balign 8
ok_main_gbyte:
    .byte 128
    .globl ok_main_gflag
    .balign 8
ok_main_gflag:
    .byte 1
    .globl ok_main_stats_base
    .balign 8
ok_main_stats_base:
    .byte 40
    .globl ok_main_stats_limit
    .balign 8
ok_main_stats_limit:
    .value 65535
