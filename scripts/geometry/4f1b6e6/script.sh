#!/usr/bin/env bash

MASON_NAME=geometry
MASON_VERSION=4f1b6e6
MASON_VERSION_FULL=4f1b6e688e6766df8a9ae698a814718d4ebcfdb5
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/geometry.hpp/archive/${MASON_VERSION}.tar.gz \
        690052c9a9d15d5a74c9acf63215bdb07734729c

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
