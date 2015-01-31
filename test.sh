#!/usr/bin/env bash

set -e -u
set -o pipefail

# ensure a few system apps work to install
./mason install zlib system
./mason install sqlite system

# ensure we can compile a few common C libs
./mason build sqlite 3.8.8.1
./mason build libuv 0.10.28
./mason build libuv 0.11.29

# ensure building a C++ lib works
./mason build boost_libregex 1.57.0

