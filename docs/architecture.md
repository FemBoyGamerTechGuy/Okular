# Okular Bootstrap Compiler — Architecture

**Version:** 0.3
**Applies to:** `bootstrap/` (the C implementation)

> The C implementation is scaffolding. It exists because Okular does not yet
> exist. Every component is structured so it can be rewritten in Okular
> component-by-component (see `docs/roadmap.md`, milestones M3–M7). Nothing in
> Okular's *semantics* is defined by this implementation.

---

## 1. Pipeline

```
            okular --compile main.ok
                      |
              [driver]  CLI parsing, option registry
                      |
              [project] project discovery: main.ok, src/ scan,
                        [source.files.use] graph, cycle detection,
                        optional-source policy
                      |
              [lexer]  per file: text -> tokens (with precise spans)
                      |
              [parser] per file: tokens -> AST (recursive descent,
                        error recovery at newline/}/.end sync points)
                      |
              [sema]   symbol tables (file -> column -> block scopes),
                        namespace resolution (module.column.name),
                        type checking, feature gates, warnings
                      |
              [ir]     typed stack-machine IR per function
                        + constant folding pass
                      |
              [codegen] x86-64 System V-flavored assembly, freestanding
                        (own `_start`, raw Linux syscalls, no libc)
                      |
              [assemble/link]  as -> .o,  ld -> executable
                      |
              build/output/<name>
```

The driver owns the pipeline but does no language work itself. Each stage has
a narrow interface so a future Okular-written stage can replace it behind the
same boundary.

---

## 2. Component layout

```
bootstrap/
├── include/ok/
│   ├── ok.h            common definitions, OkType, config
│   ├── util.h          buffers, arenas, string utils
│   ├── source.h        source manager (files, line index)
│   ├── diag.h          diagnostics engine
│   ├── lexer.h         token definitions + lexer API
│   ├── ast.h           AST node definitions
│   ├── parser.h        parser API
│   ├── project.h       project/module graph
│   ├── symtab.h        symbols, scopes, namespaces
│   ├── sema.h          semantic analysis API
│   ├── ir.h            IR instructions + builder + folding
│   ├── codegen.h       backend interface
│   └── driver.h        pipeline orchestration
└── src/
    ├── main.c          CLI entry, flag registry
    ├── util.c
    ├── source.c
    ├── diag.c
    ├── lexer.c
    ├── ast.c
    ├── parser.c
    ├── project.c
    ├── symtab.c
    ├── sema.c
    ├── ir.c
    ├── codegen_x64.c  the one backend (x86-64 Linux)
    └── driver.c

runtime/               bootstrap runtime shim (C, freestanding, no libc)
├── rt.c               output buffer, formatting, concat arena, traps
└── rt_start.s         _start trampoline (assembler)
```

Backend isolation: `codegen.h` declares a small interface (`codegen_module`,
`codegen_entry`). `codegen_x64.c` implements it for one target. Adding ARM64
later means adding `codegen_arm64.c` and a `--target` flag — nothing else in
the compiler changes. The IR is the contract between front end and back end.

---

## 3. Key data structures

### 3.1 Tokens

```c
typedef enum { T_IDENT, T_NUMBER_LIT, T_DEC_LIT, T_TEXT_LIT, T_KEYWORD, ... } TokKind;
typedef struct { TokKind kind; SrcLoc loc; /* line, col, byte offset */
                 char *text; /* identifier name / keyword / literal payload */
                 uint64_t ival; double dval; } Token;
```

Every token carries `SrcLoc` (file index, line, column, span) — diagnostics
are only as good as their locations.

### 3.2 AST

Plain C structs with a `kind` tag and per-node payload. Nodes own nothing;
the parser's arena owns all allocations, so freeing is trivial and leaks are
impossible by construction. Expressions and statements are separate node
families. Names are kept as dotted paths (`greeting.math.fall`) resolved in
sema — the parser does not guess what a dot means.

### 3.3 Symbols

```c
typedef struct Symbol { const char *name; OkType type;
                         SymKind kind; /* FUNC, VAR, NS */
                         struct Scope *scope; ... } Symbol;
```

Scopes nest: file/module scope → column scopes → function block scopes.
Module namespaces are scopes whose name is the file name; developer columns
are scopes nested inside them. Name lookup walks outward, then reports the
full candidate path in the error message.

### 3.4 IR

Typed stack machine: each instruction pops/pushes values whose Okular types
are tracked by the builder, so codegen never guesses.

```
LOAD_CONST_INT 42        ; pushes number
LOAD_LOCAL 3             ; slot 3
BINOP ADD                ; pops 2 numbers, pushes number
CALL ok_greeting_greet 0 ; pops args, pushes result (or nothing)
JMP_FALSE L7
WRITE                     ; builtin: pops 1, appends to output buffer
PRINT_FLUSH               ; statement
RETURN
```

`ir.c` contains the only optimization pass in 0.2: constant folding
(replaces `BINOP` over two foldable constants; used both for global
initializer checking and for `-xw` diagnostics like always-true comparisons).
The pass framework is a simple function-pointer list over functions — the
shape a real optimizer framework will grow into.

### 3.5 Code generation

x86-64, Linux, freestanding:

* Expression evaluation uses an operand stack on the machine stack
  (`push`/`pop` with `rax`/`rcx`/`xmm0`). Correctness before speed — the
  optimization milestone will lower through registers properly.
* Locals live at `rbp`-relative slots; every slot is rounded up to a
  multiple of 8 bytes for scalars (sub-word values are padded — the padding
  is unobservable), 16 for `text` (ptr+len pair), and the array's total
  bytes for arrays. Slots are typed and number-checked.
* **Fixed-width integers (0.3)**: values travel **extended** in 64-bit
  registers and operand-stack words — sign-extended for signed types,
  zero-extended for unsigned — and arithmetic runs at 64 bits then
  re-encodes (`shl`/`sar` or `shl`/`shr`) to the operand type's width.
  Memory uses natural widths: `movsx/movzx`/`movsxd`/`mov eax` loads and
  byte/word/dword stores for globals and array elements; `.data` emits
  `.byte`/`.value`/`.long`/`.quad` per type. Comparisons pick `setl`-family
  (signed) or `setb`-family (unsigned) from the operand type. Division is
  guarded: zero divisors call `rt_div_trap` (exit 71); `INT64_MIN / -1`
  wraps instead of raising `#DE`. `uint64` printing uses `rt_write_uint`.
* Globals live in `.data`/`.bss` under mangled names (`ok_<module>_<name>`).
* Calling convention: **Okular internal ABI v1** — up to 6 arguments in
  `rdi, rsi, rdx, rcx, r8, r9` (integer registers only), return in `rax`,
  caller cleans stack for excess args, `rbx`/`r12`–`r15` callee-saved.
  `decimal` values travel as raw bit patterns in integer registers/stack
  slots and live in `xmm` registers only while being computed. This is
  deliberately *not* full System V — SysV interop (XMM arg regs, varargs) is
  a designed milestone gated on FFI. It is our own ABI, documented here.
* **Arrays (v1)**: array-typed expressions evaluate to an *address* on the
  operand stack (`ADDR_LOCAL/GLOBAL`, `INDEX`, `LOAD_AT`, `STORE_AT`,
  `COPY`). Indexing scales by the element size after an unsigned bounds
  comparison; violations call `rt_bounds_trap` (exit 70). Whole-array
  assignment and parameter passing lower to `COPY` (`rep movsb`, byte-
  exact for sub-word element types). Array
  arguments: the caller copies the array into a per-frame scratch block
  (sized to the largest single call site's array bytes) and passes the
  copy's address in a register; the callee's prologue copies it into its
  own slot — value semantics with one register per argument, same shape as
  `text` pairs. Array globals are `.data` with `.globl` (cross-module
  access works); text elements point into `.rodata`.
* Text literals go to `.rodata` with a length table; `text` values are
  (ptr, len) pairs passed by value.
* The program entry `__ok_entry` is synthesized from `main.ok`'s top-level
  statements; `_start` (in `runtime/rt_start.s`) initializes the runtime,
  calls `__ok_entry`, and performs the `exit` syscall with the returned code.
* Every external symbol the compiler emits starts with `ok_` or `__ok_`;
  runtime helpers use the `rt_` prefix. No libc symbols are referenced
  anywhere. `ld` links `build/objects/*.o` + `runtime/rt.o` directly.

### 3.6 Bootstrap runtime shim

`runtime/rt.c` (~250 lines of freestanding C, built `gcc -ffreestanding
-nostdlib -fno-stack-protector -fno-builtin`) provides:

* output buffer management (`rt_write_*`, `rt_print`)
* integer/decimal/unsigned formatting, `text` concatenation via a static
  bump arena
* runtime traps (`rt_trap`: message + exit code 70; `rt_div_trap`: exit 71)

It is scaffolding in the same sense the C compiler is: milestone M4 rewrites
it in Okular against the syscall module. The *language* depends on none of
its internals — only on the documented `write`/`print` semantics.

---

## 4. Diagnostics engine

One engine, all stages. A diagnostic is: severity (error / warning / note),
location, message, optional "found" token, optional note lines. Rendering
follows the brief's required format:

```
src/player.ok:42:17

Error: expected a number after the `=` operator.

42 | number.health =
                 ^

Found: `}`

note: the declaration is missing an initializer.
```

The source manager keeps files and line offsets so excerpt rendering is
O(1)-ish per diagnostic. Error recovery: the parser synchronizes at newline,
`}`, `.end`, and column starts; compilation stops after 50 errors or when a
stage's output would be garbage. **An executable is never produced from
required code that failed to check** (brief §43/§71).

---

## 5. Project & module loading

1. Locate `main.ok` (from the CLI path).
2. Parse `[source.files.use]` columns (a fast pre-parse pass over tokens).
3. Build the module graph: `main.ok` → used files → their used files.
   Cycles → error with the cycle path.
4. Determine *required* files (reachable from main) vs *optional* (other
   `src/*.ok` files).
5. Compile required files; compile optional files too, but their failures
   downgrade to warnings in normal mode (never in `--strict`).
6. `[libs.use]` entries are checked against `libs/`, `deps/`, std dir;
   unresolved → warning (error in strict). Binding is future work.

---

## 6. Testing strategy

`tools/run_tests.sh` drives `tests/cases/`:

* **positive**: each `.ok` file must compile and its stdout/exit code must
  match the expected files.
* **negative**: each `.ok` file must fail to compile and produce the expected
  error class (message regex).
* **policy**: optional-broken-src / required-broken-src / strict-mode
  matrix (brief §36).
* **flags**: warnings and extra-warnings behavior.

The compiler also has hidden debug flags (`--dump-tokens`, `--dump-ast`,
`--dump-ir`, `--dump-symbols`, `--emit-asm`) used by tests to inspect stages.
Regression policy (brief §51): every fixed bug gets a case.

---

## 7. Self-hosting milestones

```
M1  bootstrap C compiler compiles real Okular programs      [done in 0.1]
M2  language covers substantial normal programs             [0.2+]
M3  Okular can compile portions of the compiler             [tracked in roadmap]
M4  compiler components rewritten in Okular (lexer first)
M5  Okular compiler builds itself
M6  C bootstrap no longer required
M7  C bootstrap removed from the repository
```

Progress is tracked in `docs/roadmap.md` — never claimed before it is true.

---

## 8. Portability

* Implemented: x86-64 Linux (the bootstrap target).
* The architecture is portable: target-specific code is confined to
  `codegen_x64.c` and `runtime/`; everything upstream of IR is target-
  independent; `as`/`ld` are invoked through a thin command abstraction.
* Planned, in order: ARM64 Linux, x86-64 other ELF platforms, Windows,
  macOS. Not claimed until they run the test suite.
