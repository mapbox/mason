#!/usr/bin/env bash

MASON_NAME=node
MASON_VERSION=4.7.3
MASON_LIB_FILE=bin/node

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://nodejs.org/dist/v${MASON_VERSION}/node-v${MASON_VERSION}.tar.gz \
        df5098f93bbd08fa76b17ca7abdb0398755d36bb

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/node-v${MASON_VERSION}
}

function mason_prepare_compile {
    CCACHE_VERSION=3.3.1
    CLANG_VERSION=3.9.1

    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install clang++ ${CLANG_VERSION}
    MASON_CLANG=$(${MASON_DIR}/mason prefix clang++ ${CLANG_VERSION})
    export CXX="${MASON_CCACHE}/bin/ccache ${MASON_CLANG}/bin/clang++"
    export CC="${MASON_CCACHE}/bin/ccache ${MASON_CLANG}/bin/clang"
    export LINK=${MASON_CLANG}/bin/clang++
}

function mason_compile {
    # init a git repo to avoid the nodejs Makefile
    # complaining about changes that it detects in the parent directory
    git init .

    mason_step "Loading patch"
    patch -N -p1 < ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff

    # disable icu
    export BUILD_INTL_FLAGS="--with-intl=none"
    export BUILD_DOWNLOAD_FLAGS=" "
    export DISABLE_V8_I18N=1
    export TAG=v${MASON_VERSION}

    export CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++"
    export LDFLAGS="${LDFLAGS} -std=c++11 -stdlib=libc++"
    if [[ $(uname -s) == 'Linux' ]]; then
        export LDFLAGS="${LDFLAGS} -Wl,--start-group -lc++abi"
    fi

    echo "making binary"
    # we use `make binary` to hook into PORTABLE=1
    V= BUILDTYPE=Debug PREFIX=${MASON_PREFIX} CONFIG_FLAGS="--debug" make binary -j${MASON_CONCURRENCY}
    ls
    echo "uncompressing binary"
    tar -xf *.tar.gz
    echo "making dir"
    mkdir -p ${MASON_PREFIX}
    echo "copying over"
    cp -r node-v${MASON_VERSION}*/* ${MASON_PREFIX}/
    # the release does not package the node debug binary `node_g` so we manually copy over now
    cp out/Debug/node ${MASON_PREFIX}/bin/node_g
}

function mason_cflags {
    :
}

function mason_static_libs {
    :
}


function mason_ldflags {
    :
}

mason_run "$@"
