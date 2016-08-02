#!/usr/bin/env bash

MASON_NAME=libosmium
MASON_VERSION=14d92d6
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/osmcode/${MASON_NAME}/archive/14d92d6aa21af1cc301941a43322f262c278efe7.tar.gz \
        14d92d6aa21af1cc301941a43322f262c278efe7

    mason_extract_tar_gz
    ls

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r include/osmium ${MASON_PREFIX}/include/osmium
}

mason_run "$@"
