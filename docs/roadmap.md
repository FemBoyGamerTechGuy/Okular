# Okular Development Roadmap

**Working document — updated as milestones complete. Nothing here is claimed
before the test suite proves it.**

## Where we are

**Okular 0.11 — milestone M2→M3 (systems types).** 0.2 added fixed-length
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
(§9). See `specs/spec-v0.11.md` §22 for the honest status table.

## Milestones

| ID | Milestone | Status |
|----|-----------|--------|
| M1 | C bootstrap compiler; hello-world and small programs run natively | **done (0.1)** |
| M2 | Language covers substantial normal programs | in progress — arrays (0.2), fixed-width integers (0.3), pointers + heap (0.4), structs (0.5), text conversions (0.6), unions (0.7), constants + type.auto (0.8), text operations (0.9), file builtins (0.10), bitwise + shifts (0.11) |
| M3 | Okular can compile portions of the compiler itself | **underway (0.11)** — `selfhost/lexer` tokenizes .ok files (same token set and numbering as the bootstrap lexer); proven by `tests/cases/positive/selfhost_lexer` |
| M4 | Compiler components rewritten in Okular (lexer first, then runtime shim) | lexer component exists; pipeline integration next |
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
2. **Token interface** — a machine-readable token format the Okular lexer
   can emit and the bootstrap parser can consume (or an in-process bridge),
   so `selfhost/lexer` becomes the compiler's actual lexer (M4 begins).
3. **Parser in Okular** — recursive descent over the token stream; needs
   the struct/union/array machinery to represent the AST.
4. **Runtime shim in Okular** — rewrite `runtime/rt.c` (write/print, traps,
   allocator, text arena) as Okular code compiled by the bootstrap
   compiler, replacing the freestanding C shim.
5. **Own integrated assembler** — the last external tool dependency
   (`as`/`ld`) moves in-house (spec §15).

## Deliberate non-goals

* A VM, bytecode-only mode, mandatory GC, mandatory runtime — rejected by
  design (brief §3/§27/§47).
* Macros/metaprogramming — not before the language core is stable.
* C header interop as a language foundation — C interop is a bridge feature
  gated on the FFI design (brief §25).
