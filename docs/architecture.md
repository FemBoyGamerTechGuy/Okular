# Okular Compiler — Architecture

**Version:** 0.14
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
            [emit]   per IR function: x86-64 machine code — prologue,
                      stack-machine pushes/pops, calls with the rbx
                      alignment discipline, inline syscalls, trap sites
                |
            [elf]    one R+X PT_LOAD image: headers + code + rodata +
                      data (+bss), ABS64/REL32 fixups, entry stub,
                      fs.save + chmod
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

## 5. Targets

* Implemented: x86-64 Linux (System V kernel syscall ABI).
* Planned: ARM64 as the second backend — proving the emitter abstraction.

## 6. Testing

* `tools/run_selfhost_tests.sh` — 191 cases: positive (compile + run +
  exact stdout/exit), negative (exact diagnostic patterns), policy
  (optional-source semantics incl. `--strict`).
* `tools/run_selfbuild_check.sh` — the acceptance gate: seed
  self-reproduction + the full suite.
* CI (`.github/workflows/ci.yml`) runs the gate, then packages and
  end-to-end tests the downloadable compiler (build -> unpack -> compile
  hello -> run it) on every push, and publishes releases on `v*` tags.
