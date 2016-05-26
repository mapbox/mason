#!/usr/bin/env bash

MASON_NAME=unique_resource
MASON_VERSION=dev
MASON_HEADER_ONLY=true

GIT_HASH="ac4e6aecda8edc4f4884b0fd0f762228b5f5e770"

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/okdshin/${MASON_NAME}/archive/${GIT_HASH}.tar.gz \
        4946aea4183ed006d0e05b2147691a80f873bd86

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${GIT_HASH}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r unique_resource.hpp ${MASON_PREFIX}/include/
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}


mason_run "$@"
