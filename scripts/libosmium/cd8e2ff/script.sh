#!/usr/bin/env bash

MASON_NAME=libosmium
MASON_VERSION=cd8e2ff
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/osmcode/${MASON_NAME}/archive/${MASON_VERSION}.tar.gz \
        1b5750e1bff99779f1ce320d001e3f793d1fcdf1

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-cd8e2ff7ca72f66cd7cadcc1c36f4f0685d0fbb2
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r include/osmium ${MASON_PREFIX}/include/osmium
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}

mason_run "$@"
