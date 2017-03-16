#!/usr/bin/env bash

MASON_NAME=ninja
MASON_VERSION=1.7.2
MASON_LIB_FILE=bin/ninja

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/ninja-build/ninja/archive/v${MASON_VERSION}.tar.gz \
        c2bedfff79f86f82bea29054dcf17689b7716fcc

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
