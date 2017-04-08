#!/usr/bin/env bash

MASON_NAME=gdb
MASON_VERSION=2017-04-08-aebcde5
MASON_LIB_FILE=bin/gdb

. ${MASON_DIR}/mason.sh

function mason_load_source {
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
    git clone git://sourceware.org/git/binutils-gdb.git ${MASON_BUILD_PATH}
    cd ${MASON_BUILD_PATH}
    git clone aebcde5eb475befba571ca9ae7b6c58126d41160
    cd ../
}

function mason_compile {
    # set -fpermissive to try to work around
    # location.c:527:16: error: comparison between pointer and integer ('const char *' and 'int')
    # || *argp == '\0'
    export CFLAGS="${CFLAGS} -fpermissive"
    export CXXFLAGS="${CXXFLAGS} -fpermissive"
    ./configure \
     --prefix=${MASON_PREFIX} \
     --enable-gold \
     --enable-plugins \
     --enable-static \
     --disable-debug \
     --disable-dependency-tracking \
     --disable-werror \
     --disable-shared \
     --without-guile \
     --without-python \
     --with-system-zlib

    make -j${MASON_CONCURRENCY}
    make install
}

function mason_clean {
    make clean
}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_static_libs {
    :
}

mason_run "$@"
