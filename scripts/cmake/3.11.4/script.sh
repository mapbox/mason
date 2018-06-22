#!/usr/bin/env bash

MASON_NAME=cmake
MASON_VERSION=3.11.4
MASON_LIB_FILE=bin/cmake

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        http://www.cmake.org/files/v3.11/cmake-${MASON_VERSION}.tar.gz \
        3e92a9fd023945ac2b698d35023e4b82212a963c

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    CCACHE_VERSION="3.4.2"
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    export PATH=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})/bin:${PATH}
}
function mason_compile {
    # Add optimization flags since CFLAGS overrides the default (-g -O2)
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    export CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG"
    # TODO - use mason deps
    ./configure --prefix=${MASON_PREFIX} \
      --no-system-libs \
      --parallel=${MASON_CONCURRENCY} \
      --enable-ccache
    make -j${MASON_CONCURRENCY} VERBOSE=1
    make install
    # remove non-essential things to save on package size
    rm -f ${MASON_PREFIX}/bin/ccmake
    rm -f ${MASON_PREFIX}/bin/cmakexbuild
    rm -f ${MASON_PREFIX}/bin/cpack
    rm -f ${MASON_PREFIX}/bin/ctest
    rm -rf ${MASON_PREFIX}/share/cmake-*/Help
    ls -lh ${MASON_PREFIX}/bin/
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
