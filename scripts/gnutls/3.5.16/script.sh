#!/usr/bin/env bash

MASON_NAME=gnutls
MASON_VERSION=3.5.16
MASON_LIB_FILE=bin/gnutls

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://www.gnupg.org/ftp/gcrypt/gnutls/v3.5/gnutls-3.5.16.tar.xz \
        0666073d691bd92acc9f7fe7facf7c8a0763b9bc

    mason_extract_tar_xz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    ./configure \
        --prefix ${MASON_PREFIX} \
        --with-included-unistring

    make -j${MASON_CONCURRENCY}
    make install
}

function mason_cflags {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
