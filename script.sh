#!/usr/bin/env bash

MASON_NAME=boost
MASON_VERSION=1.57.0
MASON_HEADER_ONLY=true

. ${MASON_DIR:-~/.mason}/mason.sh

BOOST_ROOT=${MASON_PREFIX}

function mason_load_source {
    mason_download \
        http://downloads.sourceforge.net/project/boost/boost/1.57.0/boost_1_57_0.tar.bz2 \
        397306fa6d0858c4885fbba7d43a0164dcb7f53e

    mason_extract_tar_bz2 boost_1_57_0/boost

    MASON_BUILD_PATH=${MASON_ROOT}/.build/boost_1_57_0
}

function mason_prefix {
    echo "${BOOST_ROOT}"
}

function mason_compile {
    mkdir -p ${BOOST_ROOT}/include
    mv ${MASON_ROOT}/.build/boost_1_57_0/boost ${BOOST_ROOT}/include
}

function mason_cflags {
    echo "-I${BOOST_ROOT}/include"
}

mason_run "$@"
