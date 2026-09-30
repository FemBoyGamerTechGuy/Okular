# rt_start.s — program entry for Okular freestanding executables (x86-64).
# The kernel hands control to _start with a 16-aligned stack; aligning and
# calling gives every Okular function the ABI it was compiled against.
    .intel_syntax noprefix
    .text
    .globl _start
_start:
    xor ebp, ebp
    and rsp, -16
    call rt_init
    call __ok_entry
    mov rdi, rax
    call rt_exit
