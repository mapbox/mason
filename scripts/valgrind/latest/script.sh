#!/usr/bin/env bash

MASON_NAME=valgrind
MASON_VERSION=latest
MASON_LIB_FILE=bin/valgrind

. ${MASON_DIR}/mason.sh

function mason_load_source {
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/valgrind-trunk
    if [[ ! -d ${MASON_BUILD_PATH} ]]; then
        svn co svn://svn.valgrind.org/valgrind/trunk ${MASON_BUILD_PATH}
    else
        (cd ${MASON_BUILD_PATH} && svn update)
    fi
}

function mason_compile {
    ./autogen.sh
    ./configure ${MASON_HOST_ARG} --prefix=${MASON_PREFIX}
    make -j${MASON_CONCURRENCY}
    make install
}

function mason_ldflags {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
