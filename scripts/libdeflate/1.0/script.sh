#!/usr/bin/env bash

MASON_NAME=libdeflate
MASON_VERSION=1.0
MASON_LIB_FILE=lib/libdeflate.a

# Used when cross compiling to cortex_a9
ZLIB_SHARED_VERSION=1.2.8

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/ebiggers/${MASON_NAME}/archive/v${MASON_VERSION}.tar.gz \
        5255c4b15185451247032a29c480a198215384ec
    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
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
