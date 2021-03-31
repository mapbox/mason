#!/usr/bin/env bash

MASON_NAME=expat
MASON_VERSION=2.3.0
MASON_VERSION2="R_${MASON_VERSION//./_}"
MASON_LIB_FILE=lib/libexpat.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/expat.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/libexpat/libexpat/releases/download/${MASON_VERSION2}/expat-${MASON_VERSION}.tar.gz \
        f6d07e2b059f7c17a0d16257d972268f66c4aec3
    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/expat-${MASON_VERSION}
}

function mason_compile {
    cd expat
    # Add optimization flags since CFLAGS overrides the default (-g -O2)
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --without-xmlwf \
        --enable-static \
        --disable-shared \
        --disable-dependency-tracking

    make install -j${MASON_CONCURRENCY}
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    echo -L${MASON_PREFIX}/lib -lexpat
}


function mason_clean {
    make clean
}

mason_run "$@"
