#!/usr/bin/env bash

MASON_NAME=any
MASON_VERSION=8fef1e9
MASON_HEADER_ONLY=true

GIT_HASH="8fef1e93710a0edf8d7658999e284a1142c4c020"

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/thelink2012/${MASON_NAME}/archive/${GIT_HASH}.tar.gz \
        73f96c9289ac8ce415b9d8116283d12c2497b5d1

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${GIT_HASH}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/linb/
    cp -r any.hpp ${MASON_PREFIX}/include/linb/
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}


mason_run "$@"
