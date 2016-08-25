#!/usr/bin/env bash

MASON_NAME=vectortile
MASON_VERSION=1.0.0-rc4
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/vector-tile/archive/v${MASON_VERSION}.tar.gz \
        7f9e12913ccb09bbe4e32cc8300383b1e7a2aef0

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/vector-tile-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r include ${MASON_PREFIX}/include
}

mason_run "$@"