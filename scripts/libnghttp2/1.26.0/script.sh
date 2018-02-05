#!/usr/bin/env bash

MASON_NAME=libnghttp2
MASON_VERSION=1.26.0
MASON_LIB_FILE=lib/libnghttp2.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/libnghttp2.pc

. ${MASON_DIR}/mason.sh


function mason_load_source {
    mason_download \
        https://github.com/nghttp2/nghttp2/releases/download/v${MASON_VERSION}/nghttp2-${MASON_VERSION}.tar.gz \
        49b166e603a056900a5febc2681de3bc4b65675e

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/nghttp2-${MASON_VERSION}
}

function mason_compile {
    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --disable-shared \
        --disable-dependency-tracking \
        --enable-lib-only

    make -j${MASON_CONCURRENCY}
    make install
}

function mason_clean {
    make clean
}

mason_run "$@"
