#!/usr/bin/env bash

MASON_NAME=glproto
MASON_VERSION=1.4.17

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://xorg.freedesktop.org/archive/individual/proto/${MASON_NAME}-${MASON_VERSION}.tar.gz \
        70deb35a63fefb63c80d89546f053e80d8d4e83d

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
