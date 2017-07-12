#!/usr/bin/env bash

MASON_NAME=cheap-ruler
MASON_VERSION=2.5.2
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/${MASON_NAME}-cpp/archive/v${MASON_VERSION}.tar.gz \
        c4c295bcf1269161ad4f1d50518a6d86d147e27b

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-cpp-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r include/mapbox ${MASON_PREFIX}/include/mapbox
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}


mason_run "$@"
