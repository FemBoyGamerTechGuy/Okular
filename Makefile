# Okular build (M6: the normal path needs NO C compiler, NO as, NO ld)
#
#   make            build/okular  — the Okular compiler, compiled from
#                   selfhost/compiler sources by bin/okular (the committed
#                   native seed). Pure Okular -> native x86-64.
#   make test       the C-free acceptance: the seed must reproduce itself
#                   byte-identically from source, and the compiler must
#                   pass the full differential suite.
#   make release    package + end-to-end test the downloadable compiler.
#
# Transitional (until M7 removes the C bootstrap entirely):
#   make c-bootstrap  build/okular-c — the C bootstrap compiler (needs cc/as/ld)
#   make test-c       the legacy 560-check suite through the C compiler,
#                     including the C-vs-Okular parser differential
#   make bootstrap-chain  the M5 chain: stage 0 (cc) -> 1 -> 2 -> 3

.DEFAULT_GOAL := all

.PHONY: all test test-c clean release selfhost-compiler bootstrap-chain \
        c-bootstrap selfhost-lex selfhost-parse selfhost-runtime selfhost-assembler

# ---- the normal (C-free) path ----

OKC_SRCS := selfhost/compiler/main.ok $(wildcard selfhost/compiler/src/*.ok)

build/okular: bin/okular $(OKC_SRCS)
	mkdir -p build
	cd selfhost/compiler && ../../bin/okular main.ok --out ../../build/okular

all: build/okular

# bin/okular is the committed self-built compiler (stage 2 of the chain).
# Building the compiler from source with it must reproduce it exactly.
test: all
	bash tools/run_selfbuild_check.sh

release: all
	bash tools/package_release.sh

# ---- the standalone selfhost components (M3/M4/M5 lineage) — all
# compiled by the Okular compiler now ----

selfhost/lexer/build/output/main: build/okular selfhost/lexer/main.ok selfhost/lexer/src/lexer.ok
	cd selfhost/lexer && ../../build/okular main.ok

selfhost-lex: selfhost/lexer/build/output/main

selfhost/parser/build/output/main: build/okular selfhost/parser/main.ok selfhost/parser/src/toks.ok selfhost/parser/src/parser.ok
	cd selfhost/parser && ../../build/okular main.ok

selfhost-parse: selfhost/parser/build/output/main

selfhost/runtime/build/output/main: build/okular selfhost/runtime/main.ok selfhost/runtime/src/rt.ok
	cd selfhost/runtime && ../../build/okular main.ok

selfhost-runtime: selfhost/runtime/build/output/main

selfhost/assembler/build/output/main: build/okular selfhost/assembler/main.ok selfhost/assembler/src/elf.ok
	cd selfhost/assembler && ../../build/okular main.ok

selfhost-assembler: selfhost/assembler/build/output/main

selfhost-compiler: build/okular

# ---- the M5 acceptance chain (C-based, transitional) ----

bootstrap-chain: build/okular
	bash tools/run_bootstrap_chain.sh

# ---- the C bootstrap (transitional until M7) ----

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

build/okular-c: $(OBJS)
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

c-bootstrap: build/okular-c runtime/rt.o

test-c: c-bootstrap selfhost-lex selfhost-parse selfhost-runtime selfhost-assembler
	OKC_BOOTSTRAP=$(CURDIR)/build/okular-c bash tools/run_tests.sh

clean:
	rm -rf build
	rm -rf examples/*/build selfhost/*/build tests/tmp
