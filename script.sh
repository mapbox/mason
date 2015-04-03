#!/usr/bin/env bash

MASON_NAME=boost
MASON_VERSION=1.58.0
MASON_HEADER_ONLY=true

. ${MASON_DIR:-~/.mason}/mason.sh

BOOST_ROOT=${MASON_PREFIX}

function mason_load_source {
    mason_download \
        http://sourceforge.net/projects/boost/files/boost/1.58.0.beta.1/boost_1_58_0_b1.tar.bz2/download \
        c5091923813e319340d86cb52d94de96b21ed701

    mason_extract_tar_bz2 boost_1_58_0_b1/boost

    MASON_BUILD_PATH=${MASON_ROOT}/.build/boost_1_58_0_b1
}

function mason_prefix {
    echo "${BOOST_ROOT}"
}

function mason_compile {
    mkdir -p ${BOOST_ROOT}/include
    mv ${MASON_ROOT}/.build/boost_1_58_0_b1/boost ${BOOST_ROOT}/include
}

function mason_cflags {
    echo "-I${BOOST_ROOT}/include"
}

mason_run "$@"
