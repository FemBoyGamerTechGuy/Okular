# Okular

A simple, fast programming language designed for building large
applications with minimal code.

**Status:** Okular 0.5 — milestone M3 (systems types) underway. The C
bootstrap compiler builds and runs real Okular programs natively on
x86-64 Linux — arrays and structs with value semantics, the full
fixed-width integer family, and pointers with manual memory: `&x`, `*p`,
`alloc<T>(n)` / `release(p)` over a real heap allocator, null checks,
scaled pointer arithmetic, and records with predictable layout.

```ok
type.text=1

type.array<type.number, 5> scores = {10, 20, 30, 40, 50}
scores[2] = 99
write(scores[2])
print

type.int8 tiny = -100
type.uint8 mask = 0xFF
type.uint16 port = 443
type.uint32 flags = 0x8000_0000
type.uint64 huge = 18446744073709551615
write(huge)
print
```

Okular is a natively compiled, general-purpose systems language:

* **Approachable by default** — write understandable code without first
  learning pointers, allocation, or ABI details.
* **No ceiling** — the same language is designed to express kernels,
  drivers, databases, and eventually the Okular compiler itself.
* **Its own language** — its own grammar, module system, type system,
  memory model, and tooling; recognizable to C/Rust/Python programmers
  without being a clone of any of them.

Executables are freestanding: no C library, no interpreter, no VM —
Okular's own backend emits x86-64 assembly, and the output depends on
nothing but the kernel.

## Quick start

```console
$ make
$ cd examples/HelloProject
$ ../../build/okular --compile main.ok
okular: wrote ./build/output/main
$ ./build/output/main
Hello 1 Hello 2 Hello 3
okular!
```

## Repository layout

```
bootstrap/    the C bootstrap compiler (temporary scaffolding, M1–M6)
runtime/      the freestanding runtime shim (raw syscalls, no libc)
specs/        the language specification (versioned, honest status table)
docs/         getting started, language basics, architecture, roadmap
examples/     runnable Okular programs (HelloProject = full project)
tests/        the test suite (positive / negative / policy / flags)
tools/        run_tests.sh and future tooling
std/          standard library (empty in 0.5 — planned)
build/        build artifacts
```

## Documentation

* [Getting started](docs/getting-started.md) — build, compile, run
* [Language basics](docs/language-basics.md) — a tour of Okular 0.5
* [Specification v0.5](specs/spec-v0.5.md) — the definition, with an
  implementation status table that says exactly what works
* [Architecture](docs/architecture.md) — how the bootstrap compiler is
  built and how it will self-host
* [Roadmap](docs/roadmap.md) — milestones M1–M7 and the M3 work list

## Tests

```console
$ make test
passed: 343   failed: 0
ALL TESTS PASSED
```

## The bootstrap plan

C is scaffolding. The evolution is tracked explicitly
(`docs/roadmap.md`): the bootstrap compiler (M1) → substantial programs
(M2) → compiling portions of the compiler itself (M3) → components
rewritten in Okular (M4) → self-hosting (M5) → C no longer required (M6)
→ C removed (M7). Nothing is claimed before the test suite proves it.
