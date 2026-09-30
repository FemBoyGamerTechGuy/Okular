# Okular 0.4 bootstrap — x86-64 Linux assembly
# module: main
    .intel_syntax noprefix

    .text

    .globl ok_main_run
ok_main_run:
    push rbp
    mov rbp, rsp
    sub rsp, 208
    lea rax, [rip+ok_main_origin]
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
    call rt_write_number
    mov rsp, rbx
    pop rbx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    lea rax, [rip+ok_main_origin]
    push rax
    pop rax
    add rax, 8
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
    lea rax, [rip+ok_main_marker]
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
    call rt_write_number
    mov rsp, rbx
    pop rbx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    lea rax, [rip+ok_main_marker]
    push rax
    pop rax
    add rax, 8
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
    lea rax, [rip+ok_main_origin]
    push rax
    pop rax
    push rax
    mov eax, 5
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rip+ok_main_origin]
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
    call rt_write_number
    mov rsp, rbx
    pop rbx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    lea rax, [rip+ok_main_default]
    push rax
    pop rax
    push rax
    pop rax
    mov eax, DWORD PTR [rax]
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
    lea rax, [rip+ok_main_default]
    push rax
    pop rax
    add rax, 4
    push rax
    pop rax
    mov eax, DWORD PTR [rax]
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
    lea rax, [rip+ok_main_default]
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
    lea rax, [rip+ok_main_default]
    push rax
    pop rax
    add rax, 9
    push rax
    pop rax
    movzx rax, BYTE PTR [rax]
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
    lea rax, [rip+ok_main_default]
    push rax
    pop rax
    add rax, 16
    push rax
    pop rax
    mov rdx, [rax+8]
    mov rax, [rax]
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
    lea rax, [rip+ok_main_config_center]
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
    call rt_write_number
    mov rsp, rbx
    pop rbx
    push rbx
    mov rbx, rsp
    and rsp, -16
    call rt_print
    mov rsp, rbx
    pop rbx
    lea rax, [rip+ok_main_config_ui]
    push rax
    pop rax
    push rax
    pop rax
    mov eax, DWORD PTR [rax]
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
    lea rax, [rip+ok_main_config_ui]
    push rax
    pop rax
    add rax, 16
    push rax
    pop rax
    mov rdx, [rax+8]
    mov rax, [rax]
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
    lea rax, [rip+ok_main_config_center]
    push rax
    pop rax
    add rax, 8
    push rax
    mov eax, 300
    push rax
    pop rax
    pop rcx
    mov QWORD PTR [rcx], rax
    lea rax, [rip+ok_main_config_center]
    push rax
    pop rax
    add rax, 8
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
    lea rax, [rbp-16]
    push rax
    lea rax, [rip+ok_main_origin]
    push rax
    pop rsi
    pop rdi
    mov rcx, 16
    rep movsb
    lea rax, [rbp-16]
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
.Lgstr0:
    .byte 111, 107, 117, 108, 97, 114
.Lgstr1:
    .byte 117, 105

    .section .data
    .globl ok_main_origin
    .balign 8
ok_main_origin:
    .quad 0
    .quad 0
    .globl ok_main_marker
    .balign 8
ok_main_marker:
    .quad 18446744073709551611
    .quad 12
    .globl ok_main_default
    .balign 8
ok_main_default:
    .long 1920
    .long 1080
    .byte 32
    .byte 1
    .zero 6
    .quad .Lgstr0, 6
    .globl ok_main_config_center
    .balign 8
ok_main_config_center:
    .quad 100
    .quad 200
    .globl ok_main_config_ui
    .balign 8
ok_main_config_ui:
    .long 800
    .long 600
    .byte 24
    .byte 0
    .zero 6
    .quad .Lgstr1, 2
