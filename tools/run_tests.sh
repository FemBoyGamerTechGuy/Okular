#!/usr/bin/env bash
# tools/run_tests.sh — the Okular 0.13 test suite (brief §51).
#
# Layout: tests/cases/{positive,negative,policy,flags}/<name>/
#   main.ok (+ src/)          the project
#   flags                     extra compiler flags (optional, one line)
#   entry_name                rename main.ok to this before compiling (optional)
#   args                      program arguments (optional, one line, split on spaces)
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
SELFHOST_LEX="$REPO/selfhost/lexer/build/output/main"
SELFHOST_PARSE="$REPO/selfhost/parser/build/output/main"
CASES="$REPO/tests/cases"
TMP="$REPO/tests/tmp"

if [ ! -x "$OKULAR" ]; then
    echo "run_tests: compiler not built at $OKULAR — run \`make\` first." >&2
    exit 2
fi
if [ ! -x "$SELFHOST_LEX" ]; then
    echo "run_tests: self-hosted lexer not built at $SELFHOST_LEX — run \`make selfhost-lex\` first." >&2
    exit 2
fi
if [ ! -x "$SELFHOST_PARSE" ]; then
    echo "run_tests: self-hosted parser not built at $SELFHOST_PARSE — run \`make selfhost-parse\` first." >&2
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
    flags="${flags//@selfhost@/$SELFHOST_LEX}"
    flags="${flags//@selfhostparser@/$SELFHOST_PARSE}"

    # program arguments (0.12: the env builtins) — split on spaces
    local prog_args=()
    if [ -f "$work/args" ]; then
        read -r -a prog_args < "$work/args"
    fi

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
        (cd "$work" && "$work/build/output/main" "${prog_args[@]}") >"$out" 2>/dev/null
        pexit=$?
        # a program may produce an artifact to execute (self-hosting chains:
        # the assembler emits a native binary and the suite runs it too).
        # `exec_after` names the artifact relative to the work directory.
        if [ -f "$work/exec_after" ]; then
            local after="$(cat "$work/exec_after")"
            (cd "$work" && "./$after") >>"$out" 2>/dev/null
            pexit=$?
        fi
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
            (cd "$work" && "$work/build/output/main" "${prog_args[@]}") >"$out" 2>/dev/null
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

echo "== Okular 0.13 test suite =="

for group in positive negative policy flags; do
    echo "-- $group"
    for dir in "$CASES/$group"/*/; do
        [ -d "$dir" ] || continue
        run_one "$group" "${dir%/}"
    done
done

# differential verification (M4): every positive case parses to a
# BYTE-IDENTICAL machine AST through the Okular-written parser and the C
# parser (--selfhost-verify compares the serializations)
echo "-- differential (selfhost parser vs C parser)"
diff_ok=0
diff_bad=0
for dir in "$CASES/positive"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"
    if $OKULAR --selfhost-verify "$SELFHOST_PARSE" "$dir/main.ok" >/dev/null 2>&1; then
        diff_ok=$((diff_ok + 1))
    else
        diff_bad=$((diff_bad + 1))
        echo "  FAIL: differential/$name"
    fi
done
check "differential: all positive cases identical" [ "$diff_bad" -eq 0 ]

echo
echo "passed: $pass   failed: $fail"
if [ "$fail" -gt 0 ]; then
    echo "failing cases:"
    for c in "${failed_cases[@]}"; do echo "  - $c"; done
    exit 1
fi
echo "ALL TESTS PASSED"
