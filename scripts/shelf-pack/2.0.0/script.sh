#!/usr/bin/env bash

MASON_NAME=shelf-pack
MASON_VERSION=2.0.0
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
    https://github.com/mapbox/shelf-pack-cpp/archive/v${MASON_VERSION}.tar.gz \
    443ba2e07a157393d50f18cd19ca9c428000265e
    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/shelf-pack-cpp-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/mapbox
    cp -v include/*.hpp ${MASON_PREFIX}/include/mapbox
    cp -v README.md LICENSE.md ${MASON_PREFIX}
}

function mason_cflags {
    echo -isystem ${MASON_PREFIX}/include -I${MASON_PREFIX}/include
}

function mason_ldflags {
    :
}

function mason_static_libs {
    :
}

mason_run "$@"
