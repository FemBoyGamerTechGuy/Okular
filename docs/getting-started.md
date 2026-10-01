# Getting Started with Okular

**Okular 0.14** — a natively compiled systems language. This guide takes
you from zero to a running executable.

## Requirements

* Linux on x86-64 (ARM64 is planned)
* GNU make
* Nothing else: **no C compiler, no `as`, no `ld`** — the repository
  carries its own native compiler seed (`bin/okular`), and the build is
  the Okular compiler compiling its own sources

## Build the compiler

```console
$ make
$ cd examples/hello && ../../build/okular main.ok
okular: wrote ./build/output/main
$ ./build/output/main
Hello Okular
```

The build produces:

| Path | What it is |
|---|---|
| `build/okular` | the Okular compiler, built from `selfhost/compiler` sources by the committed seed |
| `bin/okular` | the committed native seed — the same compiler at a verified self-compilation fixed point |

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
$ ../build/okular main.ok
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
$ okular [-s | --strict] [--out PATH] [--dump-ir] path/to/main.ok
```

| Flag | Meaning |
|---|---|
| `-s`, `--strict` | strict builds — failures in unused `src/` files are fatal (normally warnings, and broken unused files are skipped) |
| `--out PATH` | executable output path (default `<project>/build/output/main`) |
| `--dump-ir` | print the generated IR of every function to stderr |

## Projects with source components

```
MyProject/
├── main.ok          entry point + program body
├── src/
│   └── greeting.ok  reusable component
├── libs/            project libraries (validated in 0.2; binding is planned)
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
* `specs/spec-v0.2.md` — the specification (with an honest status table)
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
