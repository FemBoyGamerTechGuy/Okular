# Test Suite

`tools/run_tests.sh` drives every case in `cases/`. Run everything with
`make test` from the repository root.

## Groups

| Group | Verifies |
|---|---|
| `positive/` | programs compile, run, and produce the exact expected stdout and exit codes — including **runtime-trap cases** (`arrays_bounds_trap`, `arrays_neg_index_trap`) whose programs die with the trap exit code 70 after printing their partial stdout |
| `negative/` | invalid programs fail with the expected error text **and no executable is produced** |
| `policy/` | the optional-source matrix (spec §2.1): broken-unused sources warn and are skipped; broken-used sources fail; `--strict` makes everything fatal |
| `flags/` | `-w` warnings fire (unused variables, unreachable code) |

## Case format

Each case is a directory containing:

| File | Meaning |
|---|---|
| `main.ok` (+ `src/`) | the project under test |
| `flags` | extra compiler flags, one line (optional) |
| `entry_name` | rename `main.ok` to this before compiling (optional; used by the entry-point test) |
| `stdout.txt` | expected program stdout, exact |
| `exit.txt` | expected program exit code |
| `error.txt` | fixed-string patterns that must appear in compiler stderr (negative) |
| `stderr.txt` | patterns that must appear in compiler stderr (policy/flags) |
| `stderr_not.txt` | patterns that must NOT appear in compiler stderr |

Cases are copied to `tests/tmp/` so the case directories stay pristine.

## Regression policy

Every fixed compiler bug gets a case here (brief §51). The debug flags
`--dump-tokens`, `--dump-ast`, `--dump-ir`, `--emit-asm` exist so tests (and
humans) can inspect every pipeline stage.
