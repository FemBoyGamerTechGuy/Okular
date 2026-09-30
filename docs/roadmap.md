# Okular Development Roadmap

**Working document — updated as milestones complete. Nothing here is claimed
before the test suite proves it.**

## Where we are

**Okular 0.1 — bootstrap milestone M1.** The C bootstrap compiler compiles
and runs real Okular programs on x86-64 Linux: variables, functions,
`when`/`loop` control flow, `write`/`print`, modules via `[source.files.use]`,
developer columns as namespaces, and full project builds with the
optional-source policy. See `specs/spec-v0.1.md` §22 for the honest status
table.

## Milestones

| ID | Milestone | Status |
|----|-----------|--------|
| M1 | C bootstrap compiler; hello-world and small programs run natively | **done (0.1)** |
| M2 | Language covers substantial normal programs | in progress |
| M3 | Okular can compile portions of the compiler itself | not started |
| M4 | Compiler components rewritten in Okular (lexer first, then runtime shim) | not started |
| M5 | Okular compiler builds itself | not started |
| M6 | C bootstrap no longer required | not started |
| M7 | C bootstrap removed from repository | not started |

## M2 work items (next), in dependency order

1. **Arrays** — fixed + dynamic, `type.array<number> x = [...]` shape under
   design; needs the heap milestone first for dynamic, fixed first.
2. **Heap + pointers + manual memory** (`alloc/release`, `&x`, deref,
   pointer arithmetic, `null`) — unlocks structs-by-reference, arrays, FFI.
3. **Structs** (`struct.X = { fields }.end`) with explicit layout control.
4. **Unions** — active-member semantics documented, unsafe by declaration.
5. **Explicit conversion builtins** — `number.to_text`, `text.to_number`.
6. **Match-style selection** on the `when` foundation (`else when` chains,
   value matching) — extends, never breaks, 0.1 syntax.
7. **Constants** (`const`), **type inference** (`type.auto`).
8. **Standard library beginnings** — `io`, `text`, `math`, `memory` modules,
   `[libs.use]` binding real code; `oklib` format design.
9. **ARM64 backend** — second target proves the backend abstraction.
10. **Optimizer framework** — register allocation, DCE, inlining on the IR;
    constant folding already exists as the first pass.

## Deliberate non-goals

* A VM, bytecode-only mode, mandatory GC, mandatory runtime — rejected by
  design (brief §3/§27/§47).
* Macros/metaprogramming — not before the language core is stable.
* C header interop as a language foundation — C interop is a bridge feature
  gated on the FFI design (brief §25).
