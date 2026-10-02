# Okular build — the normal architecture (M7): Okular source -> Okular
# compiler -> native executables. No C compiler, no `as`, no `ld` anywhere.
#
#   make              build/okular — the compiler, compiled from
#                     selfhost/compiler sources by bin/okular (the committed
#                     native seed). Deterministic: the output is byte-identical
#                     to the seed when the sources match it.
#   make test         the acceptance gate: the seed must reproduce itself
#                     byte-for-bit, and the compiler must pass the full
#                     differential suite (positive / negative / policy;
#                     every positive case is also re-verified at -O1 and
#                     -O2 — optimization must not change behavior).
#   make release      package + end-to-end test the downloadable compiler.
#   make update-seed  after editing compiler sources: rebuild to the new fixed
#                     point, verify, and install it as bin/okular.
#
# bin/okular is the only bootstrap artifact: a self-built native compiler
# committed to the repository. Every compiler change ships together with an
# updated seed at a verified fixed point (see tools/update_seed.sh).

.DEFAULT_GOAL := all

.PHONY: all test clean release selfhost-compiler update-seed \
        selfhost-lex selfhost-parse selfhost-runtime selfhost-assembler

OKC_SRCS := selfhost/compiler/main.ok $(wildcard selfhost/compiler/src/*.ok)

build/okular: bin/okular $(OKC_SRCS)
	mkdir -p build
	cd selfhost/compiler && ../../bin/okular main.ok --out ../../build/okular

all: build/okular

test: all
	bash tools/run_selfbuild_check.sh

release: all
	bash tools/package_release.sh

update-seed:
	bash tools/update_seed.sh

# ---- the standalone selfhost components (M3/M4/M5 lineage: the lexer,
# parser, runtime, and assembler that once bootstrapped the compiler —
# now ordinary Okular programs, compiled by the Okular compiler) ----

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

clean:
	rm -rf build
	rm -rf examples/*/build selfhost/*/build tests/tmp
