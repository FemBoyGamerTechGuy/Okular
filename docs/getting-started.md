# Getting Started with Okular

**Okular 0.1** — a natively compiled systems language. This guide takes you
from zero to a running executable.

## Requirements

* Linux on x86-64 (the 0.1 bootstrap target; ARM64 is planned)
* A C compiler (`cc`), GNU `as` and `ld` (binutils) — used to build the
  bootstrap compiler and to assemble/link its output
* GNU make

## Build the compiler

```console
$ make
$ ./build/okular --version
Okular 0.1
```

The build produces:

| Path | What it is |
|---|---|
| `build/okular` | the bootstrap compiler |
| `runtime/rt.o` | the freestanding runtime shim linked into every program |

## Your first program

Okular projects are directories rooted at a `main.ok` file:

```console
$ mkdir hello && cd hello
$ cat > main.ok
type.text=1

write("Hello Okular")
print
```

Compile and run:

```console
$ ../build/okular --compile main.ok
okular: wrote ./build/output/main
$ ./build/output/main
Hello Okular
```

The executable is **freestanding**: no C library, no interpreter, raw
syscalls — check with `ldd` (it reports "not a dynamic executable") and
`nm`.

## How output works

`write(value)` appends to an output buffer; `print` flushes it as one line.
Compose lines from pieces:

```ok
type.text=1
type.number total = 42

write("The answer is ")
write(total)
print
```

`type.text=1` at the top of a file activates the text output subsystem
(write/print). It is a compile-time feature switch, not a variable.

## Compiler flags

```console
$ okular --compile [-w] [-xw] [-s] [-l] [-o PATH] path/to/main.ok
```

| Flag | Meaning |
|---|---|
| `--compile` | compile the project (required) |
| `-w`, `--warnings` | warnings: unused variables, unreachable code, implicit number→decimal widening |
| `-xw`, `--extra-warnings` | extra diagnostics (implies `-w`) |
| `-s`, `--strict` | strict builds — see below |
| `-l`, `--legacy` | legacy compatibility (no legacy syntax exists yet; the mechanism is in place) |
| `-o`, `--output PATH` | executable output path (default `build/output/<name>`) |

## Projects with source components

```
MyProject/
├── main.ok          entry point + program body
├── src/
│   └── greeting.ok  reusable component
├── libs/            project libraries (validated in 0.1; binding is planned)
├── deps/            external dependencies
└── etc/             reserved
```

```ok
# main.ok
type.text=1

[source.files.use] = {
    "greeting"
}.end

write(greeting.hello())
print
```

Source files expose their names under the module namespace
(`greeting.hello()` above). Files in `src/` that the project does **not**
use are optional: if they fail to compile, the build continues (with a
warning). In `--strict` mode any failure is fatal. If a *used* file fails,
the build always fails.

## Where to go next

* `docs/language-basics.md` — a tour of the language
* `specs/spec-v0.1.md` — the specification (with an honest status table)
* `docs/architecture.md` — how the compiler works
* `docs/roadmap.md` — what comes next (heap, pointers, structs, arrays…)
* `examples/` — runnable programs (`examples/HelloProject` shows a full
  project)

## Running the test suite

```console
$ make test
...
passed: 113   failed: 0
ALL TESTS PASSED
```
