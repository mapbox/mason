#!/usr/bin/env bash

MASON_NAME=apitrace
MASON_VERSION=2018-05-16-7fadfba
GITSHA=7fadfba5cbeada0e198b0ab8f83d88db43b66790
MASON_LIB_FILE=bin/apitrace

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/apitrace/apitrace/archive/${GITSHA}.tar.gz \
        62f9850e382362da90b86195ea95b893519e084f

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${GITSHA}
}

function mason_compile {
    cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=RelWithDebInfo -DENABLE_GUI=FALSE \
                -DCMAKE_INSTALL_PREFIX="${MASON_PREFIX}"
    make -C build
    make -C build install
}

function mason_ldflags {
    :
}

function mason_cflags {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
