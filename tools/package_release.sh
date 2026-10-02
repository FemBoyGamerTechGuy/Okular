#!/usr/bin/env bash
# tools/package_release.sh — build the downloadable Okular distribution.
#
# The USER path (no bootstrap, no C compiler, no as, no ld):
#   download -> unpack -> bin/okular your-project/main.ok -> run it.
#
# Layout:
#   okular-<ver>-linux-x86_64/
#     bin/okular     the self-built native compiler (okc, stage 2)
#     src/rt.ok      the runtime module (compiled into every program;
#                    located via the compiler's ../src/rt.ok lookup)
#     examples/      runnable example projects
#     docs/          getting started, language basics, architecture, roadmap
#     README.md      install and quick-start instructions
#     VERSION
#
# After packing, this script TESTS THE REAL PRODUCT: it unpacks the
# archive into a scratch directory and compiles + runs examples/hello.
set -eu
REPO="$(cd "$(dirname "$0")/.." && pwd)"
VER="$(git -C "$REPO" describe --tags --always 2>/dev/null || echo 0.14.0)"
NAME="okular-${VER}-linux-x86_64"
STAGE="$REPO/build/release/$NAME"
OUT_TGZ="$REPO/build/release/$NAME.tar.gz"

# the compiler: build/okular, compiled from the Okular sources by the
# committed native seed (bin/okular) — proven byte-identical to the seed by
# `make test` (deterministic self-reproduction); zero C in the chain
OKC="$REPO/build/okular"
if [ ! -x "$OKC" ]; then
    echo "package_release: compiler missing at $OKC" >&2
    echo "  run: make first" >&2
    exit 2
fi

rm -rf "$STAGE" "$OUT_TGZ"
mkdir -p "$STAGE/bin" "$STAGE/src" "$STAGE/docs"

cp "$OKC" "$STAGE/bin/okular"
chmod 755 "$STAGE/bin/okular"

cp "$REPO/selfhost/compiler/src/rt.ok" "$STAGE/src/rt.ok"

# the standard library: [libs.use] resolves against stdlib/ next to bin/
mkdir -p "$STAGE/stdlib"
cp "$REPO"/stdlib/*.ok "$STAGE/stdlib/"

cp -r "$REPO/examples" "$STAGE/examples"
rm -rf "$STAGE/examples"/*/build

for f in getting-started.md language-basics.md architecture.md roadmap.md; do
    cp "$REPO/docs/$f" "$STAGE/docs/" 2>/dev/null || true
done

cp "$REPO/LICENSE" "$STAGE/LICENSE"

cat > "$STAGE/README.md" << EOF
# Okular ${VER} — native compiler for the Okular language (linux-x86_64)

Okular is a native-compiled systems language: no VM, no bytecode, no C
transpilation. This archive contains the complete compiler as one native
x86-64 executable. It emits standalone ELF64 executables directly — no
\`as\`, no \`ld\`, no C toolchain needed on your machine.

## Install

    tar xzf ${NAME}.tar.gz
    export PATH="$(pwd)/${NAME}/bin:\$PATH"

Or just call \`bin/okular\` by its full path.

## Quick start

    cd ${NAME}/examples/hello
    ../../bin/okular main.ok
    ./build/output/main

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

echo "$VER" > "$STAGE/VERSION"

mkdir -p "$(dirname "$OUT_TGZ")"
tar -C "$(dirname "$STAGE")" -czf "$OUT_TGZ" "$NAME"

( cd "$(dirname "$OUT_TGZ")" && sha256sum "$NAME.tar.gz" > "$NAME.tar.gz.sha256" )

echo "package_release: wrote $OUT_TGZ"

# ---- test the REAL product: unpack fresh, compile, run ----
TESTDIR="$REPO/build/release/verify"
rm -rf "$TESTDIR"
mkdir -p "$TESTDIR"
tar -C "$TESTDIR" -xzf "$OUT_TGZ"

cd "$TESTDIR/$NAME/examples/hello"
"$TESTDIR/$NAME/bin/okular" main.ok
OUT="$("./build/output/main")"
if [ "$OUT" != "Hello Okular" ]; then
    echo "package_release: PRODUCT TEST FAILED — hello printed: $OUT" >&2
    exit 1
fi
echo "package_release: product test OK — unpacked compiler built and ran hello: $OUT"
