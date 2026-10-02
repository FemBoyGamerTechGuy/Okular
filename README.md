# Okular

A simple, fast programming language designed for building large
applications with minimal code.

**Status:** Okular 0.15 — milestones M5, M6, and M7 are **done**:
**the compiler is written in Okular and compiles itself.** One native
executable (`selfhost/compiler`, ~14k lines of Okular) contains the
complete pipeline — tokenizer, parser, semantic analysis, IR with
constant folding, x86-64 code generation, and native ELF64 emission.
`make` builds it with the committed native seed (`bin/okular`):
**no C compiler, no `as`, no `ld`** anywhere in the repository, and the
build is proven deterministic (the seed reproduces itself byte-for-bit
from source). The C bootstrap compiler has been **removed from the
repository** (M7) after the full differential suite proved the
Okular-written compiler equivalent on every test case.

The language covers real systems programming on x86-64 Linux: arrays
and structs with value semantics, the full fixed-width integer family,
pointers with manual memory (`&x`, `*p`, `alloc<T>(n)` /
`release(p)` over a real heap allocator, null checks, scaled pointer
arithmetic), records with predictable layout, unions with
type-directed literals, the full conversion builtin set, **bitwise
operations** with range-checked shifts, **short-circuit `and`/`or`**,
**match-style `when`** (ranges, guards, `else`, exhaustiveness — spec
§10.1), **`f32`** — a true 32-bit IEEE float (spec §4.2), a **standard
library** (`[libs.use]` binding `math`/`text`/`io`/`memory` — spec §6.3),
and the raw syscall floor (`sys.*` — write/read/open/close/size/
mmap/exit/chmod/mkdir/getdents) that the runtime itself rides on.

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

# match-style when: one keyword, two readings (0.15)
when (scores[2]) {
    90 to 100 { write("grade A") print }
    0 to 89   { write("grade B") print }
    else      { write("impossible") print }
}
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
Okular's own backend emits x86-64 machine code directly into a native
ELF image, and the output depends on nothing but the kernel.

### Optimizing

```
$ ./build/okular main.ok -O2          # dead-code elimination, peephole,
                                      # control-flow simplification, and
                                      # register-cached code generation
```

`-O1` runs the IR pass pipeline; `-O2` additionally keeps the operand
stack's top values in registers instead of round-tripping through
memory. Measured: fib(30) runs ~24% faster, binaries ~6% smaller.
Optimization is semantics-preserving by contract — every test case in
the repository is verified to behave identically at `-O0`, `-O1`, and
`-O2`, and the compiler itself compiles under `-O2` and passes the
whole suite that way.

## Quick start

```console
$ make                        # the seed compiles the compiler — zero C
$ cd examples/HelloProject
$ ../../build/okular main.ok
okular: wrote ./build/output/main
$ ./build/output/main
Hello 1 Hello 2 Hello 3
okular!
```

## Repository layout

```
bin/          okular — the committed native seed compiler (self-built,
              byte-reproducible from selfhost/compiler sources)
selfhost/     the compiler written in Okular (toks, parser, sema, ir,
              emit, elf, rt, and the M3/M4 component lineage)
specs/        the language specification (versioned, honest status table)
stdlib/       the standard library (math, text, io, memory)
docs/         getting started, language basics, architecture, roadmap
examples/     runnable Okular programs (HelloProject = full project)
tests/        the test suite (positive / negative / policy)
tools/        run_selfbuild_check.sh, run_selfhost_tests.sh,
              update_seed.sh, package_release.sh
build/        build artifacts
```

## Documentation

* [Getting started](docs/getting-started.md) — build, compile, run
* [Language basics](docs/language-basics.md) — a tour of Okular 0.12
* [Specification v0.16](specs/spec-v0.16.md) — the definition, with an
  implementation status table that says exactly what works
* [Architecture](docs/architecture.md) — how the bootstrap compiler is
  built and how it will self-host
* [Roadmap](docs/roadmap.md) — milestones M1–M7 and the M3 work list

## Tests

```console
$ make test
selfbuild: seed self-reproduction byte-identical ...
selfhost differential: passed 233   failed 0
ALL SELFHOST TESTS PASSED
```

## Formatting

`okular fmt` is the official formatter — token-based, comment-preserving,
and semantics-preserving by construction (it never changes the token
sequence or the statement boundaries):

```console
$ bin/okular fmt main.ok           # format in place
$ bin/okular fmt --check main.ok   # CI: exit 1 when not formatted
```

The whole repository (compiler, stdlib, examples) is formatted with it.

## License

Okular is **source-available** under the [Okular Project License](LICENSE).
In plain words:

* **Study and use freely** — read all the source, run the compiler,
  build anything with it, including commercial software.
* **Software you build is yours** — programs you write and compile with
  Okular are entirely unrestricted: distribute, sell, publish, open-source,
  or keep them proprietary. The runtime the compiler links into your
  programs is exempt as well, so this is true in practice, not just on
  paper.
* **The project itself is not for re-publishing** — no redistributing the
  compiler/source as your own distribution, no forks.

## The self-hosting arc

The evolution is complete and tracked in `docs/roadmap.md`: bootstrap
compiler (M1) → substantial programs (M2) → compiling portions of the
compiler itself (M3) → components rewritten in Okular (M4) →
self-hosting (M5) → C no longer required (M6) → **C removed (M7 —
done)**. The compiler's own changes flow through
`make update-seed`: build to a new verified self-compilation fixed
point, run the suite, install the new seed. Nothing is claimed before
the test suite proves it.
