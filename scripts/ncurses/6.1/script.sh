#!/usr/bin/env bash

MASON_NAME=ncurses
MASON_VERSION=6.1
MASON_LIB_FILE=lib/libncursesw.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://ftp.gnu.org/gnu/ncurses/${MASON_NAME}-${MASON_VERSION}.tar.gz \
        511c02700a6fd392a11a4d5e88f5315a7c295d0c

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    # Add optimization flags since CFLAGS overrides the default (-g -O2)
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    ./configure \
        --prefix=${MASON_PREFIX} \
        --enable-sigwinch \
        --enable-symlinks \
        --enable-widec \
        --enable-static \
        --disable-shared \
        --disable-dependency-tracking

    make -j${MASON_CONCURRENCY}
    make install
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
