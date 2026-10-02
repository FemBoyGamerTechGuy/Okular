#!/usr/bin/env bash
# tools/package_release.sh — build the downloadable Okular distributions.
#
# The USER path (no bootstrap, no C compiler, no as, no ld):
#   download -> unpack -> bin/okular your-project/main.ok -> run it.
#
# Two targets ship since 0.17:
#   okular-<ver>-linux-x86_64/   the compiler as a native x86-64 executable
#   okular-<ver>-linux-arm64/    the SAME compiler cross-compiled to aarch64
#                                (run it natively on ARM64 hardware, or
#                                cross-compile from any host)
#
# Layout (each):
#   bin/okular     the self-built native compiler (okc, stage 2)
#   src/rt.ok      the runtime module (compiled into every program)
#   stdlib/        the standard library
#   examples/      runnable example projects
#   docs/          getting started, language basics, architecture, roadmap
#   README.md      install and quick-start instructions
#   VERSION
#
# After packing, this script TESTS THE REAL PRODUCT: it unpacks each
# archive into a scratch directory, compiles examples/hello with the
# unpacked compiler, and runs the result. The arm64 compiler is executed
# under tools/emu64.py (the aarch64 user-mode emulator) — the same
# binary real ARM64 hardware would run — and the executable it emits is
# run natively.
set -eu
REPO="$(cd "$(dirname "$0")/.." && pwd)"
VER="$(git -C "$REPO" describe --tags --always 2>/dev/null || echo 0.14.0)"
OUTDIR="$REPO/build/release"
mkdir -p "$OUTDIR"

# the compiler: build/okular, compiled from the Okular sources by the
# committed native seed (bin/okular) — proven byte-identical to the seed by
# `make test` (deterministic self-reproduction); zero C in the chain
OKC="$REPO/build/okular"
OKC_ARM="$REPO/build/okular-arm64"
if [ ! -x "$OKC" ]; then
    echo "package_release: compiler missing at $OKC" >&2
    echo "  run: make first" >&2
    exit 2
fi
if [ ! -x "$OKC_ARM" ]; then
    echo "package_release: arm64 compiler missing at $OKC_ARM" >&2
    echo "  run: make arm64 first" >&2
    exit 2
fi

stage_common() {
    local STAGE="$1"
    rm -rf "$STAGE"
    mkdir -p "$STAGE/bin" "$STAGE/src" "$STAGE/docs" "$STAGE/stdlib"
    cp "$REPO/selfhost/compiler/src/rt.ok" "$STAGE/src/rt.ok"
    cp "$REPO"/stdlib/*.ok "$STAGE/stdlib/"
    cp -r "$REPO/examples" "$STAGE/examples"
    rm -rf "$STAGE/examples"/*/build
    for f in getting-started.md language-basics.md architecture.md roadmap.md; do
        cp "$REPO/docs/$f" "$STAGE/docs/" 2>/dev/null || true
    done
    cp "$REPO/LICENSE" "$STAGE/LICENSE"
    echo "$VER" > "$STAGE/VERSION"
}

emit_readme_x86() {
cat > "$1/README.md" << EOF
# Okular ${VER} — native compiler for the Okular language (linux-x86_64)

Okular is a native-compiled systems language: no VM, no bytecode, no C
transpilation. This archive contains the complete compiler as one native
x86-64 executable. It emits standalone ELF64 executables directly — no
\`as\`, no \`ld\`, no C toolchain needed on your machine.

## Install

    tar xzf ${NAME_X}.tar.gz
    export PATH="$(pwd)/${NAME_X}/bin:\$PATH"

Or just call \`bin/okular\` by its full path.

## Quick start

    cd ${NAME_X}/examples/hello
    ../../bin/okular main.ok
    ./build/output/main

## Targets

Compiles for the host by default; \`--target arm64\` cross-compiles the
same program to a linux-aarch64 executable (and \`--target x86-64\` is
the explicit spelling of the default).

## What you got

    bin/okular   the compiler (one native executable)
    src/rt.ok    the runtime module (compiled into every program)
    stdlib/      the standard library (math, text, io, memory) —
                 [libs.use] = { "math" }.end pulls it in
    examples/    runnable example projects
    docs/        language and architecture documentation
    LICENSE      the Okular Project License (see the license note below)

Requirements: Linux x86-64. Nothing else.

## License, in plain words

The software you build with this compiler is entirely yours: distribute,
sell, publish, or keep it proprietary — the Okular Project claims nothing
over programs compiled with Okular (the runtime linked into them is
exempt as well). The compiler and its source are licensed for study and
use, not for redistribution or forks: see LICENSE in this archive.
EOF
}

emit_readme_arm() {
cat > "$1/README.md" << EOF
# Okular ${VER} — native compiler for the Okular language (linux-arm64)

Okular is a native-compiled systems language: no VM, no bytecode, no C
transpilation. This archive contains the complete compiler as one native
aarch64 executable — the same compiler, built for ARM64 hardware.

## Install (on a linux-aarch64 machine)

    tar xzf ${NAME_A}.tar.gz
    export PATH="$(pwd)/${NAME_A}/bin:\$PATH"

Or just call \`bin/okular\` by its full path.

## Quick start

    cd ${NAME_A}/examples/hello
    ../../bin/okular main.ok --target arm64
    ./build/output/main

## Targets

The compiler selects its output architecture explicitly: \`--target
arm64\` (aarch64 executables — what you usually want on this hardware)
or \`--target x86-64\`. Cross-compiling in either direction works from
either distribution.

## What you got

    bin/okular   the compiler (one native aarch64 executable)
    src/rt.ok    the runtime module (compiled into every program)
    stdlib/      the standard library
    examples/    runnable example projects
    docs/        language and architecture documentation
    LICENSE      the Okular Project License (see the license note below)

Requirements: Linux aarch64 (ARM64). Nothing else.

## License, in plain words

The software you build with this compiler is entirely yours: distribute,
sell, publish, or keep it proprietary — the Okular Project claims nothing
over programs compiled with Okular (the runtime linked into them is
exempt as well). The compiler and its source are licensed for study and
use, not for redistribution or forks: see LICENSE in this archive.
EOF
}

NAME_X="okular-${VER}-linux-x86_64"
NAME_A="okular-${VER}-linux-arm64"

# ---- x86-64 distribution ----
STAGE_X="$OUTDIR/$NAME_X"
OUT_TGZ_X="$OUTDIR/$NAME_X.tar.gz"
stage_common "$STAGE_X"
cp "$OKC" "$STAGE_X/bin/okular"
chmod 755 "$STAGE_X/bin/okular"
emit_readme_x86 "$STAGE_X"
tar -C "$OUTDIR" -czf "$OUT_TGZ_X" "$NAME_X"
( cd "$OUTDIR" && sha256sum "$NAME_X.tar.gz" > "$NAME_X.tar.gz.sha256" )
echo "package_release: wrote $OUT_TGZ_X"

# ---- arm64 distribution ----
STAGE_A="$OUTDIR/$NAME_A"
OUT_TGZ_A="$OUTDIR/$NAME_A.tar.gz"
stage_common "$STAGE_A"
cp "$OKC_ARM" "$STAGE_A/bin/okular"
chmod 755 "$STAGE_A/bin/okular"
emit_readme_arm "$STAGE_A"
tar -C "$OUTDIR" -czf "$OUT_TGZ_A" "$NAME_A"
( cd "$OUTDIR" && sha256sum "$NAME_A.tar.gz" > "$NAME_A.tar.gz.sha256" )
echo "package_release: wrote $OUT_TGZ_A"

# ---- test the REAL product: unpack fresh, compile, run ----
TESTDIR="$REPO/build/release/verify"
rm -rf "$TESTDIR"
mkdir -p "$TESTDIR"

# x86-64: the unpacked compiler builds and runs hello natively
tar -C "$TESTDIR" -xzf "$OUT_TGZ_X"
cd "$TESTDIR/$NAME_X/examples/hello"
"$TESTDIR/$NAME_X/bin/okular" main.ok
OUT="$("./build/output/main")"
if [ "$OUT" != "Hello Okular" ]; then
    echo "package_release: PRODUCT TEST FAILED — hello printed: $OUT" >&2
    exit 1
fi
echo "package_release: product test OK — unpacked x86-64 compiler built and ran hello: $OUT"

# arm64: the unpacked aarch64 compiler (executed under tools/emu64.py,
# the same binary ARM64 hardware runs) builds hello; the executable it
# emits is run natively
tar -C "$TESTDIR" -xzf "$OUT_TGZ_A"
cd "$TESTDIR/$NAME_A/examples/hello"
rm -rf build
timeout 1800 python3 "$REPO/tools/emu64.py" "$TESTDIR/$NAME_A/bin/okular" main.ok --out ./build/output/main
OUT="$("./build/output/main")"
if [ "$OUT" != "Hello Okular" ]; then
    echo "package_release: PRODUCT TEST FAILED (arm64) — hello printed: $OUT" >&2
    exit 1
fi
echo "package_release: product test OK — unpacked arm64 compiler built and ran hello: $OUT"

echo "package_release: BOTH DISTRIBUTIONS VERIFIED"
