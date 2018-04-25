#!/usr/bin/env bash

MASON_NAME=libzip
MASON_VERSION=1.5.1
MASON_LIB_FILE=lib/libzip.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/libzip.pc
ZLIB_VERSION=1.2.8

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        http://www.nih.at/libzip/libzip-${MASON_VERSION}.tar.gz \
        c06271ddd5bbe00f8710cce612189c212d6486cd

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/libzip-${MASON_VERSION}
}

function mason_prepare_compile {
    ${MASON_DIR}/mason install zlib ${ZLIB_VERSION}
    MASON_ZLIB=`${MASON_DIR}/mason prefix zlib ${ZLIB_VERSION}`
}

function mason_compile {
    mkdir -p ./build
    rm -rf ./build/*
    cd build

    if [ ${MASON_PLATFORM} = 'android' ]; then
        ${MASON_DIR}/utils/android.sh > toolchain.cmake
        echo ${MASON_ZLIB}

        cmake ../ \
            -DCMAKE_PREFIX_PATH=${MASON_ZLIB} \
            -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
            -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
            -DZIP_STATIC=ON -DBUILD_SHARED_LIBS=OFF \
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
