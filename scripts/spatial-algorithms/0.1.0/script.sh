#!/usr/bin/env bash

MASON_NAME=spatial-algorithms
MASON_VERSION=0.1.0
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/${MASON_NAME}/tarball/v${MASON_VERSION} \
        4bddd38bd4534aef9e1b10dfec601c733876bbd4

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/mapbox-${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r include/mapbox ${MASON_PREFIX}/include/mapbox
    cp -r include/boost ${MASON_PREFIX}/include/boost
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}

mason_run "$@"
