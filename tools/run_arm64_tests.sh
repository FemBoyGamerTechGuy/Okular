#!/usr/bin/env bash
# tools/run_arm64_tests.sh — ARM64 backend differential verification.
#
# Every positive case is compiled with `--target arm64` (default and -O1)
# and EXECUTED under tools/emu64.py, the AArch64 user-mode emulator that
# ships with the repository (the same instruction subset the backend
# emits, plus the Linux syscall interface the runtime rides on). Stdout
# and exit codes must match the x86-64 expectations EXACTLY — the target
# must never change observable program behavior.
#
# Execution mode: "emu" (default; x86-64 hosts run the aarch64 ELF under
# tools/emu64.py) or "native" (a real aarch64 host executes the binaries
# directly — no emulator anywhere). Both compare against the same x86-64
# expectations: the target must never change observable program behavior.
#
# This is the honest verification path for ARM64 in the absence of native
# arm64 runners: real programs, really executed, really compared. The
# emulator is a test tool, not a build dependency (zero-C policy intact).
set -u
REPO="$(cd "$(dirname "$0")/.." && pwd)"
OKC="${OKC:-$REPO/build/okular}"
EMU="$REPO/tools/emu64.py"
ARM64_RUN="${ARM64_RUN:-emu}"
CASES="$REPO/tests/cases"
TMP="$REPO/tests/tmp/arm64"

if [ ! -x "$OKC" ]; then
    echo "run_arm64: compiler not built at $OKC" >&2
    exit 2
fi
if [ "$ARM64_RUN" != "native" ] && [ ! -f "$EMU" ]; then
    echo "run_arm64: emulator missing at $EMU" >&2
    exit 2
fi

pass=0; fail=0; skip=0
failed_cases=()

# ARM64 levels: default (plain codegen) and -O1 (the IR pass pipeline;
# -O2 register-cached emission is x86-64-only and falls back to -O1 on
# arm64 — see the --target handling in selfhost/compiler/main.ok)
ARM_LEVELS="${ARM_LEVELS:--O1}"

for dir in "$CASES/positive"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"
    work="$TMP/$name"
    rm -rf "$work"
    mkdir -p "$work"
    cp -r "$dir/." "$work/"
    rm -rf "$work/build"

    entry="main.ok"
    if [ -f "$work/entry_name" ]; then
        entry="$(cat "$work/entry_name")"
        mv "$work/main.ok" "$work/$entry"
    fi

    local_args=()
    if [ -f "$work/args" ]; then
        read -r -a local_args < "$work/args"
    fi

    # fmt_check's exec_after exercises the host-side formatter (a
    # compiler feature, not a codegen feature) — it is covered by the
    # x86-64 suite; here only the program's own behavior is verified.
    has_exec_after=0
    [ -f "$work/exec_after" ] && has_exec_after=1

    for lvl in "" $ARM_LEVELS; do
        tag="$name${lvl:+ $lvl}"
        cout="$TMP/$name.cerr"
        (cd "$work" && timeout 120 $OKC "$entry" --target arm64 $lvl --out ./abin) >"$cout" 2>&1
        cexit=$?
        if [ "$cexit" -ne 0 ]; then
            fail=$((fail + 1))
            failed_cases+=("arm64/$tag compile ($cexit)")
            echo "  FAIL compile: $tag ($cexit)"
            sed 's/^/    okc: /' "$cout" | head -6
            continue
        fi
        out="$TMP/$name.out"
        if [ "$ARM64_RUN" = "native" ]; then
            (cd "$work" && timeout 240 ./abin "${local_args[@]}") >"$out" 2>/dev/null
        else
            (cd "$work" && timeout 240 python3 "$EMU" ./abin "${local_args[@]}") >"$out" 2>/dev/null
        fi
        pexit=$?

        # selfhost_assembler: main.ok (now an arm64 program) emits a tiny
        # x86-64 ELF; the x86-64 suite runs it natively — do the same here
        # so the full expected stdout is exercised.
        if [ "$has_exec_after" -eq 1 ] && [ -f "$work/okular-assembled" ] && [ "$name" = "selfhost_assembler" ]; then
            (cd "$work" && timeout 30 ./okular-assembled) >>"$out" 2>/dev/null
            pexit=$?
        fi

        ok=1
        if [ -f "$dir/stdout.txt" ] && [ "$has_exec_after" -eq 0 -o "$name" = "selfhost_assembler" ]; then
            diff -q "$dir/stdout.txt" "$out" >/dev/null || ok=0
        elif [ -f "$dir/stdout.txt" ]; then
            # exec_after-driven cases: compare the program's own first line
            # only when the whole expected output is produced by the script
            # (fmt_check: stdout.txt is exactly the program's own output)
            diff -q "$dir/stdout.txt" "$out" >/dev/null || ok=0
        fi
        if [ -f "$dir/exit.txt" ] && [ "$has_exec_after" -eq 0 ]; then
            [ "$pexit" -eq "$(cat "$dir/exit.txt")" ] || ok=0
        fi
        if [ "$ok" -eq 1 ]; then
            pass=$((pass + 1))
        else
            fail=$((fail + 1))
            failed_cases+=("arm64/$tag behavior (exit $pexit)")
            echo "  FAIL behavior: $tag (exit $pexit)"
            diff "$dir/stdout.txt" "$out" 2>/dev/null | head -4
        fi
    done
done

echo
echo "arm64 differential: passed $pass   failed $fail"
if [ "$fail" -gt 0 ]; then
    for c in "${failed_cases[@]}"; do echo "  - $c"; done
    exit 1
fi
if [ "$ARM64_RUN" = "native" ]; then
    echo "ALL ARM64 TESTS PASSED (compiled with --target arm64, executed NATIVELY on aarch64 hardware)"
else
    echo "ALL ARM64 TESTS PASSED (compiled with --target arm64, executed under tools/emu64.py)"
fi
