#!/usr/bin/env bash

MASON_NAME=geojsonvt
MASON_VERSION=6.6.2
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/geojson-vt-cpp/archive/v${MASON_VERSION}.tar.gz \
        a16b1164e8521fedf92d0a04427971057988149f

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/geojson-vt-cpp-${MASON_VERSION}
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
