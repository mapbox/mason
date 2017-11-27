#!/usr/bin/env bash

MASON_NAME=wget
MASON_VERSION=1.19.2
MASON_LIB_FILE=bin/wget

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        http://ftp.gnu.org/gnu/${MASON_NAME}/${MASON_NAME}-${MASON_VERSION}.tar.gz \
        07a689125eaf3b050cd62fcb98662eeddc4982db

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    ./configure \
        --prefix ${MASON_PREFIX} \
        --with-included-libunistring \
        --with-ssl=openssl \
        --without-libuuid \
        --with-openssl

    make -j${MASON_CONCURRENCY}
    make install
}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
