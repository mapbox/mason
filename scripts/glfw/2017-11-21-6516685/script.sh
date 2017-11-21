#!/usr/bin/env bash

MASON_NAME=glfw
MASON_VERSION=2017-11-21-6516685
MASON_LIB_FILE=lib/libglfw3.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/glfw3.pc

GLFW_HASH=65166858ffc8e1bb85fd091aaadefcfdc398137e

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/glfw/archive/${GLFW_HASH}.tar.gz \
        aca02fe4f5c849ecfec32f817bdc016e65a04c79

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${GLFW_HASH}
}

function mason_compile {
    rm -rf build
    mkdir build
    cd build
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
        -DCMAKE_INCLUDE_PATH=${MASON_PREFIX}/include \
        -DCMAKE_LIBRARY_PATH=${MASON_PREFIX}/lib \
        -DBUILD_SHARED_LIBS=OFF \
        -DGLFW_BUILD_DOCS=OFF \
        -DGLFW_BUILD_TESTS=OFF \
        -DGLFW_BUILD_EXAMPLES=OFF \
        -DCMAKE_BUILD_TYPE=Release

    make install -j${MASON_CONCURRENCY}
}

function mason_ldflags {
    LIBS=$(`mason_pkgconfig` --static --libs-only-l --libs-only-other)
    echo ${LIBS//-lglfw3/}
}

mason_run "$@"
