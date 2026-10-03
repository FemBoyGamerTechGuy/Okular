#!/bin/sh
# --out with missing parent directories: the compiler must create
# nested/deep/ before writing the executable there (0.18.1: the
# release packaging test caught the gap — only the DEFAULT path
# got mkdir_p).
set -e
cd "$(dirname "$0")"
rm -rf nested
"$OKC" main.ok --out nested/deep/app
./nested/deep/app
