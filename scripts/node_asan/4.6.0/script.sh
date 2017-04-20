#!/usr/bin/env bash

MASON_NAME=node_asan
MASON_VERSION=4.6.0
MASON_LIB_FILE=bin/node

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://nodejs.org/dist/v${MASON_VERSION}/node-v${MASON_VERSION}.tar.gz \
        861dbe14fff9522e41385b4394ce6d9f12c8374e

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/node-v${MASON_VERSION}
}

function mason_prepare_compile {
    ${MASON_DIR}/mason install clang++ 3.9.0
    MASON_CLANG=$(${MASON_DIR}/mason prefix clang++ 3.9.0)
    export CXX=${MASON_CLANG}/bin/clang++
    export LINK=${MASON_CLANG}/bin/clang++
    export CC=${MASON_CLANG}/bin/clang
}

function mason_compile {
    mason_step "Loading patch"
    patch -N -p1 < ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff
    export CXXFLAGS="${CXXFLAGS} -fsanitize=address"
    export CFLAGS="${CFLAGS} -fsanitize=address"
    export LDFLAGS="${LDFLAGS} -fsanitize=address"
    export BUILD_INTL_FLAGS=
    export DISABLE_V8_I18N=1
    # to compile against libc++: https://bugs.freebsd.org/bugzilla/attachment.cgi?id=168585&action=diff

    if [[ $(uname -s) == 'Darwin' ]]; then
        export CFLAGS="${CFLAGS} ${CFLAGS//-mmacosx-version-min=10.8}"
        export CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++ ${CXXFLAGS//-mmacosx-version-min=10.8}"
        export LDFLAGS="${LDFLAGS} -std=c++11 -stdlib=libc++ ${LDFLAGS//-mmacosx-version-min=10.8}"
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

function mason_clean {
    make clean
}

mason_run "$@"
