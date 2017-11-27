#!/usr/bin/env bash

MASON_NAME=wget
MASON_VERSION=1.19.2
MASON_LIB_FILE=bin/wget

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        http://ftp.gnu.org/gnu/wget/wget-1.19.2.tar.gz \
        07a689125eaf3b050cd62fcb98662eeddc4982db

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    ./configure

    PREFIX=${MASON_PREFIX} \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS} -ldl -lpthread" make

    PREFIX=${MASON_PREFIX} \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS} -ldl -lpthread" make install
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

function mason_clean {
    make clean
}

mason_run "$@"
