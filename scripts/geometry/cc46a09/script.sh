#!/usr/bin/env bash

MASON_NAME=geometry
MASON_VERSION=cc46a09
MASON_VERSION_FULL=cc46a0960d42d971a342d1cf032c55dbe72a5ac2
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/geometry.hpp/archive/${MASON_VERSION}.tar.gz \
        21b5c82bd7d0a877a093747bc089c8fbb41477c8

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/geometry.hpp-${MASON_VERSION_FULL}
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
