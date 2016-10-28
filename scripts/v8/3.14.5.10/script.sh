#!/usr/bin/env bash

MASON_NAME=v8
MASON_VERSION=3.14.5.10
MASON_LIB_FILE=lib/libv8_base.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/${MASON_NAME}/${MASON_NAME}/archive/${MASON_VERSION}.tar.gz \
        2e3700f00d1c1863e7718b2c2bd109cced7217ff

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    git clone --depth 1 https://chromium.googlesource.com/external/gyp build/gyp
    mason_step "Loading patch ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff"
    patch -N -p1 < ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff
    export LDFLAGS="${LDFLAGS:-} -stdlib=libc++"
    make x64.release werror=no -j${MASON_CONCURRENCY}
    mkdir -p ${MASON_PREFIX}/include
    mkdir -p ${MASON_PREFIX}/bin
    mkdir -p ${MASON_PREFIX}/lib
    cp -r include/* ${MASON_PREFIX}/include/
    cp out/x64.release/lib* ${MASON_PREFIX}/lib/
    cp out/x64.release/d8 ${MASON_PREFIX}/bin/
}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
