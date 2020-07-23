#!/usr/bin/env bash

MASON_NAME=libpostal
MASON_VERSION=1.1-alpha
MASON_LIB_FILE=bin/libpostal

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/openvenues/${MASON_NAME}/archive/v${MASON_VERSION}.tar.gz \
        b9a4972d0f2fcdc8b24ef91adf4a7749865f4865

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {

    # installation instructions from https://github.com/openvenues/libpostal

    if [[ $(uname -s) == 'Linux' ]]
    then
        yum install curl autoconf automake libtool pkgconfig
    elif [[ $(uname -s) == 'Darwin' ]]
    then
        brew install curl autoconf automake libtool pkg-config
    fi

}

function mason_compile {
    ./bootstrap.sh
    ./configure --datadir=${MASON_ROOT}/libpostal-data/

    if [[ ${TRAVIS_OS_NAME:-} ]]; then
        make VERBOSE=1 -j4
    else
        make VERBOSE=1 -j${MASON_CONCURRENCY}
    fi

    make install

    if [[ $(uname -s) == 'Linux' ]]
    then
        ldconfig
    fi

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