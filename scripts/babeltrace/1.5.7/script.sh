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
    ${MASON_DIR}/mason install popt 1.16
    MASON_POPT=$(${MASON_DIR}/mason prefix popt 1.16)
    ${MASON_DIR}/mason install elfutils 0.178
    MASON_ELFUTILS=$(${MASON_DIR}/mason prefix elfutils 0.178)
}


function mason_compile {
    export CFLAGS="${CFLAGS:-} -O3 -DNDEBUG -I${MASON_POPT}/include -I${MASON_ELFUTILS}/include"
    export LDFLAGS="${LDFLAGS:-} -L${MASON_POPT}/lib -liconv -L${MASON_ELFUTILS}/lib"

    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --with-pic \
        --disable-shared \
        --disable-dependency-tracking \
        --disable-debug-info || cat config.log

    V=1 VERBOSE=1 make install -j${MASON_CONCURRENCY}
}

function mason_strip_ldflags {
    shift # -L...
    shift # -lpng16
    echo "$@"
}

function mason_ldflags {
    mason_strip_ldflags $(`mason_pkgconfig` --static --libs)
}

function mason_clean {
    make clean
}

mason_run "$@"
