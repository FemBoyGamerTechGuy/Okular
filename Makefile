# Okular bootstrap build (brief §62: readable, modular, portable where possible)
CC      := cc
CFLAGS  := -std=c11 -O2 -Wall -Wextra -Wno-unused-parameter -Ibootstrap/include
RTFLAGS := -O2 -ffreestanding -nostdlib -fno-pie -fno-stack-protector \
           -fno-builtin -fno-asynchronous-unwind-tables

SRCS := $(wildcard bootstrap/src/*.c)
OBJS := $(patsubst bootstrap/src/%.c,build/bootstrap/%.o,$(SRCS))
HDRS := $(wildcard bootstrap/include/ok/*.h)

# every object depends on every header: the compiler is small and the
# headers define its ABI (types, IR, AST) — a stale object after a header
# change silently corrupts the build (found the hard way in M2)
$(OBJS): $(HDRS)

# the dependency rule above must not become the default goal (found in M3:
# bare `make` built exactly one object and stopped)
.DEFAULT_GOAL := all

.PHONY: all test clean selfhost-lex selfhost-parse selfhost-runtime selfhost-assembler

all: build/okular runtime/rt.o

# the Okular-written lexer (M4, docs/roadmap.md): the bootstrap compiler
# compiles it; --selfhost-lex then uses it as the compiler's tokenizer
selfhost/lexer/build/output/main: build/okular selfhost/lexer/main.ok selfhost/lexer/src/lexer.ok
	cd selfhost/lexer && ../../build/okular --compile main.ok

selfhost-lex: selfhost/lexer/build/output/main

# the Okular-written parser (M4, docs/roadmap.md): the bootstrap compiler
# compiles it; --selfhost-parse then uses it as the compiler's parser
selfhost/parser/build/output/main: build/okular selfhost/parser/main.ok selfhost/parser/src/toks.ok selfhost/parser/src/parser.ok
	cd selfhost/parser && ../../build/okular --compile main.ok

selfhost-parse: selfhost/parser/build/output/main

# the Okular-written runtime (M4, docs/roadmap.md): the output formatters,
# text arena, conversion builtins, heap allocator, and file operations —
# all in Okular, on the sys.* syscall floor (spec §6.6)
selfhost/runtime/build/output/main: build/okular selfhost/runtime/main.ok selfhost/runtime/src/rt.ok
	cd selfhost/runtime && ../../build/okular --compile main.ok

selfhost-runtime: selfhost/runtime/build/output/main

# the integrated assembler seed (M5): emits a native ELF64 executable
# from Okular — ELF headers, machine code, symbol fixups, chmod — with
# no `as` and no `ld` anywhere in the chain
selfhost/assembler/build/output/main: build/okular selfhost/assembler/main.ok selfhost/assembler/src/elf.ok
	cd selfhost/assembler && ../../build/okular --compile main.ok

selfhost-assembler: selfhost/assembler/build/output/main

build/okular: $(OBJS)
	@mkdir -p build/bootstrap
	$(CC) $(CFLAGS) -o $@ $(OBJS)

build/bootstrap/%.o: bootstrap/src/%.c
	@mkdir -p build/bootstrap
	$(CC) $(CFLAGS) -c -o $@ $<

# bootstrap runtime shim: freestanding C + _start trampoline, partial-linked
runtime/rt.o: runtime/rt.c runtime/rt_start.s
	$(CC) $(RTFLAGS) -c -o build/rt_code.o runtime/rt.c
	$(CC) -c -o build/rt_start.o runtime/rt_start.s
	ld -r -o runtime/rt.o build/rt_code.o build/rt_start.o

test: all selfhost-lex selfhost-parse selfhost-runtime selfhost-assembler bootstrap-chain
	bash tools/run_tests.sh

clean:
	rm -rf build/bootstrap build/okular build/rt_code.o build/rt_start.o runtime/rt.o
	rm -rf examples/*/build selfhost/*/build tests/tmp

# the Okular-written compiler (M5): the complete pipeline — project load,
# sema, IR, x86-64 emission, native ELF64 — in one Okular program
selfhost/compiler/build/output/main: build/okular selfhost/compiler/main.ok $(wildcard selfhost/compiler/src/*.ok)
	cd selfhost/compiler && ../../build/okular --compile main.ok

selfhost-compiler: selfhost/compiler/build/output/main

# the M5 acceptance test: the bootstrap chain (stage 0 -> 1 -> 2 -> 3,
# byte-identical fixed point) plus the differential suite through the
# self-built compiler — permanently in CI
bootstrap-chain: selfhost/compiler/build/output/main
	bash tools/run_bootstrap_chain.sh

.PHONY: selfhost-compiler bootstrap-chain
