#!/usr/bin/env bash

MASON_NAME=glfw
MASON_VERSION=2017-04-07-f40d085
MASON_LIB_FILE=lib/libglfw3.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/glfw3.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/glfw/archive/f40d085e3ca4cd8d834f8bc47d9a729ae7d737e2.tar.gz \
        ae6bcfe0620bd80f103139c24474b2a2bcda8222

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/glfw-f40d085e3ca4cd8d834f8bc47d9a729ae7d737e2
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
