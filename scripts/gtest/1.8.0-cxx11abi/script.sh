#!/usr/bin/env bash

LIB_VERSION=1.8.0

MASON_NAME=gtest
MASON_VERSION=${LIB_VERSION}-cxx11abi
MASON_LIB_FILE=lib/libgtest.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/google/googletest/archive/release-${LIB_VERSION}.tar.gz \
        a40df33faad4a1fb308282148296ad7d0df4dd7a

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/googletest-release-${LIB_VERSION}/googletest
}

function mason_compile {
    cd "${MASON_BUILD_PATH}"

    mkdir -p ${MASON_PREFIX}/lib
    mkdir -p ${MASON_PREFIX}/include/gtest
    cp -rv include ${MASON_PREFIX}

    rm -rf build
    mkdir -p build
    cd build

    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
        -DCMAKE_CXX_FLAGS="${CXXFLAGS:-} -D_GLIBCXX_USE_CXX11_ABI=1" \
        ..
    make VERBOSE=1 -j${MASON_CONCURRENCY} gtest
    cp -v libgtest.a ${MASON_PREFIX}/lib
}

function mason_cflags {
    echo -isystem ${MASON_PREFIX}/include -I${MASON_PREFIX}/include
}

function mason_static_libs {
    echo ${MASON_PREFIX}/lib/libgtest.a
}

mason_run "$@"
