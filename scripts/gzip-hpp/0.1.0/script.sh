#!/usr/bin/env bash

MASON_NAME=gzip-hpp
MASON_VERSION=1.0.0
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/gzip-hpp/archive/v${MASON_VERSION}.tar.gz \
        84a777e2b7ea70d07565caa1f1ed820f5721f63d

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
