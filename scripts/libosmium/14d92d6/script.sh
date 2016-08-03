#!/usr/bin/env bash

MASON_NAME=libosmium
MASON_VERSION=14d92d6
MASON_HEADER_ONLY=true

LONG_GITSHA=14d92d6aa21af1cc301941a43322f262c278efe7

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/osmcode/${MASON_NAME}/archive/${LONG_GITSHA}.tar.gz \
        d3062f084324461bdad695bdad07a8122e463bb9

    mason_extract_tar_gz
    ls

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${LONG_GITSHA}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r include/osmium ${MASON_PREFIX}/include/osmium
}

mason_run "$@"
