#!/usr/bin/env bash

MASON_NAME=mason_test
MASON_VERSION=xcompile
MASON_LIB_FILE=bin/${MASON_NAME}_${MASON_VERSION}

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_setup_build_dir

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_LIB_FILE}

    mkdir -p ${MASON_BUILD_PATH}
    cp $(dirname $0)/Makefile ${MASON_BUILD_PATH}
    cp $(dirname $0)/test.c ${MASON_BUILD_PATH}
}

function mason_compile {
    make
    PREFIX=${MASON_PREFIX} make install
}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

mason_run "$@"
