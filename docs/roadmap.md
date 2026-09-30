# Okular Development Roadmap

**Working document — updated as milestones complete. Nothing here is claimed
before the test suite proves it.**

## Where we are

**Okular 0.2 — milestone M2 (core data model) underway.** On top of the M1
bootstrap compiler, 0.2 adds **fixed-length arrays**: value semantics,
always-checked bounds, nested arrays, array parameters, and global arrays.
The type system now runs on interned descriptors — the foundation the
pointer, struct, and union milestones build on. See `specs/spec-v0.2.md` §22
for the honest status table.

## Milestones

| ID | Milestone | Status |
|----|-----------|--------|
| M1 | C bootstrap compiler; hello-world and small programs run natively | **done (0.1)** |
| M2 | Language covers substantial normal programs | in progress — arrays done (0.2) |
| M3 | Okular can compile portions of the compiler itself | not started |
| M4 | Compiler components rewritten in Okular (lexer first, then runtime shim) | not started |
| M5 | Okular compiler builds itself | not started |
| M6 | C bootstrap no longer required | not started |
| M7 | C bootstrap removed from repository | not started |

## M2 work items, in dependency order

1. ~~**Arrays** — fixed-length~~ **done in 0.2**: `type.array<type.number, 5>`,
   literals, indexing, indexed stores, value-copy semantics, bounds traps,
   nesting, params, globals (`specs/spec-v0.2.md` §8.4). Dynamic arrays
   wait for the heap milestone.
2. **Fixed-width integers** (`type.uint32` et al.) — the type descriptors
   now make this a codegen task (sign/zero extension discipline).
3. **Heap + pointers + manual memory** (`alloc/release`, `&x`, deref,
   pointer arithmetic, `null`) — unlocks structs-by-reference, dynamic
   arrays, FFI. The address-forming IR (`ADDR/INDEX/LOAD_AT/STORE_AT/COPY`)
   already models the low-level shapes.
4. **Structs** (`struct.X = { fields }.end`) with explicit layout control.
5. **Unions** — active-member semantics documented, unsafe by declaration.
6. **Explicit conversion builtins** — `number.to_text`, `text.to_number`.
7. **Match-style selection** on the `when` foundation (`else when` chains,
   value matching) — extends, never breaks, existing syntax.
8. **Constants** (`const`), **type inference** (`type.auto`).
9. **Standard library beginnings** — `io`, `text`, `math`, `memory` modules,
   `[libs.use]` binding real code; `oklib` format design.
10. **ARM64 backend** — second target proves the backend abstraction.
11. **Optimizer framework** — register allocation, DCE, inlining on the IR;
    constant folding already exists as the first pass.

## Deliberate non-goals

* A VM, bytecode-only mode, mandatory GC, mandatory runtime — rejected by
  design (brief §3/§27/§47).
* Macros/metaprogramming — not before the language core is stable.
* C header interop as a language foundation — C interop is a bridge feature
  gated on the FFI design (brief §25).
