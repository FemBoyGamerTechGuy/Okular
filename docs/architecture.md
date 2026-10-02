# Okular Compiler — Architecture

**Version:** 0.18
**Applies to:** `selfhost/compiler` (the Okular implementation)

> The compiler is written in Okular and compiles itself. The C bootstrap
> that once grew these components is gone (M7); the repository carries a
> native seed binary (`bin/okular`) at a verified self-compilation fixed
> point, and `make` uses it to rebuild the compiler from source — no C
> compiler, no `as`, no `ld` anywhere.

---

## 1. Pipeline

```
            okc main.ok
                |
            [driver]  main.ok — CLI parsing, project load, phases
                |
            [toks]   per file: text -> tokens (in-memory, precise spans)
                |
            [parser] per file: tokens -> AST (recursive descent, recovery
                      at newline/}/.end sync points)
                |
            [sema]   symbol tables (file -> column -> block scopes),
                      namespace resolution (module.column.name), full
                      type checking, constant evaluation, control-flow
                      and return validation, diagnostics
                |
            [ir]     per required module: AST -> stack-machine IR
                      (function list, instruction list, constant folding)
                |
            [opt]    -O1: IR pass pipeline — dead-code elimination,
                      control-flow simplification, algebraic peephole
                |
            [emit]   per IR function: x86-64 machine code — prologue,
                      calls with the rbx alignment discipline, inline
                      syscalls, trap sites; -O2: register-cached
                      evaluation (the operand stack's top units live in
                      registers), -O0: classic stack-machine pushes/pops
                |
             OR, with --target arm64:
                |
            [arm]    per IR function: AArch64 machine code — the same
                      typed stack IR lowered to fixed 4-byte instructions
                      with NZCV condition codes, the AAPCS-style frame
                      (stp/ldp x29-x30, 16-byte alignment, args x0-x5),
                      movz/movk absolute address chains (ABS64_ARM
                      fixup), REL26 branches/calls, Linux aarch64
                      syscall numbers; -O2 falls back to -O1 here
                |
            [elf]    one R+X PT_LOAD image: headers + code + rodata +
                      data (+bss), ABS64/REL32 fixups (x86-64) or
                      ABS64_ARM/REL26 fixups (aarch64), e_machine 62 or
                      183, entry stub, fs.save + chmod
                |
            native ELF64 executable (freestanding, raw syscalls)
```

## 2. Modules

`selfhost/compiler/src/` — all Okular, loaded via `[source.files.use]`:

| File | Role |
|---|---|
| `toks.ok` | the tokenizer: byte stream to token records, keyword table, `>>` splitting for nested type arguments |
| `parser.ok` | the complete grammar: expressions with the precedence ladder, statements, functions, structs/unions, columns, directives, error recovery |
| `sema.ok` | the type checker: collect (symbols, module scopes, struct layout) + check (every expression/statement rule), constant evaluation, diagnostics with the optional-source downgrade policy |
| `ir.ok` | IR construction (stack-machine form), constant folding, `--dump-ir` |
| `opt.ok` | the optimizer (0.16): the `-O1` pass pipeline — DCE, jump simplification, peephole; pass statistics |
| `arm.ok` | the ARM64 backend (0.17): the same typed stack IR lowered to AArch64 machine code — instruction selection, frames, fixups, syscall numbers |
| `lsp.ok` | the language server protocol half (0.18): a robust JSON parser/writer, Content-Length framing with garbage resynchronization, UTF-8↔UTF-16 position mapping, the open-document table |
| `rt.ok` | gains the recompile scratch region: during LSP checks the allocator and text arena route into one 16 MiB region the next check rewinds (~8 KiB residual growth per change) |
| `emit.ok` | the x86-64 backend: every IR instruction, frame layout, call discipline, inline syscalls, trap sequences, label backpatching |
| `elf.ok` | native ELF64 emission: segments, symbols, fixups, entry |
| `rt.ok` | the runtime compiled into every program: output formatters, text arena, conversions, the free-list heap allocator, file operations — on the `sys.*` syscall floor |
| `main.ok` | the driver: project load (prescan of `[source.files.use]`), the optional `src/` scan (getdents64), phases, output |

## 3. ABI notes

* **Stack machine:** expressions evaluate through push/pop on the machine
  stack; every value is 8 bytes (text is a (ptr,len) pair = two pushes).
* **Calls:** `rbx` is callee-saved and doubles as the alignment anchor —
  every call is wrapped `push rbx; mov rbx,rsp; and rsp,-16; call;
  mov rsp,rbx; pop rbx`, mirroring the discipline the C bootstrap used.
* **Frames:** `[rbp-locals]` slots, a 96-byte outgoing-arg area, array-arg
  copy scratch, and a syscall scratch (256-byte path buffer + stat
  struct) at the bottom.
* **Syscalls:** `sys.*` builtins are emitted inline (write, read, open,
  close, size/fstat, mmap, exit, chmod, mkdir, getdents/getdents64);
  everything else the runtime needs rides on this floor.
* **Traps:** runtime failures are loud, named, and exit-coded (div-by-zero
  71, shift-range 72, null deref 73, fs errors 77, ...). Emitter-side trap
  sequences use labels in a `TRAP_BASE` region above the IR label space —
  the collision of the two label families was a real 0.14 bug (see
  `tests/cases/positive/sys_chmod_label_trap`).

## 4. Bootstrap and determinism

* `bin/okular` is the committed seed: a self-built compiler (stage 2 of
  the historical chain). `make` has the seed compile
  `selfhost/compiler` sources into `build/okular`.
* Determinism: the emitted ELF contains no timestamps or layout noise, so
  the seed compiling the sources it was built from reproduces itself
  **byte-for-byte**. `make test` proves it every run.
* Compiler changes: `make update-seed` (tools/update_seed.sh) rebuilds to
  the new fixed point (A: old seed -> new sources; B: A -> sources; C:
  B -> sources; require B == C), runs the suite, installs B as the new
  seed. If the new sources use a feature the old seed lacks, bridge by
  stubbing the use once, building, restoring, and re-running.

## 5. The optimizer (0.16)

* `-O1` (`opt.ok`): reachability-based DCE (dead stores to non-address-
  taken locals become pops — the operand stack stays balanced), dead
  pure computations, constant-condition branch folding, jump threading,
  jump-to-next removal, dead labels, identity/zero peephole. Every
  rewrite is stack-neutral and trap-neutral.
* `-O2` (`emit.ok`): register-cached emission. The operand stack is
  tracked in 8-byte units; the machine stack holds the deepest units
  and registers cache the top (spilling the deepest cached unit evicts
  the value used furthest in the future). Consumers pop into the exact
  registers each op needs; GP (9 regs) and XMM (8 regs, `decimal`)
  are separate classes; calls flush (caller-saved); store-to-load
  forwarding folds reloads. Uncovered instructions flush and run the
  classic path — correctness by construction. Measured: fib(30) ~24%
  faster, binaries ~6% smaller, +11% compile time.
* The default build is -O0: the seed's byte-identical self-reproduction
  never depends on optimizer behavior. The differential suite triple-
  compiles every positive case at -O0/-O1/-O2 (503 checks); the compiler
  self-compiles under -O2 and passes the suite.

## 6. Targets

* Implemented: x86-64 Linux (System V kernel syscall ABI) — classic
  stack-machine codegen at `-O0`, register-cached at `-O2`.
* Implemented: ARM64 Linux (AAPCS-style frames, Linux aarch64 syscall
  numbers) — selected with `--target arm64`; classic stack-machine
  codegen with the `-O1` IR passes available (register-cached `-O2`
  emission is x86-64-only and honestly falls back to `-O1`). The
  runtime source `rt.ok` is shared; syscall numbers and call frames
  differ per target. Cross-compilation works in both directions from
  either distribution, and `make arm64` cross-builds the compiler
  itself for aarch64.
* Planned: RISC-V as the third backend.

## 7. Testing

* `tools/run_selfhost_tests.sh` — 503 checks: positive (compile + run +
  exact stdout/exit — at -O0, -O1, AND -O2), negative (exact diagnostic
  patterns), policy (optional-source semantics incl. `--strict`).
* `tools/run_arm64_tests.sh` — 264 further checks: every positive case
  re-compiled `--target arm64` and executed (under `tools/emu64.py`, the
  aarch64 user-mode emulator shipping with the repository, or natively
  via `ARM64_RUN=native` on real aarch64 hosts) — stdout and exit codes
  must match the x86-64 expectations exactly.
* `tools/run_selfbuild_check.sh` — the acceptance gate: seed
  self-reproduction + the full suite.
* `tools/run_lsp_tests.sh` + `tools/lsp_test.py` — 47 protocol
  checks: a real JSON-RPC client drives `okular lsp` through the
  lifecycle, document sync, diagnostics (UTF-16 positions, dependency
  attribution), hover signatures — and the robustness clause (malformed
  anything degrades to an error response, never a crash).
* CI (`.github/workflows/ci.yml`) runs the gate, the emulated ARM64
  suite, the self-cross-compilation test, a native `ubuntu-24.04-arm`
  job (the ARM64 compiler self-compiles byte-identically on real
  hardware; the full positive suite is compiled and executed natively),
  and the LSP protocol suite, then packages and end-to-end tests both
  downloadable compilers (build -> unpack -> compile hello -> run it)
  on every push, and publishes releases on `v*` tags.
