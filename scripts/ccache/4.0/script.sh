#!/usr/bin/env bash

MASON_NAME=ccache
MASON_VERSION=4.0
MASON_LIB_FILE=bin/ccache

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/${MASON_NAME}/${MASON_NAME}/releases/download/v${MASON_VERSION}/${MASON_NAME}-${MASON_VERSION}.tar.gz \
        cda12d016e6e020e094cbde68e4e24712471841b

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    ${MASON_DIR}/mason install cmake 3.18.1
    ${MASON_DIR}/mason link cmake 3.18.1
}

function mason_compile {
    rm -rf build
    mkdir -p build
    cd build
    CMAKE_PREFIX_PATH=${MASON_ROOT}/.link \
    ${MASON_ROOT}/.link/bin/cmake \
        -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
        -DCMAKE_BUILD_TYPE=Release \
        -DZSTD_FROM_INTERNET=ON \
        ..
    make VERBOSE=1 -j${MASON_CONCURRENCY}
    make install
}

function mason_ldflags {
    :
}

function mason_cflags {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
