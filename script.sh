#!/usr/bin/env bash

MASON_NAME=osmium-tool
MASON_VERSION=1.0.0
MASON_LIB_FILE=build/osmium

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/osmcode/osmium-tool/tarball/v1.0.0 \
        a5a1822267e1832e27e805ff9bcfe9217a4f82ad

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/osmcode-osmium-tool-06bcd2c
}

function mason_prepare_compile {
    cd $(dirname ${MASON_ROOT})
    OSMIUM_INCLUDE_DIR=$(pwd)/osmcode-libosmium-5e4af90/include
    wget -O osmium.tar.gz https://github.com/osmcode/libosmium/tarball/v2.0.0
    tar -xzf osmium.tar.gz

    ${MASON_DIR:-~/.mason}/mason install boost 1.57.0
    ${MASON_DIR:-~/.mason}/mason link boost 1.57.0
    ${MASON_DIR:-~/.mason}/mason install boost_libprogram_options 1.57.0
    ${MASON_DIR:-~/.mason}/mason link boost_libprogram_options 1.57.0
    ${MASON_DIR:-~/.mason}/mason install protobuf 2.6.1
    ${MASON_DIR:-~/.mason}/mason link protobuf 2.6.1
    ${MASON_DIR:-~/.mason}/mason install zlib 1.2.8
    ${MASON_DIR:-~/.mason}/mason link zlib 1.2.8
    ${MASON_DIR:-~/.mason}/mason install expat 2.1.0
    ${MASON_DIR:-~/.mason}/mason link expat 2.1.0
    ${MASON_DIR:-~/.mason}/mason install osmpbf 1.3.3
    ${MASON_DIR:-~/.mason}/mason link osmpbf 1.3.3
}

function mason_compile {
    mkdir build
    cd build
    CXXFLAGS="-I${MASON_ROOT}/.link/include" LDFLAGS="-I${MASON_ROOT}/.link/lib" cmake -DOSMIUM_INCLUDE_DIR=${OSMIUM_INCLUDE_DIR} ..
    make
    pwd
    ls $(pwd)
}

function mason_clean {
    make clean
}

function mason_cflags {
    echo "-I${OSMIUM_INCLUDE_DIR}"
}

mason_run "$@"
