#!/usr/bin/env bash

MASON_NAME=libdrm
MASON_VERSION=2.4.70

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://dri.freedesktop.org/${MASON_NAME}/${MASON_NAME}-${MASON_VERSION}.tar.gz \
        c5d08cea5a7a2c050a727e2deed4e777576e1c7e

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-udev

    make
    make install
}

function mason_clean {
    make clean
}

mason_run "$@"
