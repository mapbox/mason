#!/usr/bin/env bash

MASON_NAME=wagyu
MASON_VERSION=0.4.2
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/wagyu/archive/${MASON_VERSION}.tar.gz \
        78b1be69aecbc8af46faf8ffc6e9c1cb96f18476

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/wagyu-${MASON_VERSION}
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
