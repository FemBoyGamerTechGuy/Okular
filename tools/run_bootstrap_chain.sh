#!/usr/bin/env bash
# tools/run_bootstrap_chain.sh — the M5 acceptance test, permanently in CI.
#
# Stage 0: cc builds the C bootstrap compiler (build/okular)
# Stage 1: the C bootstrap compiles the Okular-written compiler (okc)
# Stage 2: okc compiles ITSELF
# Stage 3: the self-built okc compiles the compiler again
#
# Acceptance: stage2 and stage3 are byte-identical (the self-compilation
# fixed point), and the self-built compiler passes the full differential
# test suite (tools/run_selfhost_tests.sh).
set -u
REPO="$(cd "$(dirname "$0")/.." && pwd)"
CDIR="$REPO/selfhost/compiler"
STAGE2="$CDIR/build/stage2/main"
CBOOT="$REPO/build/okular-c"

# Stage 0 (the C bootstrap; transitional until M7 removes it)
if [ ! -x "$CBOOT" ]; then
    (cd "$REPO" && make c-bootstrap) || exit 2
fi

# Stage 1: the C bootstrap compiles okc
rm -rf "$CDIR/build/output"
(cd "$CDIR" && "$CBOOT" --compile main.ok) || {
    echo "bootstrap chain: STAGE 1 FAILED (C bootstrap cannot compile okc)"; exit 1; }

# Stage 2: okc compiles itself
rm -rf "$CDIR/build/stage2" && mkdir -p "$CDIR/build/stage2"
(cd "$CDIR" && ./build/output/main main.ok --out build/stage2/main) || {
    echo "bootstrap chain: STAGE 2 FAILED (okc cannot compile itself)"; exit 1; }

# Stage 3: the self-built okc compiles the compiler again
rm -rf "$CDIR/build/stage3" && mkdir -p "$CDIR/build/stage3"
(cd "$CDIR" && ./build/stage2/main main.ok --out build/stage3/main) || {
    echo "bootstrap chain: STAGE 3 FAILED (self-built okc cannot recompile)"; exit 1; }

# Fixed point: stage2 == stage3
if ! cmp -s "$CDIR/build/stage2/main" "$CDIR/build/stage3/main"; then
    echo "bootstrap chain: FIXED POINT FAILED (stage2 != stage3)"
    md5sum "$CDIR/build/stage2/main" "$CDIR/build/stage3/main"
    exit 1
fi

echo "bootstrap chain: stage0 -> stage1 -> stage2 -> stage3 OK (fixed point verified)"

# The self-built compiler must pass the full differential suite
OKC="$STAGE2" bash "$REPO/tools/run_selfhost_tests.sh" || {
    echo "bootstrap chain: DIFFERENTIAL SUITE FAILED through the self-built compiler"; exit 1; }

echo "BOOTSTRAP CHAIN COMPLETE: the Okular compiler, written in Okular, compiles itself"
