#!/usr/bin/env bash

MASON_NAME=wagyu
MASON_VERSION=0.4.2-gcc
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/wagyu/archive/22c2fe6.tar.gz \
        1c61ffe6651dfd8f91587f8b35d8622bfbc4b634

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/wagyu-22c2fe6a09b8b662eb993a804b2a3ea37c1d09f0
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
