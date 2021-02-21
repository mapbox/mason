#!/usr/bin/env bash

MASON_NAME=flex
MASON_VERSION=2.6.4
MASON_LIB_FILE=bin/flex

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/westes/flex/releases/download/v${MASON_VERSION}/flex-${MASON_VERSION}.tar.gz \
        fd328f959c8d1f111fcb5dae9ca377f2e60c238c

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/flex-${MASON_VERSION}
    
}

function mason_prepare_compile {
    CLANG_VERSION=11.0.0
    ZLIB_VERSION=1.2.8
    ${MASON_DIR}/mason install clang++ ${CLANG_VERSION}
    MASON_CLANG=$(${MASON_DIR}/mason prefix clang++ ${CLANG_VERSION})
    ${MASON_DIR}/mason install zlib ${ZLIB_VERSION}
    MASON_ZLIB=$(${MASON_DIR}/mason prefix zlib ${ZLIB_VERSION})
}

function mason_compile {
    export CXX="${CUSTOM_CXX:-${MASON_CLANG}/bin/clang++}"
    export CC="${CUSTOM_CC:-${MASON_CLANG}/bin/clang}"
    echo "using CXX=${CXX}"
    echo "using CC=${CC}"
    export CFLAGS="${CFLAGS:-} ${MASON_ZLIB_CFLAGS:-} -O3 -DNDEBUG"
    export LDFLAGS="${CFLAGS:-} ${MASON_ZLIB_LDFLAGS:-}"
    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --with-pic \
        --disable-shared \
        --disable-dependency-tracking

    V=1 VERBOSE=1 make install -j${MASON_CONCURRENCY}
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
