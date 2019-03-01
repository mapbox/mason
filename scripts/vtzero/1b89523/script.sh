#!/usr/bin/env bash

MASON_NAME=vtzero
MASON_VERSION=1b89523
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/vtzero/tarball/${MASON_VERSION} \
        ec411459f66a6ae7e0af739850912378a6fce3ce

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
