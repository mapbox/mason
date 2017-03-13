#!/usr/bin/env bash

MASON_NAME=sparsehash
MASON_VERSION=2.0.2
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/sparsehash/sparsehash/archive/sparsehash-${MASON_VERSION}.tar.gz \
        34182e6923efa9fce24f3c41036c1a57daa4b1b7

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    patch -N -p1 < ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff
    # Add optimization flags since CFLAGS overrides the default (-g -O2)
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    export CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG"
    ./configure --prefix=${MASON_PREFIX} ${MASON_HOST_ARG} \
    --enable-static --disable-shared \
    --disable-dependency-tracking
    make  -j${MASON_CONCURRENCY}
    make install    
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
