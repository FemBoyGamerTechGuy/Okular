#!/usr/bin/env bash
# tools/run_lsp_tests.sh — the LSP protocol test suite (0.18).
#
# Drives `okular lsp` through the full protocol contract with a real
# stdio JSON-RPC client (tools/lsp_test.py): lifecycle (initialize,
# shutdown, exit codes), document sync (didOpen/didChange/didClose with
# full-text sync), diagnostics (positions in 0-based lines and UTF-16
# code units, dependency attribution, standalone files), hover
# (signatures from the checker's symbol tables), and the robustness
# clause — malformed JSON, lying Content-Length headers, binary
# garbage, unknown methods, wrong parameter shapes: every one degrades
# to a JSON-RPC error or a dropped notification, and the server keeps
# serving. python3 is a test tool, not a build dependency.
set -u
REPO="$(cd "$(dirname "$0")/.." && pwd)"
OKC="${OKC:-$REPO/build/okular}"

if [ ! -x "$OKC" ]; then
    echo "run_lsp: compiler not built at $OKC" >&2
    exit 2
fi
if [ ! -f "$REPO/tools/lsp_test.py" ]; then
    echo "run_lsp: test client missing at $REPO/tools/lsp_test.py" >&2
    exit 2
fi

OKC="$OKC" python3 "$REPO/tools/lsp_test.py"
