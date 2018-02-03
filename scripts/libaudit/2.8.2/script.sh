#!/usr/bin/env bash

MASON_NAME=libaudit
MASON_VERSION=2.8.2
MASON_LIB_FILE=lib/libaudit.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/linux-audit/audit-userspace/archive/v${MASON_VERSION}.tar.gz \
        f660846db36da06a0efc8f3aefe1f9fae1525002

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/audit-userspace-${MASON_VERSION}
}

function mason_compile {
    # Add optimization flags since CFLAGS overrides the default (-g -O2)
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    ./autogen.sh
    ./configure \
        --prefix=${MASON_PREFIX} \
        --enable-static \
        --disable-shared \
        --disable-dependency-tracking

    make -j${MASON_CONCURRENCY}
    make install
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    :
}

function mason_static_libs {
    echo ${MASON_PREFIX}/${MASON_LIB_FILE}
}

function mason_clean {
    make clean
}

mason_run "$@"
