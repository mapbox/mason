#!/usr/bin/env bash

MASON_NAME=wagyu
MASON_VERSION=0.2.0
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/wagyu/archive/${MASON_VERSION}.tar.gz \
        37af907e4085f53cfdf9e4521db2b520597aaa1e

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
