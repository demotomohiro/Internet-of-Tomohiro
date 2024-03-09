#!/bin/bash

set -e
set -u

install_nim() {
  if [ -z "$1" ]
  then
    echo "install_nim requires Nim version."
    exit 1
  fi

  local nimver=$1

  wget -N -nv https://nim-lang.org/download/nim-$nimver-linux_x64.tar.xz
  wget -N -nv https://nim-lang.org/download/nim-$nimver-linux_x64.tar.xz.sha256

  sha256sum -c nim-$nimver-linux_x64.tar.xz.sha256

  if [ ! $? = 0 ]; then
    echo "Failed to download pre-built Nim"
  fi

  tar xf nim-$nimver-linux_x64.tar.xz

  export PATH=`pwd`/nim-$nimver/bin:$PATH
}

install_nim_check() {
  if [ -z "$1" ]
  then
    echo "install_nim_check requires Nim version."
    exit 1
  fi

  local nimver="$1"
  install_nim $nimver
  local src_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
  if command -v nim && nim e "$src_dir/checknimver.nims" $nimver
  then
    echo "Installing nim done"
  else
    echo "Failed to install Nim"
    exit 1
  fi
}
