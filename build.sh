#!/bin/bash

set -e
set -u

src_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source "$src_dir/scripts/installnim.sh"

install_nim_check "1.4.0"
cd "$src_dir/src"
nim c -r -d:release "$src_dir/src/bloggen.nim"
