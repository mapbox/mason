#!/usr/bin/env bash

MASON_NAME=bison
MASON_VERSION=3.1
MASON_LIB_FILE=bin/bison

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        http://ftp.gnu.org/gnu/bison/bison-${MASON_VERSION}.tar.gz \
        80dd52f478bd6dfddf3c5e01619f3c8ae29659ca
    mason_extract_tar_gz
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/bison-${MASON_VERSION}
}

function mason_compile {
    export CFLAGS="${CFLAGS:-} -O3 -DNDEBUG"
    export LDFLAGS="${CFLAGS:-}"

    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --with-pic \
        --disable-shared \
        --disable-dependency-tracking

    V=1 VERBOSE=1 make install -j${MASON_CONCURRENCY}
}


function mason_ldflags {
    :
}

function mason_cflags {
    :
}


mason_run "$@"
