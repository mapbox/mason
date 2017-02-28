#!/usr/bin/env bash

MASON_NAME=libzmq
MASON_VERSION=4.2.2
MASON_LIB_FILE=lib/libzmq.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/libzmq.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/zeromq/libzmq/releases/download/v${MASON_VERSION}/zeromq-${MASON_VERSION}.tar.gz \
        3ff55a1c2b23ad1a586789747c9837bd0729bb6d

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/zeromq-${MASON_VERSION}
}

function mason_compile {
    # note: mason CFLAGS/CXXFLAGS override default (-g -O2)
    # so we add optmization settings now
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    export CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG"

    # we link to libc++ on OS X so we need to knock out the libstdc++ assumption in the .pc file
    perl -i -p -e "s/-lstdc\+\+//g;" libzmq.pc.in

    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --disable-shared \
        --disable-dependency-tracking

    V=1 make -j${MASON_CONCURRENCY}
    make install
}

function mason_clean {
    make clean
}

mason_run "$@"
