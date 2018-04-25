#!/usr/bin/env bash

MASON_NAME=libzip
MASON_VERSION=1.5.1
MASON_LIB_FILE=lib/libzip.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/libzip.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        http://www.nih.at/libzip/libzip-${MASON_VERSION}.tar.gz \
        c06271ddd5bbe00f8710cce612189c212d6486cd

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/libzip-${MASON_VERSION}
}

function mason_prepare_compile {
    CMAKE_VERSION=3.8.2
    CCACHE_VERSION=3.3.1
    if [[ ${MASON_PLATFORM} == 'android' ]] || [[ ${MASON_PLATFORM} == 'ios' ]]; then
        MASON_PLATFORM= MASON_PLATFORM_VERSION= ${MASON_DIR}/mason install cmake ${CMAKE_VERSION}
        MASON_CMAKE=$(MASON_PLATFORM= MASON_PLATFORM_VERSION= ${MASON_DIR}/mason prefix cmake ${CMAKE_VERSION})
        ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
        MASON_PLATFORM= MASON_PLATFORM_VERSION= MASON_CCACHE=$(MASON_PLATFORM= MASON_PLATFORM_VERSION= ${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    fi
}

function mason_compile {
    mkdir -p ./build
    rm -rf ./build/*
    cd build

    if [ ${MASON_PLATFORM} = 'android' ]; then
        ${MASON_DIR}/utils/android.sh > toolchain.cmake

        ${MASON_CMAKE}/bin/cmake ../ \
            -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
            -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
            -DZIP_STATIC=ON -DBUILD_SHARED_LIBS=OFF \
            -DCMAKE_CXX_COMPILER_LAUNCHER="${MASON_CCACHE}/bin/ccache" \
            -DCMAKE_BUILD_TYPE=Release \
            ..
    else
        ${MASON_CMAKE}/bin/cmake ../ \
            -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
            -DZIP_STATIC=ON -DBUILD_SHARED_LIBS=OFF \
            -DCMAKE_CXX_COMPILER_LAUNCHER="${MASON_CCACHE}/bin/ccache" \
            -DCMAKE_BUILD_TYPE=Release \
            ..
    fi
 
    make VERBOSE=1 -j${MASON_CONCURRENCY}
    make install
}

mason_run "$@"
