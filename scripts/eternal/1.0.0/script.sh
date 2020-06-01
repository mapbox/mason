#!/usr/bin/env bash

MASON_NAME=eternal
MASON_VERSION=1.0.0
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/eternal/archive/v${MASON_VERSION}.tar.gz \
        b40b0fe8de247b4467d6c8c1fa6e4ac4a06c44b2

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/eternal-${MASON_VERSION}
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
