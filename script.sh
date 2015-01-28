#!/usr/bin/env bash

MASON_NAME=libuv
MASON_VERSION=0.10.32
MASON_LIB_FILE=lib/libuv.a

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/libuv/libuv/archive/v${MASON_VERSION}.tar.gz \
        09f74ec846a9a19a3868f2ae3ecd3f2219b36674

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/libuv-${MASON_VERSION}
}

function mason_compile {
    CFLAGS="-fPIC" make libuv.a -j${MASON_CONCURRENCY}
    mkdir -p lib
    mv libuv.a "${MASON_LIB_FILE}"
    mkdir -p "${MASON_PREFIX}"
    cp -rv lib include "${MASON_PREFIX}"
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    if [ ${MASON_PLATFORM} = 'osx' ]; then
        echo "-lpthread -ldl -framework CoreFoundation -framework CoreServices"
    elif [ ${MASON_PLATFORM} = 'ios' ]; then
        echo "-lpthread -ldl"
    elif [ ${MASON_PLATFORM} = 'linux' ]; then
        echo "-lpthread -ldl -lrt"
    fi
}

function mason_clean {
    make clean
}

mason_run "$@"
