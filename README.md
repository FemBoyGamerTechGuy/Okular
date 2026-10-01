# Okular

A simple, fast programming language designed for building large
applications with minimal code.

**Status:** Okular 0.13 — milestone M4: **the parser itself is written in
Okular.** The bootstrap compiler (in C) builds and runs real Okular
programs natively on x86-64 Linux — arrays and structs with value
semantics, the full fixed-width integer family, pointers with manual
memory: `&x`, `*p`, `alloc<T>(n)` / `release(p)` over a real heap
allocator, null checks, scaled pointer arithmetic, records with
predictable layout, unions with type-directed literals (spec §8.5), the
full conversion builtin set (`number.to_text`, `text.to_number`, ...),
**bitwise operations** (`& | ^ ~ << >>` with range-checked shifts —
spec §9), and **short-circuit `and`/`or`** (spec §9 — `p != null and
*p == x` guards do not trap). Programs read their own command-line
arguments (`env.arg_count()`, `env.arg(i)` — spec §6.5).

**Self-hosting (M4):** the tokenizer (`selfhost/lexer`), the **parser**
(`selfhost/parser` — the complete grammar, in Okular), and the **runtime**
(`selfhost/runtime` — formatters, text arena, conversions, the heap
allocator, file operations, on the `sys.*` syscall floor) are all
written in Okular. `--selfhost-lex` routes tokenization through the
Okular lexer, `--selfhost-parse` routes parsing through the Okular
parser (the machine AST protocol rebuilds the tree sema consumes), and
`--selfhost-verify` differentially proves the two parsers' outputs
byte-identical across the whole positive suite — end-to-end program
output is identical through both paths. The **runtime** is written in
Okular too (`selfhost/runtime`, on the `sys.*` syscall floor — spec
§23), and the **integrated assembler has begun** (`selfhost/assembler`
emits a running native ELF64 executable from Okular with no `as` and no
`ld`). 0.13 also adds `text.from_bytes` and the
`ptr.to_number`/`number.to_ptr` address conversions.

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

when (flags & 0x8000_0000 == 0x8000_0000) {
    write("high bit set")
    print
}
write(1 << 20)
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
selfhost/     compiler components written in Okular (lexer first, M3/M4)
runtime/      the freestanding runtime shim (raw syscalls, no libc)
specs/        the language specification (versioned, honest status table)
docs/         getting started, language basics, architecture, roadmap
examples/     runnable Okular programs (HelloProject = full project)
tests/        the test suite (positive / negative / policy / flags)
tools/        run_tests.sh and future tooling
std/          standard library (planned — fs builtins bridge the gap)
build/        build artifacts
```

## Documentation

* [Getting started](docs/getting-started.md) — build, compile, run
* [Language basics](docs/language-basics.md) — a tour of Okular 0.12
* [Specification v0.12](specs/spec-v0.12.md) — the definition, with an
  implementation status table that says exactly what works
* [Architecture](docs/architecture.md) — how the bootstrap compiler is
  built and how it will self-host
* [Roadmap](docs/roadmap.md) — milestones M1–M7 and the M3 work list

## Tests

```console
$ make test
passed: 530   failed: 0
ALL TESTS PASSED
```

## The bootstrap plan

C is scaffolding. The evolution is tracked explicitly
(`docs/roadmap.md`): the bootstrap compiler (M1) → substantial programs
(M2) → compiling portions of the compiler itself (M3) → components
rewritten in Okular (M4) → self-hosting (M5) → C no longer required (M6)
→ C removed (M7). Nothing is claimed before the test suite proves it.
