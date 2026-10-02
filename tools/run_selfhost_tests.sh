#!/usr/bin/env bash
# tools/run_selfhost_tests.sh — differential verification of the Okular-
# written compiler (M5): every positive case compiles through okc (the
# Okular compiler) and must produce EXACTLY the expected stdout and exit
# code; every negative case must fail to compile with the same messages.
set -u
REPO="$(cd "$(dirname "$0")/.." && pwd)"
OKC="${OKC:-$REPO/selfhost/compiler/build/output/main}"
CASES="$REPO/tests/cases"
TMP="$REPO/tests/tmp/selfhost"

if [ ! -x "$OKC" ]; then
    echo "run_selfhost: Okular compiler not built at $OKC" >&2
    exit 2
fi

pass=0; fail=0
failed_cases=()

# The optimizer differential (0.16): every positive case must behave
# IDENTICALLY when compiled with -O1 and -O2 — optimization must never
# change observable program behavior.
OPT_LEVELS="${OPT_LEVELS:--O1 -O2}"

for dir in "$CASES/positive"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"
    work="$TMP/$name"
    rm -rf "$work"
    mkdir -p "$work"
    cp -r "$dir/." "$work/"
    entry="main.ok"
    if [ -f "$work/entry_name" ]; then
        entry="$(cat "$work/entry_name")"
        mv "$work/main.ok" "$work/$entry"
    fi

    local_args=()
    if [ -f "$work/args" ]; then
        read -r -a local_args < "$work/args"
    fi

    cout="$TMP/$name.cerr"
    $OKC "$work/$entry" >"$cout" 2>&1
    cexit=$?
    if [ "$cexit" -ne 0 ]; then
        fail=$((fail + 1))
        failed_cases+=("positive/$name compile ($cexit)")
        echo "  FAIL compile: $name"
        sed 's/^/    okc: /' "$cout" | head -6
        continue
    fi
    out="$TMP/$name.out"
    (cd "$work" && "$work/build/output/main" "${local_args[@]}") >"$out" 2>/dev/null
    pexit=$?
    if [ -f "$work/exec_after" ]; then
        after="$(cat "$work/exec_after")"
        (cd "$work" && "./$after") >>"$out" 2>/dev/null
        pexit=$?
    fi
    ok=1
    if [ -f "$dir/stdout.txt" ]; then
        diff -q "$dir/stdout.txt" "$out" >/dev/null || ok=0
    fi
    if [ -f "$dir/exit.txt" ]; then
        [ "$pexit" -eq "$(cat "$dir/exit.txt")" ] || ok=0
    fi
    if [ "$ok" -eq 1 ]; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        failed_cases+=("positive/$name behavior")
        echo "  FAIL behavior: $name (exit $pexit)"
        diff "$dir/stdout.txt" "$out" 2>/dev/null | head -4
        continue
    fi

    # optimized re-compiles of the same case
    for lvl in $OPT_LEVELS; do
        (cd "$work" && timeout 60 $OKC "$entry" $lvl --out ./main_bin) >"$cout" 2>&1
        cexit=$?
        if [ "$cexit" -ne 0 ]; then
            fail=$((fail + 1))
            failed_cases+=("positive/$name $lvl compile ($cexit)")
            echo "  FAIL compile $lvl: $name ($cexit)"
            sed 's/^/    okc: /' "$cout" | head -6
            continue
        fi
        out2="$TMP/$name.$lvl.out"
        (cd "$work" && timeout 30 ./main_bin "${local_args[@]}") >"$out2" 2>/dev/null
        pexit2=$?
        if [ -f "$work/exec_after" ]; then
            after="$(cat "$work/exec_after")"
            (cd "$work" && timeout 30 "./$after") >>"$out2" 2>/dev/null
            pexit2=$?
        fi
        ok2=1
        if [ -f "$dir/stdout.txt" ]; then
            diff -q "$dir/stdout.txt" "$out2" >/dev/null || ok2=0
        fi
        if [ -f "$dir/exit.txt" ]; then
            [ "$pexit2" -eq "$(cat "$dir/exit.txt")" ] || ok2=0
        fi
        if [ "$ok2" -eq 1 ]; then
            pass=$((pass + 1))
        else
            fail=$((fail + 1))
            failed_cases+=("positive/$name $lvl behavior")
            echo "  FAIL behavior $lvl: $name (exit $pexit2)"
            diff "$dir/stdout.txt" "$out2" 2>/dev/null | head -4
        fi
    done
done

# negative cases: must fail with the same diagnostics
for dir in "$CASES/negative"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"
    work="$TMP/neg_$name"
    rm -rf "$work"
    mkdir -p "$work"
    cp -r "$dir/." "$work/"
    neg_entry="main.ok"
    if [ -f "$work/entry_name" ]; then
        neg_entry="$(cat "$work/entry_name")"
        mv "$work/main.ok" "$work/$neg_entry"
    fi
    cerr="$TMP/neg_$name.cerr"
    $OKC "$work/$neg_entry" >"$cerr" 2>&1
    cexit=$?
    ok=1
    [ "$cexit" -ne 0 ] || ok=0
    if [ -f "$dir/error.txt" ]; then
        while IFS= read -r pattern; do
            [ -z "$pattern" ] && continue
            grep -qF "$pattern" "$cerr" || ok=0
        done < "$dir/error.txt"
    fi
    if [ "$ok" -eq 1 ]; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        failed_cases+=("negative/$name")
        echo "  FAIL negative: $name (exit $cexit)"
        head -5 "$cerr" | sed 's/^/    /'
    fi
done

# policy cases: optional-source semantics (spec §36) — compile must match
# exit.txt, stdout must match, stderr patterns must (not) appear
for dir in "$CASES/policy"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"
    work="$TMP/pol_$name"
    rm -rf "$work"
    mkdir -p "$work"
    cp -r "$dir/." "$work/"
    pflags=""
    if [ -f "$work/flags" ]; then pflags="$(cat "$work/flags")"; fi
    perr="$TMP/pol_$name.cerr"
    $OKC "$work/main.ok" $pflags >"$perr" 2>&1
    cexit=$?
    ok=1
    if [ -f "$dir/exit.txt" ]; then
        [ "$cexit" -eq "$(cat "$dir/exit.txt")" ] || ok=0
    fi
    if [ "$cexit" -eq 0 ] && [ -f "$dir/stdout.txt" ]; then
        (cd "$work" && "$work/build/output/main") >"$TMP/pol_$name.out" 2>/dev/null
        diff -q "$dir/stdout.txt" "$TMP/pol_$name.out" >/dev/null || ok=0
    fi
    if [ -f "$dir/stderr.txt" ]; then
        while IFS= read -r pattern; do
            [ -z "$pattern" ] && continue
            grep -qF "$pattern" "$perr" || ok=0
        done < "$dir/stderr.txt"
    fi
    if [ -f "$dir/stderr_not.txt" ]; then
        while IFS= read -r pattern; do
            [ -z "$pattern" ] && continue
            grep -qF "$pattern" "$perr" && ok=0
        done < "$dir/stderr_not.txt"
    fi
    if [ "$ok" -eq 1 ]; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        failed_cases+=("policy/$name (exit $cexit)")
        echo "  FAIL policy: $name (exit $cexit)"
        head -4 "$perr" | sed 's/^/    /'
    fi
done

echo
echo "selfhost differential: passed $pass   failed $fail"
if [ "$fail" -gt 0 ]; then
    for c in "${failed_cases[@]}"; do echo "  - $c"; done
    exit 1
fi
echo "ALL SELFHOST TESTS PASSED"
