#!/usr/bin/env bash

MASON_NAME=kcov
MASON_VERSION=34
MASON_LIB_FILE=bin/kcov

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/SimonKagstrom/kcov/archive/v${MASON_VERSION}.tar.gz \
        ad754b0aac64b2a683839f9369fc3e30948a3d37

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    ${MASON_DIR}/mason install cmake 3.8.2
    MASON_CMAKE=$(${MASON_DIR}/mason prefix cmake 3.8.2)
}

function mason_compile {
    mkdir -p build && cd build
    ${MASON_CMAKE}/bin/cmake .. -DCMAKE_BUILD_TYPE=Relelease
    make
    mkdir -p ${MASON_PREFIX}/bin
    cp src/kcov ${MASON_PREFIX}/bin
}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_clean {
    cd build
    make clean
}

mason_run "$@"
