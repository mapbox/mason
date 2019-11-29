#!/usr/bin/env bash

MASON_NAME=slang
MASON_VERSION=2.3.2
MASON_LIB_FILE=lib/libslang.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://www.jedsoft.org/releases/slang/slang-${MASON_VERSION}.tar.bz2 \
        d341fa8f220d0b26d3d8a09c3c93cceb95eec0b6

    mason_extract_tar_bz2

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/slang-${MASON_VERSION}
}

function mason_compile {
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    ./configure --prefix=${MASON_PREFIX} ${MASON_HOST_ARG} \
     --enable-static \
     --disable-shared \
     --disable-dependency-tracking

    make V=1 install-static
}

function mason_cflags {
    echo ${MASON_PREFIX}/include
}

function mason_ldflags {
    :
}

function mason_static_libs {
    echo ${MASON_PREFIX}/${MASON_LIB_FILE}
}

mason_run "$@"
