#!/usr/bin/env bash

MASON_NAME=hpp_skel
MASON_VERSION=0.0.2
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/hpp-skel/archive/v${MASON_VERSION}.tar.gz \
        b4cfcae25b3b27afe8d2677f76ffe4edc770db7e

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r include ${MASON_PREFIX}/include
}

mason_run "$@"