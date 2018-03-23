#!/usr/bin/env bash

MASON_NAME=boringssl
MASON_VERSION=855d504
MASON_LIB_FILE=lib/libssl.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
    if [[ ! -d ${MASON_BUILD_PATH} ]]; then
        git clone https://boringssl.googlesource.com/boringssl ${MASON_BUILD_PATH}
        (cd ${MASON_BUILD_PATH} && git checkout ${MASON_VERSION})
    fi
}

function mason_prepare_compile {
    CCACHE_VERSION=3.3.1
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install cmake 3.7.1
    ${MASON_DIR}/mason link cmake 3.7.1
}

function mason_compile {
    rm -rf build
    mkdir -p build
    cd build
    CMAKE_PREFIX_PATH=${MASON_ROOT}/.link \
    ${MASON_ROOT}/.link/bin/cmake \
        -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
        -DCMAKE_CXX_COMPILER_LAUNCHER="${MASON_CCACHE}/bin/ccache" \
        -DCMAKE_BUILD_TYPE=Release \
        ..
    make VERBOSE=1 -j${MASON_CONCURRENCY}
    mkdir -p ${MASON_PREFIX}
    mkdir -p ${MASON_PREFIX}/lib
    mkdir -p ${MASON_PREFIX}/include
    cp -r ../include/openssl ${MASON_PREFIX}/include/openssl
    cp ssl/libssl.a ${MASON_PREFIX}/lib/
    cp crypto/libcrypto.a ${MASON_PREFIX}/lib/
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    echo -L${MASON_PREFIX}/lib -lboringssl
}

function mason_clean {
    make clean
}

mason_run "$@"
