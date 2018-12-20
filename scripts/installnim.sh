#!/bin/bash

set -e
set -u

: ${NETLIFY_BUILD_BASE="/opt/buildhome"}
NETLIFY_CACHE_DIR="$NETLIFY_BUILD_BASE/cache"
NIM_INSTALL_DIR="$NETLIFY_CACHE_DIR"

export PATH=$NIM_INSTALL_DIR/nim/bin:$PATH

install_nim() {
  if [ -z "$1" ]
  then
    echo "install_nim requires Nim version."
    exit 1
  fi

  local nimver=$1

  rm -rf $NIM_INSTALL_DIR/nim

  wget -N -nv https://nim-lang.org/download/nim-$nimver.tar.xz
  wget -N -nv https://nim-lang.org/download/nim-$nimver.tar.xz.sha256

  sha256sum -c nim-$nimver.tar.xz.sha256

  if [ ! $? = 0 ]; then
    echo "Failed to download nim source code"
  fi

  tar xf nim-$nimver.tar.xz
  pushd nim-$nimver
  sh build.sh
  bin/nim c koch
  ./koch tools
  ./koch install $NIM_INSTALL_DIR
  popd
}

install_nim_check() {
  if [ -z "$1" ]
  then
    echo "install_nim_check requires Nim version."
    exit 1
  fi

  local nimver="$1"
  local src_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
  if command -v nim && nim e "$src_dir/checknimver.nims" $nimver
  then
    echo skip installing nim
  else
    install_nim $nimver
  fi
}
