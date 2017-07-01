#!/usr/bin/env bash

set -e -u
set -o pipefail

mason build expat 2.1.1
mason build expat 2.2.0
mason build libzip 1.1.3
mason build zlib 1.2.8
mason build libuv 0.11.29