#!/usr/bin/env bash

MASON_NAME=benchmark
MASON_VERSION=1.3.0
MASON_LIB_FILE=lib/libbenchmark.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/google/benchmark/archive/v${MASON_VERSION}.tar.gz \
            722fe92eb48464b5b99323e70a1031fac3b528da

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/benchmark-${MASON_VERSION}
}

function mason_prepare_compile {
    ${MASON_DIR}/mason install cmake 3.5.2
    MASON_CMAKE=$(${MASON_DIR}/mason prefix cmake 3.5.2)
}

function mason_compile {
    rm -rf build
    mkdir -p build
    cd build
    ${MASON_CMAKE}/bin/cmake \
        ${MASON_CMAKE_TOOLCHAIN:-} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${MASON_PREFIX}" \
        -DBENCHMARK_ENABLE_LTO=ON \
        -DBENCHMARK_ENABLE_TESTING=OFF \
        ..

    VERBOSE=1 make install -j${MASON_CONCURRENCY}
}

function mason_cflags {
    echo -isystem ${MASON_PREFIX}/include
}

function mason_ldflags {
    :
}

function mason_static_libs {
    echo ${MASON_PREFIX}/${MASON_LIB_FILE}
}

mason_run "$@"
