#!/usr/bin/env bash

MASON_NAME=node
MASON_VERSION=8.11.3
MASON_LIB_FILE=bin/node

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/nodejs/node/archive/v${MASON_VERSION}.tar.gz \
        fa5631c244128c5ef6c51708be0f4b6918d123eb

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/node-${MASON_VERSION}
}

function mason_prepare_compile {
    CCACHE_VERSION=3.3.4

    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    export CXX="${MASON_CCACHE}/bin/ccache ${CXX:-clang++}"
    export CC="${MASON_CCACHE}/bin/ccache ${CC:-clang}"
    export LINK=${CXX:-clang++}
}

function mason_compile {
    # init a git repo to avoid the nodejs Makefile
    # complaining about changes that it detects in the parent directory
    git init .

    # disable icu
    export BUILD_INTL_FLAGS="--with-intl=none"
    export BUILD_DOWNLOAD_FLAGS=" "
    export DISABLE_V8_I18N=1
    export TAG=
    export BUILDTYPE=Release
    export DISTTYPE=release
    export CONFIG_FLAGS="--shared-zlib"

    export CXXFLAGS="${CXXFLAGS} -std=c++11"
    export LDFLAGS="${LDFLAGS} -std=c++11"

    if [[ $(uname -s) == 'Darwin' ]]; then
        export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
        export LDFLAGS="${LDFLAGS} -stdlib=libc++"
    fi

    echo "making binary"
    # we use `make binary` to hook into PORTABLE=1
    # note, pass V=1 to see compile args (default off to avoid breaking the 4 GB log limit on travis)
    V=  PREFIX=${MASON_PREFIX}  make binary -j${MASON_CONCURRENCY}
    ls
    echo "uncompressing binary"
    tar -xf *.tar.gz
    echo "making dir"
    mkdir -p ${MASON_PREFIX}
    echo "copying over"
    cp -r node-v${MASON_VERSION}*/* ${MASON_PREFIX}/
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
