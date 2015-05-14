#!/usr/bin/env bash

MASON_NAME=iojs
MASON_VERSION=2.0.1
MASON_LIB_FILE=bin/iojs

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    if [ ${MASON_PLATFORM} = 'osx' ]; then
        mason_download \
            https://iojs.org/dist/v2.0.1/iojs-v2.0.1-darwin-x64.tar.gz \
            bc354a98eb9060343d86c3df8f2b75bbd1c5db53ffed923d8e6f89c1ef73078e
    elif [ ${MASON_PLATFORM} = 'linux' ]; then
        mason_download \
            https://iojs.org/dist/v2.0.1/iojs-v2.0.1-linux-x64.tar.gz \
            ae9a1bcd870774198b5ff3bc9534f7c8cc3790af2c16bca5b07e6f4a6b4a065c
    fi

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}
    mv -v */* ${MASON_PREFIX}
}

mason_run "$@"
