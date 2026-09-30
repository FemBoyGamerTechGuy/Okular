# Okular Development Roadmap

**Working document — updated as milestones complete. Nothing here is claimed
before the test suite proves it.**

## Where we are

**Okular 0.3 — milestone M2→M3 (systems types).** On top of the M1 bootstrap
compiler and 0.2's fixed-length arrays, 0.3 adds the **fixed-width integer
family** (`int8`…`uint64`, `byte`, aliases) with wrapping arithmetic, the
implicit widening lattice, contextual literal typing, and the `T.to_U(x)`
conversion builtins — plus checked division. The type system runs on
interned descriptors; the address-forming IR is ready for pointers. See
`specs/spec-v0.3.md` §22 for the honest status table.

## Milestones

| ID | Milestone | Status |
|----|-----------|--------|
| M1 | C bootstrap compiler; hello-world and small programs run natively | **done (0.1)** |
| M2 | Language covers substantial normal programs | in progress — arrays (0.2), fixed-width integers + conversions (0.3) |
| M3 | Okular can compile portions of the compiler itself | not started |
| M4 | Compiler components rewritten in Okular (lexer first, then runtime shim) | not started |
| M5 | Okular compiler builds itself | not started |
| M6 | C bootstrap no longer required | not started |
| M7 | C bootstrap removed from repository | not started |

## M2 work items, in dependency order

1. ~~**Arrays** — fixed-length~~ **done in 0.2**: `type.array<type.number, 5>`,
   literals, indexing, indexed stores, value-copy semantics, bounds traps,
   nesting, params, globals (`specs/spec-v0.3.md` §8.4). Dynamic arrays
   wait for the heap milestone.
2. ~~**Fixed-width integers**~~ **done in 0.3**: `int8`…`uint64` + `byte`/
   `int64`/`f64` aliases, wrapping arithmetic, widening lattice, contextual
   literals, `T.to_U(x)` conversion builtins, checked division
   (`specs/spec-v0.3.md` §4.2/§4.4).
3. **Heap + pointers + manual memory** (`alloc/release`, `&x`, deref,
   pointer arithmetic, `null`) — unlocks structs-by-reference, dynamic
   arrays, FFI. The address-forming IR (`ADDR/INDEX/LOAD_AT/STORE_AT/COPY`)
   already models the low-level shapes.
4. **Structs** (`struct.X = { fields }.end`) with explicit layout control.
5. **Unions** — active-member semantics documented, unsafe by declaration.
6. **`f32`** — true 32-bit float (needs its own ABI/register path).
7. **Remaining text conversion builtins** — `number.to_text`, `text.to_number`
   (parsing/formatting in the runtime shim, then Okular).
8. **Match-style selection** on the `when` foundation (`else when` chains,
   value matching) — extends, never breaks, existing syntax.
9. **Constants** (`const`), **type inference** (`type.auto`).
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
