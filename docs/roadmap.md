# Okular Development Roadmap

**Working document — updated as milestones complete. Nothing here is claimed
before the test suite proves it.**

## Where we are

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
| M4 | Compiler components rewritten in Okular (lexer, parser, runtime shim) | **underway (0.13)** — `--selfhost-lex` (tokenizer bridge) and `--selfhost-parse` (parser bridge, machine AST protocol) both work and are differentially verified on all positive cases; the C lexer/parser remain the default |
| M5 | Okular compiler builds itself | not started |
| M6 | C bootstrap no longer required | not started |
| M7 | C bootstrap removed from repository | not started |

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
8. **Match-style selection** on the `when` foundation (`else when` chains,
   value matching) — extends, never breaks, existing syntax.
9. **`f32`** — true 32-bit float (needs its own ABI/register path).
10. ~~**Constants** (`const`), **type inference** (`type.auto`)~~ **done in 0.8**: `const.name = value` folds and inlines at compile time; `type.auto x = init` infers from the initializer (`specs/spec-v0.11.md` §8.1). Const array lengths stay designed (needs module-aware parsing).
11. **Standard library beginnings** — `io`, `text`, `math`, `memory` modules,
    `[libs.use]` binding real code; `oklib` format design.
12. **ARM64 backend** — second target proves the backend abstraction.
13. **Optimizer framework** — register allocation, DCE, inlining on the IR;
    constant folding already exists as the first pass.

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
6. **Sema in Okular** — the type checker (collect + check) is the largest
   remaining C component; the M5 self-build needs it. Requires growing
   the machine protocol from AST records to symbol/type records, or (the
   planned route) running sema as Okular code against in-memory trees
   with no bridge at all.

## Deliberate non-goals

* A VM, bytecode-only mode, mandatory GC, mandatory runtime — rejected by
  design (brief §3/§27/§47).
* Macros/metaprogramming — not before the language core is stable.
* C header interop as a language foundation — C interop is a bridge feature
  gated on the FFI design (brief §25).
