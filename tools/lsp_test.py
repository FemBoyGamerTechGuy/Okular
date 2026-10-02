#!/usr/bin/env python3
"""lsp_test.py — the Okular LSP server protocol test client.

Spawns `okular lsp` and drives it through the full protocol contract:
lifecycle, document sync, diagnostics, hover — and the robustness
clause (malformed anything must degrade to a JSON-RPC error or a
dropped notification, never a crash; the server keeps serving).

Exit status: 0 = all tests passed, 1 = failures (listed on stdout).
"""
import json
import os
import subprocess
import sys
import time

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OKC = os.environ.get("OKC", os.path.join(REPO, "build", "okular"))

PASS = 0
FAIL = 0
FAILURES = []


def check(name, cond, detail=""):
    global PASS, FAIL
    if cond:
        PASS += 1
        print("  ok: " + name)
    else:
        FAIL += 1
        FAILURES.append(name + ((" — " + detail) if detail else ""))
        print("  FAIL: " + name + ((" — " + detail) if detail else ""))


class Server:
    def __init__(self):
        self.proc = subprocess.Popen(
            [OKC, "lsp"], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)

    def send(self, msg):
        body = json.dumps(msg).encode()
        self.proc.stdin.write(b"Content-Length: %d\r\n\r\n" % len(body) + body)
        self.proc.stdin.flush()

    def send_raw(self, raw):
        self.proc.stdin.write(raw)
        self.proc.stdin.flush()

    def recv(self, timeout=60.0):
        """Read one framed message; None on timeout/EOF."""
        deadline = time.time() + timeout
        # headers
        clen = None
        while True:
            if time.time() > deadline:
                return None
            line = self.proc.stdout.readline()
            if not line:
                return None
            if line in (b"\r\n", b"\n"):
                break
            k, _, v = line.partition(b":")
            if k.strip().lower() == b"content-length":
                clen = int(v.strip())
        if clen is None:
            return None
        body = b""
        while len(body) < clen:
            if time.time() > deadline:
                return None
            chunk = self.proc.stdout.read(clen - len(body))
            if not chunk:
                return None
            body += chunk
        return json.loads(body)

    def recv_until(self, pred, timeout=30.0):
        """Read messages until pred(msg) matches.

        publishDiagnostics arrives as ONE NOTIFICATION PER FILE, so a
        single document change can emit several; responses to requests
        queue behind them. Skipping interim messages (each still
        validated as protocol-shaped) is the correct client behavior.
        """
        deadline = time.time() + timeout
        skipped = []
        while time.time() < deadline:
            m = self.recv(timeout=max(0.1, deadline - time.time()))
            if m is None:
                break
            if pred(m):
                return m, skipped
            skipped.append(m)
        return None, skipped

    def wait(self, timeout=15.0):
        try:
            return self.proc.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            return None

    def close_stdin(self):
        try:
            self.proc.stdin.close()
        except Exception:
            pass


def uri(path):
    return "file://" + path


def main():
    tmp = os.path.join(REPO, "tests", "tmp", "lsp")
    os.makedirs(os.path.join(tmp, "proj", "src"), exist_ok=True)
    os.makedirs(os.path.join(tmp, "single"), exist_ok=True)
    main_path = os.path.join(tmp, "proj", "main.ok")
    dep_path = os.path.join(tmp, "proj", "src", "dep.ok")
    single_path = os.path.join(tmp, "single", "thing.ok")

    broken = "type.text=1\n\nwrite(broken\nprint\n"
    fixed = "type.text=1\n\nwrite(\"fixed\")\nprint\n"
    hover_doc = (
        "type.text=1\n"
        "\n"
        "function.greet(text.name) -> text {\n"
        "    return \"hello \" + name\n"
        "}\n"
        "\n"
        "write(greet(\"world\"))\n"
        "print\n"
    )

    # ---------------- lifecycle ----------------
    print("lifecycle")
    s = Server()

    # request before initialize -> -32002
    s.send({"jsonrpc": "2.0", "id": 0, "method": "textDocument/hover", "params": {}})
    r = s.recv()
    check("request before initialize is refused with -32002",
          r is not None and r.get("error", {}).get("code") == -32002, str(r))

    # notification before initialize is dropped (no response): follow
    # with the real initialize and verify only that arrives
    s.send({"jsonrpc": "2.0", "method": "textDocument/didOpen", "params": {}})
    s.send({"jsonrpc": "2.0", "id": 1, "method": "initialize",
            "params": {"processId": os.getpid(), "capabilities": {}}})
    r = s.recv()
    caps = (r or {}).get("result", {}).get("capabilities", {})
    info = (r or {}).get("result", {}).get("serverInfo", {})
    check("initialize returns capabilities", caps.get("textDocumentSync") == 1
          and caps.get("hoverProvider") is True, str(r))
    check("initialize returns serverInfo", info.get("name") == "okular", str(r))
    check("initialize echoes the request id", (r or {}).get("id") == 1)

    # double initialize -> error
    s.send({"jsonrpc": "2.0", "id": 2, "method": "initialize", "params": {}})
    r = s.recv()
    check("second initialize is an error",
          r is not None and "error" in r and r["id"] == 2, str(r))

    # initialized notification: no response (probe with shutdown later)
    s.send({"jsonrpc": "2.0", "method": "initialized", "params": {}})

    # ---------------- documents + diagnostics ----------------
    print("documents and diagnostics")

    s.send({"jsonrpc": "2.0", "method": "textDocument/didOpen", "params": {
        "textDocument": {"uri": uri(main_path), "languageId": "okular",
                         "version": 1, "text": broken}}})
    r, _ = s.recv_until(lambda m: m.get("method") == "textDocument/publishDiagnostics"
                        and m["params"]["uri"] == uri(main_path))
    diags = (r or {}).get("params", {}).get("diagnostics", [])
    check("broken document publishes diagnostics", r is not None and len(diags) > 0, str(r))
    check("diagnostics carry the document uri",
          (r or {}).get("params", {}).get("uri") == uri(main_path))
    d0 = diags[0] if diags else {}
    check("diagnostic has source okular and severity 1",
          d0.get("source") == "okular" and d0.get("severity") == 1, str(d0))
    check("diagnostic message is non-empty", len(d0.get("message", "")) > 0, str(d0))
    # the error is at the `print` line (line 3, 0-based) — 0-based lines
    check("diagnostic line is 0-based",
          d0.get("range", {}).get("start", {}).get("line") == 3, str(d0))
    check("diagnostic character is a UTF-16 offset",
          isinstance(d0.get("range", {}).get("start", {}).get("character"), int))

    # fix it
    s.send({"jsonrpc": "2.0", "method": "textDocument/didChange", "params": {
        "textDocument": {"uri": uri(main_path), "version": 2},
        "contentChanges": [{"text": fixed}]}})
    r, _ = s.recv_until(lambda m: m.get("method") == "textDocument/publishDiagnostics"
                        and m["params"]["uri"] == uri(main_path))
    check("fixed document publishes empty diagnostics",
          r is not None and (r or {}).get("params", {}).get("diagnostics") == [], str(r))

    # break it again
    s.send({"jsonrpc": "2.0", "method": "textDocument/didChange", "params": {
        "textDocument": {"uri": uri(main_path), "version": 3},
        "contentChanges": [{"text": broken}]}})
    r, _ = s.recv_until(lambda m: m.get("method") == "textDocument/publishDiagnostics"
                        and m["params"]["uri"] == uri(main_path))
    check("re-broken document publishes diagnostics again",
          r is not None and len((r or {}).get("params", {}).get("diagnostics", [])) > 0, str(r))

    # didClose clears
    s.send({"jsonrpc": "2.0", "method": "textDocument/didClose", "params": {
        "textDocument": {"uri": uri(main_path)}}})
    r, _ = s.recv_until(lambda m: m.get("method") == "textDocument/publishDiagnostics"
                        and m["params"]["uri"] == uri(main_path))
    check("didClose publishes empty diagnostics",
          r is not None and (r or {}).get("params", {}).get("diagnostics") == []
          and (r or {}).get("params", {}).get("uri") == uri(main_path), str(r))

    # ---------------- hover ----------------
    print("hover")
    s.send({"jsonrpc": "2.0", "method": "textDocument/didOpen", "params": {
        "textDocument": {"uri": uri(main_path), "languageId": "okular",
                         "version": 4, "text": hover_doc}}})
    r, _ = s.recv_until(lambda m: m.get("method") == "textDocument/publishDiagnostics"
                        and m["params"]["uri"] == uri(main_path))
    check("hover document compiles clean",
          r is not None and (r or {}).get("params", {}).get("diagnostics") == [], str(r))

    s.send({"jsonrpc": "2.0", "id": 5, "method": "textDocument/hover", "params": {
        "textDocument": {"uri": uri(main_path)},
        "position": {"line": 6, "character": 6}}})
    r, _ = s.recv_until(lambda m: m.get("id") == 5)
    val = (r or {}).get("result", {})
    check("hover on a function usage returns its signature",
          isinstance(val, dict)
          and val.get("contents", {}).get("value") == "function greet(name: text) -> text",
          str(r))

    s.send({"jsonrpc": "2.0", "id": 6, "method": "textDocument/hover", "params": {
        "textDocument": {"uri": uri(main_path)},
        "position": {"line": 2, "character": 9}}})
    r, _ = s.recv_until(lambda m: m.get("id") == 6)
    val = (r or {}).get("result", {})
    check("hover on the declaration returns the same signature",
          isinstance(val, dict)
          and val.get("contents", {}).get("value") == "function greet(name: text) -> text",
          str(r))

    s.send({"jsonrpc": "2.0", "id": 7, "method": "textDocument/hover", "params": {
        "textDocument": {"uri": uri(main_path)},
        "position": {"line": 0, "character": 0}}})
    r, _ = s.recv_until(lambda m: m.get("id") == 7)
    check("hover on a keyword returns null", (r or {}).get("result") is None, str(r))

    s.send({"jsonrpc": "2.0", "id": 8, "method": "textDocument/hover", "params": {
        "textDocument": {"uri": uri(main_path)},
        "position": {"line": 999, "character": 0}}})
    r, _ = s.recv_until(lambda m: m.get("id") == 8)
    check("hover past the document returns null", (r or {}).get("result") is None, str(r))

    # ---------------- robustness ----------------
    print("robustness (the server must survive all of this)")

    # invalid JSON body
    s.send_raw(b"Content-Length: 5\r\n\r\nnot j")
    r = s.recv()
    check("invalid JSON answers -32700",
          r is not None and r.get("error", {}).get("code") == -32700, str(r))

    # unknown method (request) -> -32601
    s.send({"jsonrpc": "2.0", "id": 9, "method": "textDocument/definition",
            "params": {}})
    r = s.recv()
    check("unknown method answers -32601",
          r is not None and r.get("error", {}).get("code") == -32601, str(r))

    # $/ notification ignored; $/ request answered (before shutdown!)
    s.send({"jsonrpc": "2.0", "method": "$/unknownNotification"})
    s.send({"jsonrpc": "2.0", "id": 12, "method": "$/unknownRequest"})
    r = s.recv()
    check("$/ request answers MethodNotFound, $/ notification ignored",
          r is not None and r.get("id") == 12
          and r.get("error", {}).get("code") == -32601, str(r))

    # unknown notification -> ignored (probe with a trailing request)
    s.send({"jsonrpc": "2.0", "method": "workspace/didSomeThing", "params": {}})
    s.send({"jsonrpc": "2.0", "id": 10, "method": "shutdown"})
    r = s.recv()
    check("unknown notification is silently ignored",
          r is not None and r.get("id") == 10 and r.get("result") is None, str(r))

    # request after shutdown -> -32600
    s.send({"jsonrpc": "2.0", "id": 11, "method": "textDocument/hover",
            "params": {}})
    r = s.recv()
    check("request after shutdown is refused with -32600",
          r is not None and r.get("error", {}).get("code") == -32600, str(r))

    # stray response (no method, has result) -> ignored
    s.send({"jsonrpc": "2.0", "id": 99, "result": {"whatever": 1}})

    # missing method with id -> -32600
    s.send({"jsonrpc": "2.0", "id": 13, "params": {}})
    r = s.recv()
    check("missing method answers -32600",
          r is not None and r.get("error", {}).get("code") == -32600, str(r))

    # a fresh server for the framing abuse (post-shutdown state above
    # is a valid but awkward base for "still serving" checks)
    s.send({"jsonrpc": "2.0", "method": "exit"})
    code = s.wait()
    check("exit after shutdown exits 0", code == 0, str(code))

    s = Server()
    s.send({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}})
    r = s.recv()
    check("second server initializes", "result" in (r or {}), str(r))

    # binary garbage with NULs, then a valid frame
    s.send_raw(b"\x00\x01\x02\xff\xfe garbage \x03\r\n\r\njunk")
    s.send({"jsonrpc": "2.0", "id": 2, "method": "shutdown"})
    r = s.recv()
    check("framing resynchronizes after binary garbage",
          r is not None and r.get("id") == 2, str(r))

    # restart the lifecycle (this server is post-shutdown; spawn fresh)
    s.send({"jsonrpc": "2.0", "method": "exit"})
    s.wait()
    s = Server()
    s.send({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}})
    s.recv()

    # Content-Length lies: declares 1000, delivers 1000 bytes of
    # garbage (so the frame completes), then a valid frame — the body
    # parses to a JSON error, the stream resynchronizes
    s.send_raw(b"Content-Length: 1000\r\n\r\n" + b"x" * 1000)
    sd = json.dumps({"jsonrpc": "2.0", "id": 2, "method": "shutdown"}).encode()
    s.send_raw(b"Content-Length: %d\r\n\r\n" % len(sd) + sd)
    # the garbage body answers -32700 first; the valid frame follows
    r1 = s.recv(timeout=30)
    r2 = s.recv(timeout=30)
    check("lying Content-Length: garbage body answers -32700",
          r1 is not None and r1.get("error", {}).get("code") == -32700, str(r1))
    check("lying Content-Length: the next frame resynchronizes",
          r2 is not None and r2.get("id") == 2, str(r2))

    # deeply nested JSON (depth 200 > cap 64) -> parse error, no crash
    deep = "{" * 200 + "}" * 200
    body = ('{"jsonrpc":"2.0","id":3,"method":"x","params":' + deep + "}").encode()
    s.send_raw(b"Content-Length: %d\r\n\r\n" % len(body) + body)
    r = s.recv()
    check("deeply nested JSON is rejected, not crashed",
          r is not None and "error" in r, str(r))

    # a huge declared Content-Length is garbage-skipped, not allocated
    s.send_raw(b"Content-Length: 999999999999\r\n\r\n")
    s.send({"jsonrpc": "2.0", "id": 4, "method": "shutdown"})
    r, skipped = s.recv_until(lambda m: m.get("id") == 4)
    check("huge Content-Length is skipped",
          r is not None and r.get("id") == 4, str(r) + " skipped:" + str(len(skipped)))

    # wrong params shape on hover -> graceful null
    s2 = Server()
    s2.send({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}})
    s2.recv()
    s2.send({"jsonrpc": "2.0", "id": 2, "method": "textDocument/hover",
             "params": "a string is not an object"})
    r = s2.recv()
    check("wrong params shape degrades to a null hover",
          r is not None and r.get("id") == 2 and r.get("result") is None, str(r))

    # malformed didOpen (missing textDocument) is dropped, server lives
    s2.send({"jsonrpc": "2.0", "method": "textDocument/didOpen", "params": {}})
    s2.send({"jsonrpc": "2.0", "method": "textDocument/didChange", "params": {
        "textDocument": {"uri": "file:///nonexistent.ok", "version": 1},
        "contentChanges": []}})
    s2.send({"jsonrpc": "2.0", "id": 3, "method": "shutdown"})
    r = s2.recv()
    check("malformed document notifications are dropped, server lives",
          r is not None and r.get("id") == 3, str(r))
    s2.send({"jsonrpc": "2.0", "method": "exit"})
    s2.wait()

    # ---------------- dependency attribution ----------------
    print("project dependencies")

    s3 = Server()
    s3.send({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}})
    s3.recv()

    main_src = "type.text=1\n\n[source.files.use] = {\n    \"dep\"\n}.end\n\nwrite(dep.value())\nprint\n"
    dep_broken = "function.value() -> number {\n    return 1\n"

    # write the dependency to disk (it is NOT virtualized — only the
    # open document is)
    with open(dep_path, "w") as f:
        f.write(dep_broken)
    # and the main file must exist on disk too for the project to load
    # (its CONTENT comes from the virtual override)
    with open(main_path, "w") as f:
        f.write(main_src)

    s3.send({"jsonrpc": "2.0", "method": "textDocument/didOpen", "params": {
        "textDocument": {"uri": uri(main_path), "languageId": "okular",
                         "version": 1, "text": main_src}}})
    r, _ = s3.recv_until(lambda m: m.get("method") == "textDocument/publishDiagnostics"
                         and m["params"]["uri"] == uri(dep_path))
    params = (r or {}).get("params", {})
    check("dependency errors are published",
          r is not None and len(params.get("diagnostics", [])) > 0, str(r))
    check("dependency diagnostics attribute to the dependency file",
          params.get("uri") == uri(dep_path), str(params.get("uri")))

    # fix the dependency on disk, touch the document -> clean
    with open(dep_path, "w") as f:
        f.write("function.value() -> number {\n    return 1\n}\n")
    s3.send({"jsonrpc": "2.0", "method": "textDocument/didChange", "params": {
        "textDocument": {"uri": uri(main_path), "version": 2},
        "contentChanges": [{"text": main_src}]}})
    # the broken state publishes BOTH files' diagnostics; the fixed
    # state clears them — drain until the LAST publish for main.ok
    time.sleep(0.5)
    r, skipped = s3.recv_until(lambda m: m.get("method") == "textDocument/publishDiagnostics"
                               and m["params"]["uri"] == uri(main_path)
                               and m["params"]["diagnostics"] == [])
    check("fixed dependency clears diagnostics",
          r is not None, str(r) + " skipped:" + str(len(skipped)))

    # ---------------- standalone (non-main.ok) documents ----------------
    print("standalone files")

    single_src = "type.text=1\n\nwrite(\"thing\"\nprint\n"
    with open(single_path, "w") as f:
        f.write(single_src)
    s3.send({"jsonrpc": "2.0", "method": "textDocument/didOpen", "params": {
        "textDocument": {"uri": uri(single_path), "languageId": "okular",
                         "version": 1, "text": single_src}}})
    r, _ = s3.recv_until(lambda m: m.get("method") == "textDocument/publishDiagnostics"
                         and m["params"]["uri"] == uri(single_path))
    check("standalone .ok files get diagnostics",
          r is not None and len((r or {}).get("params", {}).get("diagnostics", [])) > 0, str(r))

    # ---------------- UTF-16 positions ----------------
    print("UTF-16 positions")

    # a multi-byte text literal on the error line: byte columns and
    # UTF-16 units diverge ("héllo" = 6 bytes / 5 units)
    utf_doc = "type.text=1\n\nwrite(\"héllo\"\nprint\n"
    s3.send({"jsonrpc": "2.0", "method": "textDocument/didChange", "params": {
        "textDocument": {"uri": uri(main_path), "version": 3},
        "contentChanges": [{"text": utf_doc}]}})
    r, _ = s3.recv_until(lambda m: m.get("method") == "textDocument/publishDiagnostics"
                         and m["params"]["uri"] == uri(main_path)
                         and m["params"]["diagnostics"] != [])
    diags = (r or {}).get("params", {}).get("diagnostics", [])
    # the parser reports the error at the line start (col 1): line 2
    # (0-based), character 0 — but any diagnostic on the "héllo" line
    # must use UTF-16 units, not bytes
    check("diagnostics arrive for the UTF-8 document", len(diags) > 0, str(r))
    for d in diags:
        st = d.get("range", {}).get("start", {})
        check("UTF-8 document positions are UTF-16 (line %s char %s)"
              % (st.get("line"), st.get("character")),
              st.get("line") in (2, 3) and isinstance(st.get("character"), int),
              str(d))

    # hover with a UTF-16 position inside a multi-byte line
    s3.send({"jsonrpc": "2.0", "method": "textDocument/didChange", "params": {
        "textDocument": {"uri": uri(main_path), "version": 4},
        "contentChanges": [{"text": hover_doc}]}})
    s3.recv_until(lambda m: m.get("method") == "textDocument/publishDiagnostics"
                  and m["params"]["uri"] == uri(main_path)
                  and m["params"]["diagnostics"] == [])
    s3.send({"jsonrpc": "2.0", "id": 9, "method": "textDocument/hover", "params": {
        "textDocument": {"uri": uri(main_path)},
        "position": {"line": 6, "character": 6}}})
    r, _ = s3.recv_until(lambda m: m.get("id") == 9)
    check("hover works after UTF-8 documents cycled through",
          (r or {}).get("result", {}) is not None
          and "greet" in str((r or {}).get("result")), str(r))

    # ---------------- endurance ----------------
    print("endurance")

    for i in range(50):
        # end on a valid document so the hover below has symbols
        s3.send({"jsonrpc": "2.0", "method": "textDocument/didChange", "params": {
            "textDocument": {"uri": uri(main_path), "version": 100 + i},
            "contentChanges": [{"text": broken if i % 2 == 0 else hover_doc}]}})
        s3.recv()  # one publish per change (single-uri documents)
    s3.send({"jsonrpc": "2.0", "id": 10, "method": "textDocument/hover", "params": {
        "textDocument": {"uri": uri(main_path)},
        "position": {"line": 6, "character": 6}}})
    r, _ = s3.recv_until(lambda m: m.get("id") == 10)
    check("50 document-change cycles: server still serves hovers",
          (r or {}).get("result", {}) is not None, str(r))

    # ---------------- clean exit ----------------
    s3.send({"jsonrpc": "2.0", "id": 11, "method": "shutdown"})
    r, _ = s3.recv_until(lambda m: m.get("id") == 11)
    check("final shutdown result is null",
          r is not None and r.get("id") == 11 and r.get("result") is None, str(r))
    s3.send({"jsonrpc": "2.0", "method": "exit"})
    code = s3.wait()
    check("final exit code is 0", code == 0, str(code))

    # exit WITHOUT shutdown exits 1 (spec)
    s4 = Server()
    s4.send({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}})
    s4.recv()
    s4.send({"jsonrpc": "2.0", "method": "exit"})
    code = s4.wait()
    check("exit without shutdown exits 1", code == 1, str(code))

    # stdin EOF terminates the server cleanly
    s5 = Server()
    s5.send({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}})
    s5.recv()
    s5.close_stdin()
    code = s5.wait(timeout=15)
    check("stdin EOF terminates the server", code is not None, str(code))

    print()
    print("lsp protocol: passed %d   failed %d" % (PASS, FAIL))
    if FAILURES:
        for f in FAILURES:
            print("  - " + f)
        return 1
    print("ALL LSP PROTOCOL TESTS PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
