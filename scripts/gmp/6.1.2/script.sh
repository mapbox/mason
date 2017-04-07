#!/usr/bin/env bash

MASON_NAME=gmp
MASON_VERSION=6.1.2
MASON_LIB_FILE=lib/libgmp.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://gmplib.org/download/gmp/gmp-${MASON_VERSION}.tar.xz \
        41988ae93c59e489c8620b629d9079e3e4e0ace1

    mason_extract_tar_xz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    ${MASON_DIR}/mason install cmake 3.7.2
    MASON_CCACHE=$(${MASON_DIR}/mason prefix cmake 3.7.2)/bin/cmake
}

function mason_compile {
    export CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG"
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"

    # TODO: pass --build=core2-apple-darwin on osx for greater portability?
    ./configure --prefix=${MASON_PREFIX} ${MASON_HOST_ARG} \
     --enable-static \
     --disable-shared \
     --disable-dependency-tracking \
     --enable-cxx

    make -j${MASON_CONCURRENCY} V=1
    make check
    make install
}

function mason_ldflags {
    : # We're only using the full path to the archive, which is output in static_libs
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}


mason_run "$@"
