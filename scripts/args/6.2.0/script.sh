#!/usr/bin/env bash

MASON_NAME=args
MASON_VERSION=6.2.0
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
    https://github.com/Taywee/${MASON_NAME}/archive/${MASON_VERSION}.tar.gz \
    aeabc113e25d681ebbe4aed4fc56d1fce3efe0f5
    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/${MASON_NAME}
    cp -rv args.hxx ${MASON_PREFIX}/include/${MASON_NAME}
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    : # We're only using the full path to the archive, which is output in static_libs
}

function mason_clean {
    make clean
}

mason_run "$@"
