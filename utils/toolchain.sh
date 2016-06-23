#!/usr/bin/env bash

set -eu
set -o pipefail

CLANG_VERSION="3.8.0"
./mason install clang ${CLANG_VERSION}
export PATH=$(./mason prefix clang ${CLANG_VERSION})/bin:${PATH}
export CXX=clang++-3.8
export CC=clang-3.8

set +eu