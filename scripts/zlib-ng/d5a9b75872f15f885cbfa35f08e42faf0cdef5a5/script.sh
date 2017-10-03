#!/usr/bin/env bash

MASON_NAME=zlib-ng
MASON_VERSION=d5a9b75872f15f885cbfa35f08e42faf0cdef5a5
MASON_LIB_FILE=lib/libz.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/zlib.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/Dead2/zlib-ng/archive/${MASON_VERSION}.tar.gz \
        c196f3b8595e752d429bc8d1d89036509a15890d

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    # Add optimization flags since CFLAGS overrides the default (-g -O2)
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    ./configure \
        --prefix=${MASON_PREFIX} \
        --static

    make install -j${MASON_CONCURRENCY}
}

mason_run "$@"
