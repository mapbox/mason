#!/usr/bin/env bash

MASON_NAME=node
MASON_VERSION=6.14.3-g
MASON_VERSION2=6.14.3
MASON_LIB_FILE=bin/node

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/nodejs/node/archive/v${MASON_VERSION2}.tar.gz \
        ee37fb7e5594b3240df99e6fdea2cc55e887e77d

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/node-${MASON_VERSION2}
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

    mason_step "Loading patch"
    patch -N -p1 < ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff

    # disable icu
    export BUILD_INTL_FLAGS="--with-intl=none"
    export BUILD_DOWNLOAD_FLAGS=" "
    export DISABLE_V8_I18N=1
    export TAG=
    export BUILDTYPE=Debug
    export DISTTYPE=release
    export CONFIG_FLAGS="--debug --shared-zlib"

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
    cp -r node-v${MASON_VERSION2}*/* ${MASON_PREFIX}/
    # the 'make binary' target does not package the node debug binary `node_g` so we manually copy over now
    cp out/Debug/node ${MASON_PREFIX}/bin/node
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
