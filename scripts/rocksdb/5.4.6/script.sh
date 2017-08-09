#!/usr/bin/env bash

MASON_NAME=rocksdb
MASON_VERSION=5.4.6
MASON_LIB_FILE=lib/librocksdb.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/facebook/${MASON_NAME}/archive/v${MASON_VERSION}.tar.gz \
        b6b98f720dd4b1514c0bd7730af6978b5e48ef73

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    CCACHE_VERSION=3.3.1
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
}

function mason_compile {
    # by default -O2 is used for release builds (https://github.com/facebook/rocksdb/commit/1d08140e817d5908889f59046148ed4d3b1039e5)
    # but this is too conservative
    # we want -O3 for best performance
    perl -i -p -e "s/-O2 -fno-omit-frame-pointer/-O3/g;" Makefile
    export CXX="${MASON_CCACHE}/bin/ccache ${CXX}"
    # explicitly ask for SSE support, which will trigger a warning if not available
    # https://github.com/facebook/rocksdb/blob/9b11d4345a0f01fc3de756e01460bf1b0446f326/INSTALL.md#compilation)
    # https://github.com/facebook/rocksdb/blob/627c9f1abb263ab8d2072a1ac9d30a6e4bc3dde4/build_tools/build_detect_platform#L471
    export USE_SSE=1
    INSTALL_PATH=${MASON_PREFIX} V=1 make install-static -j${MASON_CONCURRENCY}
    if [[ $(uname -s) == 'Darwin' ]]; then
        export EXTRA_LDFLAGS="-lc++"
    fi
    INSTALL_PATH=${MASON_PREFIX} V=1 make tools -j${MASON_CONCURRENCY}
    mkdir -p ${MASON_PREFIX}/bin
    cp ldb ${MASON_PREFIX}/bin/
    # remove debug symbols (200 MB -> 10 MB)
    strip -S ${MASON_PREFIX}/${MASON_LIB_FILE}
}

function mason_static_libs {
    echo ${MASON_PREFIX}/${MASON_LIB_FILE}
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    :
}

mason_run "$@"
