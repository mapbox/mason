#!/usr/bin/env bash

MASON_NAME=leveldb
MASON_VERSION=1.18
MASON_HEADER_ONLY=true

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/google/leveldb/archive/v${MASON_VERSION}.tar.gz \
        d90b5cadb7a366a2ab27ec8b5ed1ea9445c9a2df

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/leveldb-${MASON_VERSION} 
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r include/leveldb ${MASON_PREFIX}/include/leveldb
}

mason_run "$@"
