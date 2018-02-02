#!/usr/bin/env bash

MASON_NAME=spatial-algorithms
MASON_VERSION=0.1.0
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/${MASON_NAME}/archive/v${MASON_VERSION}.tar.gz \
        502cec856118c76d5c8e38d6a51cce9e2d2a42c8

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
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
