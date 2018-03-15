#!/usr/bin/env bash

MASON_NAME=libdeflate
MASON_VERSION=e9d1014
MASON_LIB_FILE=lib/libdeflate.a

# Used when cross compiling to cortex_a9
ZLIB_SHARED_VERSION=1.2.8

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/ebiggers/${MASON_NAME}/tarball/${MASON_VERSION} \
        2e671e9ab8293c058e289f0151aad269dceb7526

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/ebiggers-${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    # export CFLAGS="${CFLAGS:-} -O3 -DNDEBUG"
    # export LDFLAGS="${CFLAGS:-}"
    # we want -O3 for best performance
    perl -i -p -e "s/-O2/-O3 -DNDEBUG/g;" Makefile
    # note: -fomit-frame-pointer is in default flags for libdeflate
    V=1 VERBOSE=1 make -j${MASON_CONCURRENCY}
    mkdir -p ${MASON_PREFIX}/lib
    cp libdeflate.a ${MASON_PREFIX}/lib/
    mkdir -p ${MASON_PREFIX}/include
    cp libdeflate.h ${MASON_PREFIX}/include/
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
