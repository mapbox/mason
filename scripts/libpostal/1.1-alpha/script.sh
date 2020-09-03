#!/usr/bin/env bash

MASON_NAME=libpostal
MASON_VERSION=1.1-alpha
MASON_LIB_FILE=bin/libpostal_data

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/openvenues/${MASON_NAME}/archive/v${MASON_VERSION}.tar.gz \
        b9a4972d0f2fcdc8b24ef91adf4a7749865f4865

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    ./bootstrap.sh
    ./configure ${MASON_HOST_ARG} --datadir=${MASON_ROOT}/data --prefix=${MASON_PREFIX}
    make VERBOSE=1 -j${MASON_CONCURRENCY}
    make install
    cp src/libpostal ${MASON_PREFIX}/bin/
    cp src/address_parser ${MASON_PREFIX}/bin/
    cp src/language_classifier ${MASON_PREFIX}/bin/
}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_static_libs {
    :
}

mason_run "$@"