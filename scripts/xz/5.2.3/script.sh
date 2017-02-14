#!/usr/bin/env bash

MASON_NAME=xz
MASON_VERSION=5.2.3
MASON_LIB_FILE=lib/liblzma.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        http://tukaani.org/xz/xz-${MASON_VERSION}.tar.gz \
        147ce202755a3d846dc17479999671c7cadf0c2f

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/xz-${MASON_VERSION}
}

function mason_compile {
    export CFLAGS="${CFLAGS:-} -O3 -DNDEBUG"

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
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    :
}

function mason_static_libs {
    echo ${MASON_PREFIX}/${MASON_LIB_FILE}
}

function mason_clean {
    make clean
}

mason_run "$@"
