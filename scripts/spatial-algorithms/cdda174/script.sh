#!/usr/bin/env bash

MASON_NAME=spatial-algorithms
MASON_VERSION=cdda174
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/${MASON_NAME}/tarball/${MASON_VERSION} \
        1f0c5a41c42a33295dc251ef540ce6f6c1e8d5da

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
