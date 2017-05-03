#!/usr/bin/env bash

MASON_NAME=sparsepp
MASON_VERSION=0.95
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/greg7mdp/sparsepp/archive/v${MASON_VERSION}.tar.gz \
        d6ff87aefacd1802000c9495c5f819974ddf4d6a

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r sparsepp ${MASON_PREFIX}/include/
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}


mason_run "$@"
