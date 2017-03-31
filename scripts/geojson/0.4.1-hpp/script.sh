#!/usr/bin/env bash

MASON_NAME=geojson
MASON_VERSION=0.4.1
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/geojson-cpp/archive/v${MASON_VERSION}.tar.gz \
        b50a978d97ecc0c6d32bb442eea4fd67a11cc162
    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/geojson-cpp-${MASON_VERSION}
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
