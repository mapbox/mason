#!/usr/bin/env bash

MASON_NAME=libzmq
MASON_VERSION=4.2.2
MASON_LIB_FILE=lib/libzmq.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/libzmq.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/zeromq/libzmq/releases/download/v4.2.2/zeromq-4.2.2.tar.gz \
        3ff55a1c2b23ad1a586789747c9837bd0729bb6d

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/zeromq-${MASON_VERSION}
}

function mason_compile {
    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --disable-shared \
        --disable-dependency-tracking

    ./autogen.sh

    make install -j${MASON_CONCURRENCY}
}

function mason_clean {
    make clean
}

mason_run "$@"
