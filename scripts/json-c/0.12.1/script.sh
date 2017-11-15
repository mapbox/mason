#!/usr/bin/env bash

MASON_NAME=json-c
MASON_VERSION=0.12.1
MASON_VERSION2=0.12.1-20160607
MASON_LIB_FILE=lib/libjson-c.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/json-c.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/json-c/json-c/archive/${MASON_NAME}-${MASON_VERSION2}.tar.gz \
        fbd935e5e7253716fe425428f439ffe7e89e0104

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_NAME}-${MASON_VERSION2}
}

function mason_compile {
    # Note CFLAGS overrides the default with is `-O2 -g`
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    ./configure --prefix=${MASON_PREFIX} ${MASON_HOST_ARG} \
     --enable-static \
     --disable-shared \
     --disable-silent-rules \
     --disable-dependency-tracking

    make -j${MASON_CONCURRENCY} V=1
    make install
}

function mason_ldflags {
    : # We're only using the full path to the archive, which is output in static_libs
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_clean {
    make clean
}

mason_run "$@"
