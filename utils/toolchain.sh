#!/usr/bin/env bash

set -eu
set -o pipefail

CLANG_VERSION="5.0.0"
./mason install clang++ ${CLANG_VERSION}
export PATH=$(./mason prefix clang++ ${CLANG_VERSION})/bin:${PATH}
export CXX=clang++
export CC=clang

set +eu