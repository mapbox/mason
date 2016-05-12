#!/usr/bin/env bash

MASON_NAME=node_asan
MASON_VERSION=4.4.4
MASON_LIB_FILE=bin/node

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://nodejs.org/dist/v${MASON_VERSION}/node-v${MASON_VERSION}.tar.gz \
        71c6b67274b5e042366e7fbba1ee92426ce6fe1a

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/node-v${MASON_VERSION}
}

function mason_compile {
    export CXXFLAGS="${CXXFLAGS} -fsanitize=address"
    export CFLAGS="${CFLAGS} -fsanitize=address"
    export LDFLAGS="${LDFLAGS} -fsanitize=address"
    if [[ $(uname -s) == 'Darwin' ]]; then
        export CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++"
        export LDFLAGS="${LDFLAGS} -std=c++11 -stdlib=libc++"
    fi

    ./configure \
        --prefix=${MASON_PREFIX} \
        --debug
    platform=$(uname -s | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/")
    BINARY_NAME=node-v${MASON_VERSION}-${platform}-x64
    BINARY_TARBALL=${BINARY_NAME}.tar
    make ${BINARY_TARBALL} -j${MASON_CONCURRENCY}
    tar -xf ${BINARY_TARBALL}
    mkdir -p ${MASON_PREFIX}
    cp -r ${BINARY_NAME}/* ${MASON_PREFIX}/
}

function mason_clean {
    make clean
}

mason_run "$@"
