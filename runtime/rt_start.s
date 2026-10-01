# rt_start.s — program entry for Okular freestanding executables (x86-64).
# The kernel hands control to _start with a 16-aligned stack and the
# initial process stack layout: [rsp] = argc, [rsp+8] = argv[0]...
# (0.12) both are forwarded to rt_init so programs can read their own
# invocation arguments (the env builtins, spec §6.5); then aligning and
# calling gives every Okular function the ABI it was compiled against.
    .intel_syntax noprefix
    .text
    .globl _start
_start:
    xor ebp, ebp
    mov rdi, [rsp]        # argc
    lea rsi, [rsp+8]      # argv (the pointer array begins here)
    and rsp, -16
    call rt_init
    call __ok_entry
    mov rdi, rax
    call rt_exit
