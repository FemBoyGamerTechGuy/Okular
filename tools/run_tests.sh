#!/usr/bin/env bash
# tools/run_tests.sh — the Okular 0.7 test suite (brief §51).
#
# Layout: tests/cases/{positive,negative,policy,flags}/<name>/
#   main.ok (+ src/)          the project
#   flags                     extra compiler flags (optional, one line)
#   entry_name                rename main.ok to this before compiling (optional)
#   stdout.txt                expected program stdout (positive/policy)
#   exit.txt                  expected program exit code (positive/policy)
#   error.txt                 patterns that must appear in compiler stderr (negative)
#   stderr.txt                patterns that must appear in compiler stderr (policy/flags)
#   stderr_not.txt            patterns that must NOT appear in compiler stderr
#
# Every case is copied to tests/tmp/ so case directories stay pristine.

set -u
REPO="$(cd "$(dirname "$0")/.." && pwd)"
OKULAR="$REPO/build/okular"
CASES="$REPO/tests/cases"
TMP="$REPO/tests/tmp"

if [ ! -x "$OKULAR" ]; then
    echo "run_tests: compiler not built at $OKULAR — run \`make\` first." >&2
    exit 2
fi

pass=0; fail=0
failed_cases=()

check() { # check <description> <condition...>
    local desc="$1"; shift
    if "$@"; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        failed_cases+=("$desc")
        echo "  FAIL: $desc"
    fi
}

run_one() { # run_one <group> <casedir>
    local group="$1" dir="$2"
    local name="$(basename "$dir")"
    local work="$TMP/$group/$name"
    rm -rf "$work"
    mkdir -p "$work"
    cp -r "$dir/." "$work/"

    # entry rename (negative/entry_not_main)
    local entry="main.ok"
    if [ -f "$work/entry_name" ]; then
        entry="$(cat "$work/entry_name")"
        mv "$work/main.ok" "$work/$entry"
    fi

    local flags=""
    if [ -f "$work/flags" ]; then flags="$(cat "$work/flags")"; fi

    local cout cerr cexit
    cout="$TMP/$group.$name.compile.out"; cerr="$TMP/$group.$name.compile.err"
    $OKULAR --compile $flags "$work/$entry" >"$cout" 2>"$cerr"
    cexit=$?

    case "$group" in
    positive)
        check "$group/$name compiles" [ "$cexit" -eq 0 ]
        if [ "$cexit" -ne 0 ]; then
            sed 's/^/    compiler: /' "$cerr" | head -15
            return
        fi
        local out pexit
        out="$TMP/$group.$name.run.out"
        "$work/build/output/main" >"$out" 2>/dev/null
        pexit=$?
        if [ -f "$dir/stdout.txt" ]; then
            check "$group/$name stdout" diff -q "$dir/stdout.txt" "$out" >/dev/null
        fi
        if [ -f "$dir/exit.txt" ]; then
            check "$group/$name exit $(cat "$dir/exit.txt")" \
                [ "$pexit" -eq "$(cat "$dir/exit.txt")" ]
        fi
        ;;
    negative)
        check "$group/$name fails to compile" [ "$cexit" -ne 0 ]
        if [ -f "$dir/error.txt" ]; then
            while IFS= read -r pattern; do
                [ -z "$pattern" ] && continue
                check "$group/$name reports: ${pattern:0:50}" grep -qF "$pattern" "$cerr"
            done < "$dir/error.txt"
        fi
        check "$group/$name produces no executable" \
            [ ! -x "$work/build/output/main" ]
        ;;
    policy | flags)
        if [ -f "$dir/exit.txt" ]; then
            check "$group/$name exit $(cat "$dir/exit.txt")" \
                [ "$cexit" -eq "$(cat "$dir/exit.txt")" ]
        fi
        if [ "$cexit" -eq 0 ] && [ -f "$dir/stdout.txt" ]; then
            local out pexit
            out="$TMP/$group.$name.run.out"
            "$work/build/output/main" >"$out" 2>/dev/null
            pexit=$?
            check "$group/$name program stdout" diff -q "$dir/stdout.txt" "$out" >/dev/null
            [ "$pexit" -eq 0 ] || echo "  note: $group/$name program exited $pexit"
        fi
        if [ -f "$dir/stderr.txt" ]; then
            while IFS= read -r pattern; do
                [ -z "$pattern" ] && continue
                check "$group/$name stderr has: ${pattern:0:50}" grep -qF "$pattern" "$cerr"
            done < "$dir/stderr.txt"
        fi
        if [ -f "$dir/stderr_not.txt" ]; then
            while IFS= read -r pattern; do
                [ -z "$pattern" ] && continue
                check "$group/$name stderr lacks: ${pattern:0:50}" \
                    bash -c "! grep -qF '$pattern' '$cerr'"
            done < "$dir/stderr_not.txt"
        fi
        ;;
    esac
}

echo "== Okular 0.7 test suite =="

for group in positive negative policy flags; do
    echo "-- $group"
    for dir in "$CASES/$group"/*/; do
        [ -d "$dir" ] || continue
        run_one "$group" "${dir%/}"
    done
done

echo
echo "passed: $pass   failed: $fail"
if [ "$fail" -gt 0 ]; then
    echo "failing cases:"
    for c in "${failed_cases[@]}"; do echo "  - $c"; done
    exit 1
fi
echo "ALL TESTS PASSED"
