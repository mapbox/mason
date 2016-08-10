#!/usr/bin/env bash

MASON_NAME=vectortile
MASON_VERSION=1.0.0-rc1
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/vector-tile/archive/v${MASON_VERSION}.tar.gz \
        2876991412fcfd41bd7d606e78025e2d3f6e319b

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r include ${MASON_PREFIX}/include
}

mason_run "$@"