#!/usr/bin/env bash

MASON_NAME=lz4
MASON_VERSION=1.8.2
MASON_LIB_FILE=lib/liblz4.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/liblz4.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/lz4/lz4/archive/v1.8.2.tar.gz \
        26676ba8d3e6c616dc2377afddc6ffb84c260d1d

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    PREFIX=${MASON_PREFIX} make BUILD_SHARED=no install -C lib
}

function mason_clean {
    make clean
}

mason_run "$@"
