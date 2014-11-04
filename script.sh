#!/usr/bin/env bash

MASON_NAME=boost
MASON_VERSION=1.57.0

. ${MASON_DIR:-~/.mason}/mason.sh

BOOST_ROOT=${MASON_PREFIX}

function mason_load_source {
    mason_download \
        http://downloads.sourceforge.net/project/boost/boost/1.57.0/boost_1_57_0.tar.bz2 \
        397306fa6d0858c4885fbba7d43a0164dcb7f53e

    mason_extract_tar_bz2

    mkdir -p ${BOOST_ROOT}/include
    cp -r ${MASON_ROOT}/.build/boost_1_57_0/boost ${BOOST_ROOT}/include/boost
}

function mason_prefix {
    echo "${BOOST_ROOT}"
}

function mason_cflags {
    echo "-I${BOOST_ROOT}/include"
}

mason_run "$@"
