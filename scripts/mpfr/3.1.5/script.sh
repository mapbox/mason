#!/usr/bin/env bash

MASON_NAME=mpfr
MASON_VERSION=3.1.5
MASON_LIB_FILE=lib/libmpfr.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://mirrors.ocf.berkeley.edu/debian/pool/main/m/mpfr4/mpfr4_${MASON_VERSION}.orig.tar.xz \
        a70e79bba7d23ed2625c39a81a94b5395356e9d0

    mason_extract_tar_xz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    ${MASON_DIR}/mason install gmp 6.1.2
    MASON_GMP=$(${MASON_DIR}/mason prefix gmp 6.1.2)
}

function mason_compile {
    export CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG"
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"

    # TODO: pass --build=core2-apple-darwin on osx for greater portability?
    # ld: warning: PIE disabled. Absolute addressing (perhaps -mdynamic-no-pic) not allowed in code signed PIE, but used in ___gmpn_divexact_1 from /Users/dane/.mason/mason_packages/osx-x86_64/gmp/6.1.2/lib/libgmp.a(dive_1.o). To fix this warning, don't compile with -mdynamic-no-pic or link with -Wl,-no_pie
    ./configure --prefix=${MASON_PREFIX} ${MASON_HOST_ARG} \
     --enable-static \
     --disable-shared \
     --disable-dependency-tracking \
     --disable-silent-rules \
     --with-gmp=${MASON_GMP}

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
