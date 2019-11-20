#!/usr/bin/env bash

MASON_NAME=geometry
MASON_VERSION=7781dd9
MASON_VERSION_FULL=7781dd9305580ba39938c2449bd54cf66e9f50fc
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/geometry.hpp/archive/${MASON_VERSION}.tar.gz \
        411c1720736cb8d1ad0257788d305eb9dd20352b

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
