#!/usr/bin/env bash

MASON_NAME=llnode
MASON_VERSION=1.7.1
MASON_LIB_FILE=lib/plugin.${MASON_DYNLIB_SUFFIX}

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/nodejs/llnode/archive/v${MASON_VERSION}.tar.gz \
        1bc3ff2925770b42f3b93995e1d67a3f3b547d93

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    LLVM_VERSION=6.0.1
    ${MASON_DIR}/mason install llvm ${LLVM_VERSION}
    LLVM_PATH=$(${MASON_DIR}/mason prefix llvm ${LLVM_VERSION})
    # needed for node-gyp
    NODE_VERSION=6.14.3
    ${MASON_DIR}/mason install node ${NODE_VERSION}
    export NODE_PATH=$(${MASON_DIR}/mason prefix node ${NODE_VERSION})
    echo `which node`
    echo `which npm`
}

function mason_compile {
    # ../src/llv8.cc:256:43: error: expected ')'
     #snprintf(tmp, sizeof(tmp), " fn=0x%016" PRIx64, fn.raw());
    # need to define STDC macros since libc++ adheres to spec: http://en.cppreference.com/w/cpp/types/integer
    export CXXFLAGS="-stdlib=libc++ ${CXXFLAGS} -I${LLVM_PATH}/include -D__STDC_LIMIT_MACROS -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS"
    export LDFLAGS="-stdlib=libc++ ${LDFLAGS}"
    export CXX="${LLVM_PATH}/bin/clang++"
    patch -N -p1 < ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff
    # per the llvm package, on linux we statically link libc++ for full portability
    # while on osx we use the system libc++
    if [[ $(uname -s) == 'Linux' ]] && [[ -f ${LLVM_PATH}/lib/libc++.a ]]; then
        export LDFLAGS="-Wl,--whole-archive ${LLVM_PATH}/lib/libc++.a ${LLVM_PATH}/lib/libc++abi.a ${LDFLAGS}"
    fi
    if [[ $(uname -s) == 'Darwin' ]] && [[ -f ${LLVM_PATH}/lib/libc++.a ]]; then
        export LDFLAGS="${LLVM_PATH}/lib/libc++.a ${LLVM_PATH}/lib/libc++abi.a ${LDFLAGS}"
    fi
    echo '{' > config.gypi
    echo "'lldb_header_dir':'${LLVM_PATH}/include',"  >> config.gypi
    echo "'lldb_lib_dir':'${LLVM_PATH}/lib'"  >> config.gypi
    echo '}' >> config.gypi
    ${NODE_PATH}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js configure --clang=1 -- -Dlldb_lib_dir=${LLVM_PATH}/lib
    V=1 ${NODE_PATH}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js build --clang=1
    ls build/Release/*
    mkdir -p ${MASON_PREFIX}/lib
    cp build/Release/plugin.* ${MASON_PREFIX}/lib/
}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_static_libs {
    :
}

mason_run "$@"
