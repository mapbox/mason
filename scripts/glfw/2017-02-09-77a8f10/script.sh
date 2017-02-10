#!/usr/bin/env bash

MASON_NAME=glfw
MASON_VERSION=2017-02-09-77a8f10
MASON_LIB_FILE=lib/libglfw3.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/glfw3.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/glfw/glfw/archive/77a8f103d8f8519d1a723bbd8b0490b448f1f430.tar.gz \
        0bb1b8abc915a7a9237d902b4981341c3bce3de5

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/glfw-77a8f103d8f8519d1a723bbd8b0490b448f1f430
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
