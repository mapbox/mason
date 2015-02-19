#!/usr/bin/env bash

MASON_NAME=iojs
MASON_VERSION=1.2.0
MASON_LIB_FILE=bin/iojs

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    if [ ${MASON_PLATFORM} = 'osx' ]; then
        mason_download \
            https://iojs.org/dist/v1.2.0/iojs-v1.2.0-darwin-x64.tar.gz \
            202d45f836ec45db11a58c4a3ced9774ea2144a2
    elif [ ${MASON_PLATFORM} = 'linux' ]; then
        mason_download \
            https://iojs.org/dist/v1.2.0/iojs-v1.2.0-linux-x64.tar.gz \
            350df861e161c34b97398fc1b440f3d80f174cf9
    fi

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}
    mv -v */* ${MASON_PREFIX}
}

mason_run "$@"
