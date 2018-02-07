#!/usr/bin/env bash

MASON_NAME=vtzero
MASON_VERSION=07fe353
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/vtzero/tarball/${MASON_VERSION} \
        e2987367cc80a3e202ad0e7e27d3367d2c2a4bab

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/mapbox-vtzero-${MASON_VERSION}
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
