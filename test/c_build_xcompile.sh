#!/usr/bin/env bash

set -e -u
set -o pipefail

MASON_PLATFORM_VERSION=cortex_a9 mason build mason_test xcompile
MASON_PLATFORM_VERSION=i686      mason build mason_test xcompile
