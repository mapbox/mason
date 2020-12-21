#!/usr/bin/env bash

MASON_NAME=ninja
MASON_VERSION=1.10.1
MASON_LIB_FILE=bin/ninja

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/ninja-build/ninja/archive/v${MASON_VERSION}.tar.gz \
        39f0b8b8335a6ddc3678b9c58c4042ae3fa1424f

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    ./configure.py --bootstrap
    mkdir -p ${MASON_PREFIX}/bin/
    cp ./ninja ${MASON_PREFIX}/bin/
}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_static_libs {
    :
}

mason_run "$@"
