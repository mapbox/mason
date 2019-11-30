#!/usr/bin/env bash

MASON_NAME=babletrace
MASON_VERSION=1.5.7
MASON_LIB_FILE=lib/libbabeltrace.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/babeltrace.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://www.efficios.com/files/babeltrace/babeltrace-${MASON_VERSION}.tar.bz2 \
        a41d581a2f36ef2b4c2440805ceef205f1a1fe58

    mason_extract_tar_bz2

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/babeltrace-${MASON_VERSION}
}

function mason_prepare_compile {
    ${MASON_DIR}/mason install util-linux 2.34
    MASON_UTIL_LINUX=$(${MASON_DIR}/mason prefix util-linux 2.34)
    ${MASON_DIR}/mason install popt 1.16
    MASON_POPT=$(${MASON_DIR}/mason prefix popt 1.16)
    ${MASON_DIR}/mason install elfutils 0.178
    MASON_ELFUTILS=$(${MASON_DIR}/mason prefix elfutils 0.178)
    ${MASON_DIR}/mason install zlib 1.2.11
    MASON_ZLIB=$(${MASON_DIR}/mason prefix zlib 1.2.11)
}


function mason_compile {
    export CFLAGS="${CFLAGS:-} -O3 -DNDEBUG -I${MASON_POPT}/include -I${MASON_UTIL_LINUX}/include -I${MASON_ELFUTILS}/include"
    export LDFLAGS="${LDFLAGS:-} -L${MASON_POPT}/lib -L${MASON_ELFUTILS}/lib -L${MASON_UTIL_LINUX}/lib -L${MASON_ZLIB}/lib -Wl,--start-group -lz"

    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --with-pic \
        --disable-shared \
        --disable-dependency-tracking \
        --enable-debug-info

    V=1 VERBOSE=1 make install -j${MASON_CONCURRENCY}
}

function mason_cflags {
    :
}


function mason_ldflags {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
