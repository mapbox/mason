#!/usr/bin/env bash

MASON_NAME=broken
MASON_VERSION=0.0.0
MASON_LIB_FILE=lib/this.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
    mkdir -p ${MASON_BUILD_PATH}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/lib
    touch ${MASON_PREFIX}/lib/this.a
}

mason_run "$@"
