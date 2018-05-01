#!/usr/bin/env bash

MASON_NAME=gzip-hpp
MASON_VERSION=0.1.0
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/gzip-hpp/archive/v${MASON_VERSION}.tar.gz \
        7bd14b3b9f63a05a7a09264cdda93c741666e835

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/gzip-hpp-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r include/gzip ${MASON_PREFIX}/include/gzip
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}


mason_run "$@"
