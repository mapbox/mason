#!/usr/bin/env bash

MASON_NAME=libwebp
MASON_VERSION=1.1.0
MASON_LIB_FILE=lib/libwebp.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/webmproject/libwebp/archive/v${MASON_VERSION}.tar.gz \
        6331cb7c45f5e5c2c1473c27590c4b448a099674

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    CCACHE_VERSION=3.7.2
    CMAKE_VERSION=3.15.2
    LLVM_VERSION=11.0.0
    ${MASON_DIR}/mason install clang++ ${LLVM_VERSION}
    MASON_LLVM=$(${MASON_DIR}/mason prefix clang++ ${LLVM_VERSION})
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install cmake ${CMAKE_VERSION}
    MASON_CMAKE=$(${MASON_DIR}/mason prefix cmake ${CMAKE_VERSION})
}

function mason_compile {
    mkdir -p build
    cd build

    ${MASON_CMAKE}/bin/cmake ../ \
        -DCMAKE_BUILD_TYPE=Release \
        -DWEBP_BUILD_ANIM_UTILS=OFF \
        -DWEBP_BUILD_CWEBP=OFF \
        -DWEBP_BUILD_DWEBP=OFF \
        -DWEBP_BUILD_GIF2WEBP=OFF \
        -DWEBP_BUILD_IMG2WEBP=OFF \
        -DWEBP_BUILD_VWEBP=OFF \
        -DWEBP_BUILD_WEBPINFO=OFF \
        -DWEBP_BUILD_WEBPMUX=OFF \
        -DWEBP_BUILD_EXTRAS=OFF \
        -DCMAKE_INSTALL_PREFIX="${MASON_PREFIX}" \
        -DCMAKE_C_COMPILER_LAUNCHER=${MASON_CCACHE}/bin/ccache \
        -DCMAKE_C_COMPILER="${MASON_LLVM}/bin/clang"

    VERBOSE=1 make -j${MASON_CONCURRENCY}
    VERBOSE=1 make install
}

function mason_cflags {
    echo "-isystem ${MASON_PREFIX}/include"
}

function mason_ldflags {
    echo "-L${MASON_PREFIX}/lib -lwebp"
}

function mason_static_libs {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
