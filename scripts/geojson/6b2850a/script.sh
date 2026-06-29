#!/usr/bin/env bash

MASON_NAME=geojson
MASON_VERSION=6b2850a
MASON_VERSION_FULL=6b2850a2778f1a33d0489a373dc06ff494aca3c9
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/geojson-cpp/archive/${MASON_VERSION}.tar.gz \
        4090b3fe9f1c9368f095bf16e3ce12175a7b3b09
    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/geojson-cpp-${MASON_VERSION_FULL}
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
