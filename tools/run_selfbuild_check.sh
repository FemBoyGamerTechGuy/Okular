#!/usr/bin/env bash
# tools/run_selfbuild_check.sh — the C-free acceptance test (M6).
#
# With only the committed native seed (bin/okular) and the Okular sources:
#   1. the seed compiles the compiler -> must reproduce the seed BYTE-IDENTICALLY
#      (deterministic self-reproduction: `make` on a clean checkout rebuilds
#      the committed binary bit-for-bit; no C compiler, no as, no ld anywhere)
#   2. the built compiler passes the full differential suite (191 cases:
#      positive programs compile and run with exactly the expected output;
#      negative programs are rejected with exactly the expected diagnostics;
#      policy cases verify the optional-source semantics)
set -u
REPO="$(cd "$(dirname "$0")/.." && pwd)"
SEED="$REPO/bin/okular"
BUILT="$REPO/build/okular"

if [ ! -x "$SEED" ]; then
    echo "selfbuild: committed seed compiler missing at $SEED" >&2
    exit 2
fi
if [ ! -x "$BUILT" ]; then
    echo "selfbuild: build/okular not built — run `make` first" >&2
    exit 2
fi

# 1. deterministic self-reproduction
REPRO="$REPO/build/selfrepro/main"
rm -rf "$REPO/build/selfrepro"
mkdir -p "$REPO/build/selfrepro"
( cd "$REPO/selfhost/compiler" && "$SEED" main.ok --out "$REPRO" ) || {
    echo "selfbuild: FAILED — the seed cannot compile the compiler" >&2
    exit 1
}
if ! cmp -s "$SEED" "$REPRO"; then
    echo "selfbuild: FAILED — seed self-reproduction is not byte-identical" >&2
    md5sum "$SEED" "$REPRO"
    exit 1
fi
echo "selfbuild: seed self-reproduction byte-identical (deterministic native rebuild, zero C)"

# 2. the differential suite through the built compiler
OKC="$BUILT" bash "$REPO/tools/run_selfhost_tests.sh" || {
    echo "selfbuild: FAILED — differential suite through build/okular" >&2
    exit 1
}

echo "SELFBUILD CHECK COMPLETE: Okular source -> Okular compiler -> native executables, no C toolchain"
