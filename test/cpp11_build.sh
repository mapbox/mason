#!/usr/bin/env bash

set -e -u
set -o pipefail

# bootstrap c++11 capable toolchain
source ./scripts/setup_cpp11_toolchain.sh

# ensure building a C++ lib works
./mason build stxxl 1.4.1

