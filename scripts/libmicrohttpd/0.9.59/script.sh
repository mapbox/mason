#!/usr/bin/env bash

MASON_NAME=libmicrohttpd
MASON_VERSION=0.9.59
MASON_LIB_FILE=lib/libmicrohttpd.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-${MASON_VERSION}.tar.gz \
        35586f8010a54d74691a0e1c269b48f8b43cb649

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    export CFLAGS="${CFLAGS:-} -O3 -DNDEBUG"

    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --disable-shared \
        --disable-dependency-tracking

    V=1 VERBOSE=1 make install -j${MASON_CONCURRENCY}
}

function mason_static_libs {
    echo ${MASON_PREFIX}/${MASON_LIB_FILE}
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include    
}

function mason_ldflags {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
