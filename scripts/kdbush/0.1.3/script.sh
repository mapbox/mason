#!/usr/bin/env bash

MASON_NAME=kdbush
MASON_VERSION=0.1.3
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mourner/kdbush.hpp/archive/v0.1.3.tar.gz \
        b90b2c2664bf5ba2cdae31d532eb413ba6be68bc

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/kdbush.hpp-0.1.3
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
