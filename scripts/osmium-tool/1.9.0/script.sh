#!/usr/bin/env bash

MASON_NAME=osmium-tool
MASON_VERSION=1.9.0
MASON_LIB_FILE=bin/osmium

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/osmcode/${MASON_NAME}/archive/v1.9.0.tar.gz \
        4218c5dc9fe3ebbd225ead1be419b51dc82578df

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-1.9.0
}

function mason_prepare_compile {
    CCACHE_VERSION=3.3.4
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install cmake 3.8.2
    ${MASON_DIR}/mason link cmake 3.8.2
    ${MASON_DIR}/mason install protozero 1.6.3
    ${MASON_DIR}/mason link protozero 1.6.3
    ${MASON_DIR}/mason install rapidjson 2016-07-20-369de87
    ${MASON_DIR}/mason link rapidjson 2016-07-20-369de87
    ${MASON_DIR}/mason install libosmium 2.14.2
    ${MASON_DIR}/mason link libosmium 2.14.2
    BOOST_VERSION=1.66.0
    ${MASON_DIR}/mason install boost ${BOOST_VERSION}
    ${MASON_DIR}/mason link boost ${BOOST_VERSION}
    ${MASON_DIR}/mason install boost_libprogram_options ${BOOST_VERSION}
    ${MASON_DIR}/mason link boost_libprogram_options ${BOOST_VERSION}
    ${MASON_DIR}/mason install zlib 1.2.8
    ${MASON_DIR}/mason link zlib 1.2.8
    ${MASON_DIR}/mason install expat 2.2.0
    ${MASON_DIR}/mason link expat 2.2.0
    ${MASON_DIR}/mason install bzip2 1.0.6
    ${MASON_DIR}/mason link bzip2 1.0.6
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
        -DBoost_NO_SYSTEM_PATHS=ON \
        -DBoost_USE_STATIC_LIBS=ON \
        ..
    # limit concurrency on travis to avoid heavy jobs being killed
    if [[ ${TRAVIS_OS_NAME:-} ]]; then
        make VERBOSE=1 -j4
    else
        make VERBOSE=1 -j${MASON_CONCURRENCY}
    fi
    make install

}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_static_libs {
    :
}

mason_run "$@"
