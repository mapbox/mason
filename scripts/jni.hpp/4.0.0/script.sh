#!/usr/bin/env bash

MASON_NAME=jni.hpp
MASON_VERSION=4.0.0
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
    https://github.com/mapbox/jni.hpp/archive/v${MASON_VERSION}.tar.gz \
    b55c457d4f586fb35ba50b28c677736e0825c64a
    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/jni.hpp-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}
    cp -vR include README.md LICENSE.txt ${MASON_PREFIX}
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