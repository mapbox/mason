#!/usr/bin/env bash

MASON_NAME=geometry
MASON_VERSION=822020d
MASON_VERSION_FULL=822020d31529c76bfa7f2a0c6630715bbc17e8b1
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/geometry.hpp/archive/${MASON_VERSION}.tar.gz \
        392d27bd1b8004e3984e4193c793763dcc75ffdb

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
