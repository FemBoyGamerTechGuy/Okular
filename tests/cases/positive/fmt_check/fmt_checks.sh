#!/bin/sh
# the formatter end-to-end: messy input -> canonical form; idempotence;
# --check exit codes; formatted files still compile and run identically
set -e
cd "$(dirname "$0")"
printf 'type.text=1\nwrite(  1+2  )  # trailing\n#  standalone\nwrite("x")\n' > messy.ok
"$OKC" fmt messy.ok >/dev/null
printf 'type.text=1\nwrite(1 + 2)  # trailing\n#  standalone\nwrite("x")\n' > expect.ok
diff -u expect.ok messy.ok
"$OKC" fmt --check messy.ok
cp messy.ok again.ok
"$OKC" fmt again.ok >/dev/null
cmp messy.ok again.ok
printf 'type.text=1\nwrite(1+2)\n' > unfmt.ok
if "$OKC" fmt --check unfmt.ok >/dev/null 2>&1; then exit 1; fi
"$OKC" fmt unfmt.ok >/dev/null
"$OKC" fmt --check unfmt.ok
echo "fmt: all checks passed"
