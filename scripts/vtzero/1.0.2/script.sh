#!/usr/bin/env bash

MASON_NAME=vtzero
MASON_VERSION=1.0.2
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/vtzero/archive/v${MASON_VERSION}.tar.gz \
        2bf529761a418c70ae06ab5f7439d6462890ad4b

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/vtzero-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r include/vtzero ${MASON_PREFIX}/include/vtzero
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}


mason_run "$@"
