#!/usr/bin/env bash

MASON_NAME=luajit
MASON_VERSION=2.0.3
MASON_LIB_FILE=lib/liblua.a

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        http://luajit.org/download/LuaJIT-2.0.3.tar.gz \
        3f8d5a84a38423829765512118bbf26c500b0c06

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    make generic CC=$CC CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" INSTALL_TOP=${MASON_PREFIX} install
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    echo "-L${MASON_PREFIX}/lib -llua"
}

function mason_clean {
    make clean
}

mason_run "$@"
