#!/usr/bin/env bash

MASON_NAME=zstd
MASON_VERSION=1.1.3
MASON_LIB_FILE=bin/zstd

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/facebook/zstd/archive/v1.1.3.tar.gz \
        5e90d0399b3d41851a8ab53db733ab06ab60f484

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/zstd-${MASON_VERSION}
}

function mason_compile {
    make install PREFIX=${MASON_PREFIX}
}

function mason_clean {
    make clean
}

mason_run "$@"
