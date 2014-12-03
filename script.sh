#!/usr/bin/env bash

MASON_NAME=glfw
MASON_VERSION=e1ae9af5
MASON_LIB_FILE=lib/libglfw3.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/glfw3.pc

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/glfw/glfw/archive/e1ae9af5a08f283a7edc2c0c59738a8da66a8074.tar.gz \
        b11811ec786143548bb4e994ce6bca0bc49e3fca

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/glfw-e1ae9af5a08f283a7edc2c0c59738a8da66a8074
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
