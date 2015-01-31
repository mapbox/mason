#!/usr/bin/env bash

set -e -u
set -o pipefail

# bootstrap c++11 capable toolchain
source ./scripts/setup_cpp11_toolchain.sh

# ensure building a C++ lib works
./mason build boost_libregex 1.57.0

