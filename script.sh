#!/usr/bin/env bash

MASON_NAME=node
MASON_VERSION=0.10.36
MASON_LIB_FILE=bin/node

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    if [ ${MASON_PLATFORM} = 'osx' ]; then
        mason_download \
            http://nodejs.org/dist/v0.10.36/node-v0.10.36-darwin-x64.tar.gz \
            ff5e9ab73aa025473d5601e6b71a13d0208caae9
    elif [ ${MASON_PLATFORM} = 'linux' ]; then
        mason_download \
            http://nodejs.org/dist/v0.10.36/node-v0.10.36-linux-x64.tar.gz \
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
