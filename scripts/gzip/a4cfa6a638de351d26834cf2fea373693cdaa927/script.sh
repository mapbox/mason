#!/usr/bin/env bash

MASON_NAME=gzip
MASON_VERSION=a4cfa6a638de351d26834cf2fea373693cdaa927
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/gzip-hpp/archive/${MASON_VERSION}.tar.gz \
        5209450e584d3349b857460a6a0ca599b603aec3

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
