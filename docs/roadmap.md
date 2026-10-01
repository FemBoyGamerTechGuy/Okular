# Okular Development Roadmap

**Working document — updated as milestones complete. Nothing here is claimed
before the test suite proves it.**

## Where we are

**Okular 0.9 — milestone M2→M3 (systems types).** 0.2 added fixed-length
arrays; 0.3 the fixed-width integer family (`int8`…`uint64`, `byte`,
aliases) with wrapping arithmetic, the widening lattice, contextual literal
typing, and the `T.to_U(x)` conversion builtins; 0.4 pointers and manual
memory — `ptr<T>`, `&x`, `*p`, `alloc`/`release` over a real free-list heap
allocator, `null` checks, scaled arithmetic; 0.5 **structs** — predictable
layout, positional literals, field access with pointer auto-deref, value
semantics, nesting, arrays of structs, heap structs; 0.6 the **text conversion builtins**
(`number.to_text`, `text.to_number`, constant folding); 0.7 **unions** —
overlap layout, type-directed literals, documented reinterpretation
(`specs/spec-v0.9.md` §8.5); 0.8 **constants + type.auto** (§8.1); 0.9 **text operations** — `text.length`, bounds-checked `text.byte_at`, O(1) `text.slice` (§4.5). See
`specs/spec-v0.9.md` §22 for the honest status table.

## Milestones

| ID | Milestone | Status |
|----|-----------|--------|
| M1 | C bootstrap compiler; hello-world and small programs run natively | **done (0.1)** |
| M2 | Language covers substantial normal programs | in progress — arrays (0.2), fixed-width integers (0.3), pointers + heap (0.4), structs (0.5), text conversions (0.6), unions (0.7), constants + type.auto (0.8), text operations (0.9) |
| M3 | Okular can compile portions of the compiler itself | not started |
| M4 | Compiler components rewritten in Okular (lexer first, then runtime shim) | not started |
| M5 | Okular compiler builds itself | not started |
| M6 | C bootstrap no longer required | not started |
| M7 | C bootstrap removed from repository | not started |

## M2 work items, in dependency order

1. ~~**Arrays** — fixed-length~~ **done in 0.2**: `type.array<type.number, 5>`,
   literals, indexing, indexed stores, value-copy semantics, bounds traps,
   nesting, params, globals (`specs/spec-v0.9.md` §8.4). Dynamic arrays
   wait for the heap milestone.
2. ~~**Fixed-width integers**~~ **done in 0.3**: `int8`…`uint64` + `byte`/
   `int64`/`f64` aliases, wrapping arithmetic, widening lattice, contextual
   literals, `T.to_U(x)` conversion builtins, checked division
   (`specs/spec-v0.9.md` §4.2/§4.4).
3. ~~**Heap + pointers + manual memory**~~ **done in 0.4**: `ptr<T>`,
   `&x`/`&xs[i]`/`&*p`, `*p` loads and stores, unchecked `p[i]`, scaled
   `p ± n`, element-difference `p - q`, `null`, `alloc<T>(n)`/`release(p)`
   over a real allocator (`specs/spec-v0.9.md` §12).
4. ~~**Structs**~~ **done in 0.5**: `struct.X = { fields }.end`,
   natural-alignment layout, positional literals, field access (auto-deref
   through pointers), value copies, struct params, global structs, arrays
   of structs (`specs/spec-v0.9.md` §8.3). Explicit packed/offset layout
   attributes stay designed.
5. ~~**Unions**~~ **done in 0.7**: `union.X = { members }.end`, overlap
   layout (all members at offset 0), type-directed single-value literals,
   documented reinterpretation semantics, nesting both ways, arrays of
   unions, heap unions, global unions (`specs/spec-v0.9.md` §8.5).
6. **`f32`** — true 32-bit float (needs its own ABI/register path).
7. ~~**Remaining text conversion builtins**~~ **done in 0.6**:
   `number.to_text`, `uint64.to_text`, `decimal.to_text`, `bool.to_text`,
   `text.to_number`, `text.to_decimal` — constant folding included,
   strict parsing with loud failures (`specs/spec-v0.9.md` §4.4).
8. **Match-style selection** on the `when` foundation (`else when` chains,
   value matching) — extends, never breaks, existing syntax.
9. ~~**Constants** (`const`), **type inference** (`type.auto`)~~ **done in 0.8**: `const.name = value` folds and inlines at compile time; `type.auto x = init` infers from the initializer (`specs/spec-v0.9.md` §8.1). Const array lengths stay designed (needs module-aware parsing).
10. **Standard library beginnings** — `io`, `text`, `math`, `memory` modules,
    `[libs.use]` binding real code; `oklib` format design.
11. **ARM64 backend** — second target proves the backend abstraction.
12. **Optimizer framework** — register allocation, DCE, inlining on the IR;
    constant folding already exists as the first pass.

## Deliberate non-goals

* A VM, bytecode-only mode, mandatory GC, mandatory runtime — rejected by
  design (brief §3/§27/§47).
* Macros/metaprogramming — not before the language core is stable.
* C header interop as a language foundation — C interop is a bridge feature
  gated on the FFI design (brief §25).
