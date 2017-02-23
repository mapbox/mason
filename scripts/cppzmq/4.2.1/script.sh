#!/usr/bin/env bash

MASON_NAME=cppzmq
MASON_VERSION=4.2.1
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/zeromq/cppzmq/archive/v4.2.1.tar.gz \
        91387dc3137690183c4d9437d7a1fa3f1caa2af3

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/cppzmq-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include
    cp -r ${MASON_ROOT}/.build/cppzmq-${MASON_VERSION}/*.hpp ${MASON_PREFIX}/include
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    :
}

mason_run "$@"
