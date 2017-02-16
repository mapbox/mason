#!/usr/bin/env bash

MASON_NAME=zstd
MASON_VERSION=1.1.3
MASON_LIB_FILE=lib/libzstd.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/facebook/${MASON_NAME}/archive/v${MASON_VERSION}.tar.gz \
        5e90d0399b3d41851a8ab53db733ab06ab60f484

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    # CFLAGS overrides defaults (-O3), so we add back optimization
    export CFLAGS="${CFLAGS} -O3"
    # install the release version of the command line tools
    make -C programs zstd-release install -j${MASON_CONCURRENCY} PREFIX=${MASON_PREFIX}
    # install the release version of the library
    make -C lib lib-release install -j${MASON_CONCURRENCY} PREFIX=${MASON_PREFIX}
    # Now clear out the shared libs since we only want to package static libs
    rm -f ${MASON_PREFIX}/lib/lib{*.so*,*.dylib}
}

function mason_clean {
    make clean
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_static_libs {
    echo ${MASON_PREFIX}/${MASON_LIB_FILE}
}

function mason_ldflags {
    echo -L${MASON_PREFIX}/lib
}

mason_run "$@"
