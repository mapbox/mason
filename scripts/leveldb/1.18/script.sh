#!/usr/bin/env bash

MASON_NAME=leveldb
MASON_VERSION=1.18
MASON_HEADER_ONLY=true

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/google/leveldb/tarball/v${MASON_VERSION} \
        803d69203a62faf50f1b77897310a3a1fcae712b

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/leveldb-${MASON_VERSION} 
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r include/leveldb ${MASON_PREFIX}/include/leveldb
}

mason_run "$@"
