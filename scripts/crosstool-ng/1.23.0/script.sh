#!/usr/bin/env bash

MASON_NAME=crosstool-ng
MASON_VERSION=1.23.0

MASON_LIB_FILE=bin/ct-ng

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        http://crosstool-ng.org/download/crosstool-ng/${MASON_NAME}-${MASON_VERSION}.tar.bz2 \
        1b69890d021b5b50a96b70be0fad3bd6e64a6e9e

    mason_extract_tar_bz2

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    ./configure \
        --prefix=${MASON_PREFIX}

    make V=1 -j${MASON_CONCURRENCY}
    make install -j${MASON_CONCURRENCY}
}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_pkgconfig {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
