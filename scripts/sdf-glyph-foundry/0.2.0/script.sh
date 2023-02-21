#!/usr/bin/env bash

MASON_NAME=sdf-glyph-foundry
MASON_VERSION=0.2.0
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/sdf-glyph-foundry/archive/v${MASON_VERSION}.tar.gz \
        1ef9a9cef2dc2c020cbf703a48afff43d76f6c99

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/sdf-glyph-foundry-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r include/mapbox ${MASON_PREFIX}/include/mapbox
    cp -r include/agg ${MASON_PREFIX}/include/agg
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}

function mason_static_libs {
    :
}

mason_run "$@"
