#!/usr/bin/env bash

MASON_NAME=node_asan
MASON_VERSION=6.9.4
MASON_LIB_FILE=bin/node

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://nodejs.org/dist/v${MASON_VERSION}/node-v${MASON_VERSION}.tar.gz \
        069155556c8ff510a72f62c47bf0f4443463bceb

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
    mason_step "Loading patch"
    patch -N -p1 < ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff
    SANITIZERS="-fsanitize=address,integer,undefined"
    #if [[ $(uname -s) == 'Linux' ]]; then
        #SANITIZERS="${SANITIZERS},thread,memory"
    #fi
    export CXXFLAGS="${CXXFLAGS} ${SANITIZERS}"
    export CFLAGS="${CFLAGS} ${SANITIZERS}"
    export LDFLAGS="${LDFLAGS} ${SANITIZERS}"
    export BUILD_INTL_FLAGS=
    export DISABLE_V8_I18N=1
    # to compile against libc++: https://bugs.freebsd.org/bugzilla/attachment.cgi?id=168585&action=diff

    if [[ $(uname -s) == 'Darwin' ]]; then
        export CFLAGS="${CFLAGS} ${CFLAGS//-mmacosx-version-min=10.8}"
        export CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++ ${CXXFLAGS//-mmacosx-version-min=10.8}"
        export LDFLAGS="${LDFLAGS} -std=c++11 -stdlib=libc++ ${LDFLAGS//-mmacosx-version-min=10.8}"
    fi
    export CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++"
    export LDFLAGS="${LDFLAGS} -std=c++11 -stdlib=libc++"
    if [[ $(uname -s) == 'Linux' ]]; then
        export LDFLAGS="${LDFLAGS} -lc++abi"
    fi

    echo "making binary"
    BUILDTYPE=Debug PREFIX=${MASON_PREFIX} CONFIG_FLAGS="--debug" make binary -j${MASON_CONCURRENCY}
    ls
    echo "uncompressing binary"
    tar -xf *.tar.gz
    echo "making dir"
    mkdir -p ${MASON_PREFIX}
    echo "making copying"
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
