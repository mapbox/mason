#!/usr/bin/env bash

MASON_NAME=jemalloc
MASON_VERSION=4.5.0
MASON_LIB_FILE=bin/jeprof

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/jemalloc/jemalloc/releases/download/${MASON_VERSION}/jemalloc-${MASON_VERSION}.tar.bz2 \
        aaf67fd3bc382e2bf57d4d71d4bf2b17a2136459

    mason_extract_tar_bz2

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    # note: as of jemalloc 4.5.0 CFLAGS no longer overwrites but appends.
    # so we don't mess with CFLAGS here like previous packages where we needed to manually re-add the jemalloc CFLAGS that were lost
    ./configure --prefix=${MASON_PREFIX}
    make -j${MASON_CONCURRENCY} VERBOSE=1
    make install
}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
