#!/usr/bin/env bash

MASON_NAME=geometry
MASON_VERSION=1.0.0
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/geometry.hpp/archive/v${MASON_VERSION}.tar.gz \
        021de4e4f0d2a0e4b3fd6fff254ea043921a5ded

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/geometry.hpp-${MASON_VERSION}
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
