# Okular Development Roadmap

**Working document — updated as milestones complete. Nothing here is claimed
before the test suite proves it.**

## Where we are

**Okular 0.19 — recoverable errors.** In addition to everything below,
0.19 implements the designed error model (spec §13): `-> T?` marks a
fallible function; `fail <text>` raises with a message; every call to
a fallible function must be the initializer of a `guard v = call(...)
else (err) { ... }` — the else-block must exit (`return`/`fail`/
`break`/`continue`), which is exactly what makes the guarded value
safe to use past the guard; `err: text` is scoped to the block;
propagation is an explicit re-raise (`fail err`). The runtime ABI is
two `rt` globals (`err_flag`, `err_msg`) with clear-before-call and
bind-and-re-clear discipline — a recovered inner error can never leak
into an outer guard — emitted identically by both backends, treated as
a control-flow barrier by every optimizer pass (behavior identical at
-O0/-O1/-O2, differentially verified on x86-64, ARM64 under the
emulator, qemu, and native hardware). The LSP recompiles and hovers
through the new syntax (`function parse(s: text) -> number?`). Nine
new suite checks; the suite is now 850.

**Okular 0.18 — the language server.** In addition to everything
below, 0.18 gives Okular editor integration: `okular lsp` speaks
JSON-RPC 2.0 over stdio — initialize/shutdown/exit lifecycle, full-text
document sync (didOpen/didChange/didClose), publishDiagnostics (0-based
lines, UTF-16 code-unit characters, severity mapping, per-file
attribution including src/ dependencies and standalone files), and
hover with full signatures from the checker's symbol tables
(`function greet(name: text) -> text`). Every change recompiles the
project through the SAME phases a CLI compile runs — the open
document's buffer virtualized over its file via a generic tokenizer
source override, so nothing is written to disk — reusing the entire
frontend with a per-check state reset. The protocol suite (47 checks)
is adversarial: malformed JSON, lying Content-Length framing, binary
garbage, wrong parameter shapes, unknown methods — every one degrades
to a JSON-RPC error or a dropped notification; the server never
crashes. Recompiles allocate from a rewound scratch region — ~8 KiB of
residual growth per change, 8 ms per check, hover intact across
400-change endurance runs — and the runtime's text arena became a
growable region chain (long-lived processes no longer cliff at
16 MiB).

**Okular 0.17 — the ARM64 backend.** In addition to everything below,
0.17 gives Okular a second native target: `okular main.ok --target
arm64` emits a native linux-aarch64 ELF64 executable from the same
typed stack IR. The complete AArch64 backend (`selfhost/compiler/src/
arm.ok`, ~2300 lines) covers instruction selection for every IR
operation (NZCV condition codes, `msub`/`sdiv`/`udiv` with explicit
zero-checks, decimal and `f32` SIMD in D/S forms, narrow loads/stores,
struct and array copies), the AAPCS-style frame (paired `stp`/`ldp`,
16-byte alignment, args in `x0`-`x5`), REL26/ABS64_ARM fixups, and the
Linux aarch64 syscall interface — the same `rt.ok` runtime source,
lowered per target. Cross-compilation works in both directions;
`make arm64` cross-builds the compiler itself, and releases ship
`okular-linux-arm64` alongside the x86-64 archive. Verification, all
of it executing real programs: the full positive suite re-compiled
and executed under `tools/emu64.py` (the aarch64 user-mode emulator
shipping with the repository — a test tool, not a build dependency;
276 further checks, suite now 850), the same suite again under an
external qemu-aarch64 (`ARM64_RUN=qemu` — an independent
implementation of the machine and the Linux syscall ABI, so
emulator/kernel divergence is a red test on every push), the
self-cross-compilation test
(the emulated aarch64 compiler compiles a program that runs natively),
and — on real hardware — a native `ubuntu-24.04-arm` CI runner where
the ARM64 compiler self-compiles byte-identically and the whole
positive suite is compiled AND executed natively. `-O2` register-
cached emission remains x86-64-only for now (honest fallback to `-O1`).
Three latent defects were found by the ARM64 differential before they
could ship: a mis-aligned outgoing-argument area, `sys.open` passing
mode where flags belong, and a three-argument `fstatat` real kernels
reject. A fourth — `sys.size` calling syscall 80 (aarch64 `fstat`) with
newfstatat's four-argument setup while reading "st_size" from an
untouched stack slot — shipped runtime-less binaries that hung on real
hardware; its misdiagnosis (`st_size` at offset 40; the real
asm-generic layout is `__pad1@40 size@48`, exactly like x86-64) was
corrected against the kernel headers and verified empirically with a
probe ELF under qemu-aarch64. The emulator models the real kernel, and
the `fs_size_abi` regression test pins the exact stat size on every
target.

**Okular 0.16 — the optimizer.** In addition to everything below, 0.16
gives Okular its first real optimization subsystem: `-O1` runs an IR
pass pipeline (dead-code elimination with provably-balanced dead-store
replacement, control-flow simplification, algebraic peephole) and `-O2`
switches the x86-64 backend to register-cached emission — exact
liveness from the stack discipline, GP/XMM register classes,
spill-the-deepest-cached policy, caller-saved flush at calls,
store-to-load forwarding. Measured: fib(30) ~24% faster, binaries ~6%
smaller, +11% compile time. Optimization is opt-in: the default build
and the seed's byte-identical reproduction never depend on it, and the
differential suite now triple-compiles every positive case at
-O0/-O1/-O2 (233 -> 503 checks); the compiler self-compiles under -O2
and that binary passes the whole suite. A latent 0.15 defect was found
by the new stress tests and fixed: runtime (non-folded)
`number.to_f32` emitted `cvtsi2sd` instead of `cvtsi2ss`, so any
variable converted to `f32` produced `0.0` (constants were folded and
masked it).

**Okular 0.15 — match-style `when`, `f32`, and the standard library.**
In addition to everything below, 0.15 gives the `when` keyword a second
reading: `when (subject) { pattern { ... } ... else { ... } }` — equality
patterns for integers, decimals, `text`, `bool`, and pointers (`null`),
inclusive `lo to hi` ranges, comma-separated alternatives, constant
patterns, arm guards that run only after the pattern matched,
subject-evaluated-once semantics, first-match-wins, and exhaustiveness
that satisfies the return analysis. **`f32`** arrives as a true 32-bit
IEEE float: SSE single-precision arithmetic, 4-byte storage, one-RNE
literals, bit-exact folding, exact widening to `decimal`, the full
conversion family, and NaN/inf/signed-zero semantics. **`[libs.use]`
binds** — libraries are modules resolved from `libs/`, `deps/`, or the
compiler's `stdlib/`, and the first four standard-library modules ship:
`math`, `text`, `io`, `memory` (35 new test cases). Two real correctness
defects were found and fixed along the way: text ordering (`"a" < "z"`)
was silently accepted and compiled as equality — now a precise compile
error; and NaN equality assembled its `and` into the wrong register
(`nan == nan` was `true`) — fixed in both the decimal and f32 paths.

**Okular 0.13 — milestone M4 (the parser runs in Okular).** In addition to
everything below, 0.13 makes **`and`/`or` short-circuit** (§9 — guards like
`p != null and *p == x` no longer trap), and **the parser itself is now
written in Okular**: `selfhost/parser/src/parser.ok` ports the complete
recursive descent grammar, `--selfhost-parse` makes it the compiler's
parser, and `--selfhost-verify` differentially proves the trees
byte-identical to the C parser's on the whole positive suite (identical
program output end to end). Three deep defects found along the way are
fixed and regression-tested: the heap allocator's split overlapped
adjacent blocks; `rt_release` erased its own double-release marker; and
record assignment through pointer indexing/dereference stored the
source's address instead of copying the bytes.

**Okular 0.12 — milestone M2→M3 (systems types).** 0.2 added fixed-length
arrays; 0.3 the fixed-width integer family (`int8`…`uint64`, `byte`,
aliases) with wrapping arithmetic, the widening lattice, contextual literal
typing, and the `T.to_U(x)` conversion builtins; 0.4 pointers and manual
memory — `ptr<T>`, `&x`, `*p`, `alloc`/`release` over a real free-list heap
allocator, `null` checks, scaled arithmetic; 0.5 **structs** — predictable
layout, positional literals, field access with pointer auto-deref, value
semantics, nesting, arrays of structs, heap structs; 0.6 the **text conversion builtins**
(`number.to_text`, `text.to_number`, constant folding); 0.7 **unions** —
overlap layout, type-directed literals, documented reinterpretation
(`specs/spec-v0.11.md` §8.5); 0.8 **constants + type.auto** (§8.1); 0.9 **text operations** — `text.length`, bounds-checked `text.byte_at`, O(1) `text.slice` (§4.5); 0.10 **file builtins** — `fs.read`/`fs.save`/`fs.exists` over raw syscalls (§6.4); 0.11 **bitwise operations** — `& | ^ ~ << >>` with range-checked
shifts, Rust-ordered precedence, and `>>` splitting for nested type arguments
(§9); 0.12 **environment builtins** — `env.arg_count()`/`env.arg(i)`, the
program's command line (§6.5). See `specs/spec-v0.13.md` §22 for the honest
status table.

## Milestones

| ID | Milestone | Status |
|----|-----------|--------|
| M1 | C bootstrap compiler; hello-world and small programs run natively | **done (0.1)** |
| M2 | Language covers substantial normal programs | in progress — arrays (0.2), fixed-width integers (0.3), pointers + heap (0.4), structs (0.5), text conversions (0.6), unions (0.7), constants + type.auto (0.8), text operations (0.9), file builtins (0.10), bitwise + shifts (0.11), env builtins (0.12) |
| M3 | Okular can compile portions of the compiler itself | **done (0.13)** — `selfhost/lexer` and now `selfhost/parser` compile real compiler components |
| M4 | Compiler components rewritten in Okular (lexer, parser, runtime shim) | **done (0.13)** — lexer, parser, and runtime all written in Okular, differentially verified on every positive case |
| M5 | Okular compiler builds itself | **done (0.14)** — `selfhost/compiler` is the complete compiler in Okular (~13.9k lines: toks, parser, sema, ir, emit, elf, rt); stage 0->1->2->3 bootstrap chain verified with a byte-identical fixed point, and the self-built compiler passes the full 187-case differential suite (`make bootstrap-chain`) |
| M6 | C bootstrap no longer required | **done (0.14)** — `make` builds the compiler with the committed native seed (`bin/okular`) and the Okular sources alone: no cc, no as, no ld; `make test` proves the seed reproduces itself byte-identically and passes the differential suite; the C bootstrap is opt-in (`make c-bootstrap` / `make test-c`) for transition differential work |
| M7 | C bootstrap removed from repository | **done (0.14)** — `bootstrap/`, `runtime/rt.c`, and the C test tooling are deleted; the repository carries `bin/okular` (the committed native seed) and `make`/`make test` run with zero C; verified from a clean checkout |

## M2 work items, in dependency order

1. ~~**Arrays** — fixed-length~~ **done in 0.2**: `type.array<type.number, 5>`,
   literals, indexing, indexed stores, value-copy semantics, bounds traps,
   nesting, params, globals (`specs/spec-v0.11.md` §8.4). Dynamic arrays
   wait for the heap milestone.
2. ~~**Fixed-width integers**~~ **done in 0.3**: `int8`…`uint64` + `byte`/
   `int64`/`f64` aliases, wrapping arithmetic, widening lattice, contextual
   literals, `T.to_U(x)` conversion builtins, checked division
   (`specs/spec-v0.11.md` §4.2/§4.4).
3. ~~**Heap + pointers + manual memory**~~ **done in 0.4**: `ptr<T>`,
   `&x`/`&xs[i]`/`&*p`, `*p` loads and stores, unchecked `p[i]`, scaled
   `p ± n`, element-difference `p - q`, `null`, `alloc<T>(n)`/`release(p)`
   over a real allocator (`specs/spec-v0.11.md` §12).
4. ~~**Structs**~~ **done in 0.5**: `struct.X = { fields }.end`,
   natural-alignment layout, positional literals, field access (auto-deref
   through pointers), value copies, struct params, global structs, arrays
   of structs (`specs/spec-v0.11.md` §8.3). Explicit packed/offset layout
   attributes stay designed.
5. ~~**Unions**~~ **done in 0.7**: `union.X = { members }.end`, overlap
   layout (all members at offset 0), type-directed single-value literals,
   documented reinterpretation semantics, nesting both ways, arrays of
   unions, heap unions, global unions (`specs/spec-v0.11.md` §8.5).
6. ~~**Bitwise operations**~~ **done in 0.11**: `&`, `|`, `^`, `~`, `<<`,
   `>>` on every integer type; widening-lattice typing, Rust-ordered
   precedence (comparisons looser than bitwise), arithmetic/logical shift
   split by signedness, wrapping left shifts, range-checked counts
   (compile error in constants, exit-72 trap at runtime), constant
   folding, `>>` token splitting for nested type arguments
   (`specs/spec-v0.11.md` §9).
7. ~~**Remaining text conversion builtins**~~ **done in 0.6**:
   `number.to_text`, `uint64.to_text`, `decimal.to_text`, `bool.to_text`,
   `text.to_number`, `text.to_decimal` — constant folding included,
   strict parsing with loud failures (`specs/spec-v0.11.md` §4.4).
8. ~~**Match-style selection**~~ **done in 0.15**: `when (subject) {
pattern { ... } ... }` — literals, constants, `null`, inclusive `lo to hi`
ranges, comma-separated alternatives, guards, exhaustiveness for `bool`
subjects, duplicate/empty-range/misplaced-`else` diagnostics
(`specs/spec-v0.16.md` §10.1). Struct patterns and destructuring remain
designed, not implemented.
9. ~~**`f32`**~~ **done in 0.15**: a true 32-bit IEEE float — SSE
single-precision arithmetic/comparisons, 4-byte storage (locals, globals,
arrays, structs), one-rounding literals, Figueroa-safe bit-exact folding
(division deliberately unfolded), exact widening to `decimal`, the full
conversion family, NaN/inf/signed-zero shapes, scientific formatting
for large magnitudes (`specs/spec-v0.16.md` §4.2).
10. ~~**Constants** (`const`), **type inference** (`type.auto`)~~ **done in 0.8**: `const.name = value` folds and inlines at compile time; `type.auto x = init` infers from the initializer (`specs/spec-v0.11.md` §8.1). ~~Const array lengths~~ **done in 0.14**: `type.array<T, NAME>` with module-visible constant names and dotted module paths (`specs/spec-v0.14.md` §8.4).
11. ~~**Standard library beginnings**~~ **done in 0.15**: `[libs.use]`
    binds — a library is a module (`libs/`, `deps/`, the compiler's
    `stdlib/`, transitively). First modules: `math`, `text`, `io`,
    `memory` (`specs/spec-v0.16.md` §6.3). The `oklib` packaged format
    remains designed.
12. ~~**ARM64 backend**~~ **done in 0.17**: `--target arm64` — full
    AArch64 instruction selection, AAPCS-style frames, Linux aarch64
    syscalls, cross-compilation both directions, `make arm64` cross-
    builds the compiler itself, releases ship `okular-linux-arm64`;
    verified emulated (`tools/emu64.py`, 264 further differential
    checks) AND natively on `ubuntu-24.04-arm` CI runners
    (`specs/spec-v0.17.md` §15). The `-O2` register-cached mode remains
    x86-64-only on this target (falls back to `-O1`). RISC-V remains
    the planned third target.
13. ~~**Optimizer framework**~~ **done in 0.16**: `-O1` IR passes (DCE,
    control-flow simplification, peephole) and `-O2` register-cached
    emission with spills/reloads and GP/XMM register classes
    (`specs/spec-v0.16.md` §15). Inlining and cross-block dataflow
    remain future work.
14. ~~**Formatter**~~ **done in 0.15**: `okular fmt` — token-based,
    comment-preserving, semantics-preserving (byte-identical binaries
    from formatted sources), `--check` for CI; the repository formats
    itself with it.

## M3/M4 work items (self-hosting)

1. ~~**Tokenizer in Okular**~~ **done in 0.11**: `selfhost/lexer/src/lexer.ok`
   — the full token set of spec §1 (keywords, literals with hex/underscores/
   escapes, all operators including `<<`/`>>`, newline suppression inside
   ( ) and [ ] groups, `#` comments), same kind numbering as
   `bootstrap/src/lexer.c`, verified against a golden token stream
   (`tests/cases/positive/selfhost_lexer`).
2. ~~**Token interface**~~ **done in 0.12**: the machine token stream
   (`K L C S <bytes>` records, `bootstrap/src/selfhost_bridge.c`) plus the
   `--selfhost-lex <binary>` flag — the bootstrap compiler spawns the
   compiled `selfhost/lexer` program for every project file and consumes
   its token stream. `make selfhost-lex` builds the component;
   `tests/cases/flags/selfhost_lex` compiles a full program through it;
   the whole positive suite was differentially verified to produce
   identical results through both lexers.
3. ~~**Parser in Okular**~~ **done in 0.13**: `selfhost/parser` — the
   full grammar (expressions with the complete precedence ladder,
   statements, functions, structs, unions, columns, directives, the `>>`
   split, recovery), an in-memory tokenizer (`src/toks.ok`), and the
   machine AST protocol consumed by `--selfhost-parse`. Proven three
   ways: `--selfhost-verify` (byte-identical serializations on every
   positive case), full compile+run through the bridge (identical
   program output), and `tests/cases/flags/selfhost_parse`.
4. ~~**Runtime shim in Okular**~~ **done in 0.13**: `selfhost/runtime` —
   output formatters, text arena, conversions, the free-list allocator,
   and file operations, all in Okular on the `sys.*` syscall floor
   (spec §23). Proven by `tests/cases/positive/selfhost_runtime` (25
   subsystem checks). The C shim keeps only the raw syscall wrappers;
   flipping generated code to call `ok_rt_*` happens with the M5 driver.
5. ~~**Own integrated assembler**~~ **begun in 0.13 (the M5 seed)**:
   `selfhost/assembler` emits a complete native x86-64 ELF64 executable
   from Okular — ELF headers, machine code, a symbol table with ABS32
   and REL32 fixups, `fs.save`, `sys.chmod` — and the emitted binary
   runs (`tests/cases/positive/selfhost_assembler`, verified by the
   suite's new `exec_after` chain). No `as`, no `ld` anywhere in that
   chain. Growing this emitter into the full backend IS the M5 backend
   work; the C bootstrap keeps `as`/`ld` until it retires.
6. ~~**Sema in Okular**~~ **done in 0.14**: `selfhost/compiler/src/sema.ok`
   (~4.7k lines) — the full type checker (collect + check) running as
   Okular code against in-memory trees, no bridge at all, plus `ir.ok`
   (IR build + constant folding), `emit.ok` (the complete x86-64 backend:
   every IR instruction, the stack machine, calls with the rbx alignment
   discipline, inline syscalls with frame-resident path buffers, trap
   sites), `elf.ok` (native ELF64 emission with ABS64/REL32 fixups), and
   the `main.ok` driver (`okc main.ok` — project load, sema, IR, emit).
   Verified by the M5 bootstrap chain and the 187-case differential
   suite; one real backend defect was found and fixed this way (chmod
   trap labels colliding with IR labels — `sys_chmod_label_trap`
   regression).

## Deliberate non-goals

* A VM, bytecode-only mode, mandatory GC, mandatory runtime — rejected by
  design (brief §3/§27/§47).
* Macros/metaprogramming — not before the language core is stable.
* C header interop as a language foundation — C interop is a bridge feature
  gated on the FFI design (brief §25).
