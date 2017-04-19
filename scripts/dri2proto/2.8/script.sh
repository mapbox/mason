#!/usr/bin/env bash

MASON_NAME=dri2proto
MASON_VERSION=2.8

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://xorg.freedesktop.org/archive/individual/proto/${MASON_NAME}-${MASON_VERSION}.tar.gz \
        bfede931a3e5b7957cd3c80d852e5efff78998ef

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG}

    make
    make install
}

function mason_clean {
    make clean
}

mason_run "$@"
