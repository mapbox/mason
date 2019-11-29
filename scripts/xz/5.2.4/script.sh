#!/usr/bin/env bash

MASON_NAME=xz
MASON_VERSION=5.2.4
MASON_LIB_FILE=lib/liblzma.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://tukaani.org/xz/xz-${MASON_VERSION}.tar.gz \
        cf1456593b6291ecc1672a69fd9134a1d7ac3380

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/xz-${MASON_VERSION}
}

function mason_compile {
      export CFLAGS="${CFLAGS:-} -O3 -DNDEBUG -fno-common -DPIC"
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
