#!/usr/bin/env bash

MASON_NAME=vectortile
MASON_VERSION=1.0.0-rc1
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/vector-tile/archive/v${MASON_VERSION}.tar.gz \
        cc9b976c7a885702b6cb07370d99f0751a47f6f7

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/vector-tile-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r include ${MASON_PREFIX}/include
}

mason_run "$@"