#!/usr/bin/env bash

MASON_NAME=llnode
MASON_VERSION=1.4.1
MASON_LIB_FILE=lib/llnode.${MASON_DYNLIB_SUFFIX}

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/nodejs/llnode/archive/v${MASON_VERSION}.tar.gz \
        b7ff83ff4686fdeb15517310b6e048c9c864794a

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    LLVM_VERSION=3.9.1
    ${MASON_DIR}/mason install llvm 3.9.1
    LLVM_PATH=$(${MASON_DIR}/mason prefix llvm 3.9.1)
}

function mason_compile {
    git clone --depth 1 https://chromium.googlesource.com/external/gyp.git tools/gyp
    export LDFLAGS="-stdlib=libc++ ${LDFLAGS}"
    ./gyp_llnode -Dlldb_build_dir=${LLVM_PATH} -Dlldb_dir=${LLVM_PATH}
    make -C out/ -j${MASON_CONCURRENCY} V=1
    mkdir -p ${MASON_PREFIX}/lib
    cp ./out/Release/llnode* ${MASON_PREFIX}/lib/
}

function mason_cflags {
    :
}

function mason_ldflags {
    -L${MASON_PREFIX} -llnode
}

function mason_static_libs {
    :
}

mason_run "$@"
