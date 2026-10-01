#!/usr/bin/env bash
# tools/update_seed.sh — install a new bootstrap seed after compiler changes.
#
# The committed seed (bin/okular) and the compiler sources must always ship
# together at a verified self-compilation fixed point. This script:
#   1. old seed compiles the new sources   -> build/seedA
#   2. seedA compiles the sources          -> build/seedB
#   3. seedB compiles the sources          -> build/seedC
#   4. verifies seedB == seedC (the fixed point: seedB is self-reproducing)
#   5. runs the full differential suite through seedB
#   6. installs seedB as bin/okular
#
# If step 1 fails, the new sources use a language feature the old seed does
# not support yet. Bridge it manually: temporarily stub the new-feature use,
# build once, restore the sources, and re-run this script (the M7 getdents
# transition did exactly this).
set -eu
REPO="$(cd "$(dirname "$0")/.." && pwd)"
SEED="$REPO/bin/okular"
CDIR="$REPO/selfhost/compiler"

[ -x "$SEED" ] || { echo "update-seed: $SEED missing"; exit 2; }

rm -rf "$REPO/build/seedA" "$REPO/build/seedB" "$REPO/build/seedC"
mkdir -p "$REPO/build"

echo "update-seed: 1/3 old seed compiles the new sources"
( cd "$CDIR" && "$SEED" main.ok --out "$REPO/build/seedA" ) \
    || { echo "update-seed: the old seed cannot compile the new sources — see the header comment for the manual bridge"; exit 1; }

echo "update-seed: 2/3 first self-build"
( cd "$CDIR" && "$REPO/build/seedA" main.ok --out "$REPO/build/seedB" )

echo "update-seed: 3/3 fixed-point verification"
( cd "$CDIR" && "$REPO/build/seedB" main.ok --out "$REPO/build/seedC" )
cmp "$REPO/build/seedB" "$REPO/build/seedC" \
    || { echo "update-seed: NOT a fixed point (seedB != seedC) — investigate before installing"; exit 1; }

echo "update-seed: fixed point verified; running the differential suite"
OKC="$REPO/build/seedB" bash "$REPO/tools/run_selfhost_tests.sh"

cp "$REPO/build/seedB" "$SEED"
chmod 755 "$SEED"
echo "update-seed: installed $SEED (self-reproducing, suite green)"
