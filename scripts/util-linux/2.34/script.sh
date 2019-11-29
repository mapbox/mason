#!/usr/bin/env bash

MASON_NAME=util-linux
MASON_VERSION=2.34
MASON_LIB_FILE=lib/libuuid.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v${MASON_VERSION}/util-linux-${MASON_VERSION}.tar.gz \
        10432c4a489d7dd90b133233ad938d9d20135f59

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/util-linux-${MASON_VERSION}
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
    :
}

function mason_ldflags {
    :
}

mason_run "$@"
