#!/usr/bin/env bash

MASON_NAME=redis
RAW_VERSION=3.2.9
MASON_VERSION=${RAW_VERSION}-configurable-malloc
MASON_LIB_FILE=bin/redis-server

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        http://download.redis.io/releases/redis-${RAW_VERSION}.tar.gz \
        6b2cc5a8223d235d1d2673fa8f806baf1847baa9

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${RAW_VERSION}
}

function mason_compile {
    # This extra cflags export is to ensure -O3 is passed to deps
    export CFLAGS="${CFLAGS:-} -O3 -DNDEBUG"
    make -j${MASON_CONCURRENCY} MALLOC=libc V=1 OPTIMIZATION=-O3
    make PREFIX=${MASON_PREFIX} install
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
