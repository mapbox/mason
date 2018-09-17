#!/usr/bin/env bash

MASON_NAME=build2
MASON_VERSION=0.8.0
MASON_LIB_FILE=bin/bpkg

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://download.build2.org/${MASON_VERSION}/build2-toolchain-${MASON_VERSION}.tar.gz \
        4ddfaa4f763ea7d99da4a9002f9714715e838e56

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/build2-toolchain-${MASON_VERSION}
}

function mason_compile {
    # NOTE: build2 requires a c++17 capable compiler and it uses CXX11_ABI features in libstdc++ (so it must be built with _GLIBCXX_USE_CXX11_ABI=1)
    # Since we want the binaries to be portable to pre cxx11 abi machines, we statically link against libc++ instead of linking against libstdc++
    # note with clang 4.x will hit "header 'shared_mutex' not found and cannot be generated" because c++17 support is lacking
    LDFLAGS=""
    if [[ $(uname -s) == 'Linux' ]]; then
        LDFLAGS="-Wl,--start-group -lc++ -lc++abi -pthread -lrt"
    fi
    patch -N -p1 < ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff
    ./build.sh --install-dir ${MASON_PREFIX} --verbose 3 --sudo "" --trust yes ${CXX:-clang++} -O3 -stdlib=libc++ ${LDFLAGS}
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
