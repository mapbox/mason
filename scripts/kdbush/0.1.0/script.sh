#!/usr/bin/env bash

MASON_NAME=kdbush
MASON_VERSION=0.1.0
MASON_HEADER_ONLY=true

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mourner/kdbush.hpp/archive/v${MASON_VERSION}.tar.gz \
        459af213d4b74f8211ad968f4e9daf42ce454ba8

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/kdbush.hpp-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -v include/*.hpp ${MASON_PREFIX}/include
    cp -v README.md LICENSE ${MASON_PREFIX}
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}


mason_run "$@"
