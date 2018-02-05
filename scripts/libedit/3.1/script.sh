#!/usr/bin/env bash

MASON_NAME=libedit
MASON_VERSION=3.1
MASON_LIB_FILE=lib/libedit.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://thrysoee.dk/editline/libedit-20170329-${MASON_VERSION}.tar.gz \
        7e64a1cfa3f16e7fa854e0c8cc3756ce7b793919

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/libedit-20170329-${MASON_VERSION}
}

function mason_compile {
    # Add optimization flags since CFLAGS overrides the default (-g -O2)
    # HAVE__SECURE_GETENV allows compatibility with old (circa ubuntu precise) glibc
    # per https://sourceware.org/glibc/wiki/Tips_and_Tricks/secure_getenv
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    if [[ $(uname -s) == 'Linux' ]]; then
        export CFLAGS="${CFLAGS} -DHAVE___SECURE_GETENV=1"
    fi
    ./configure \
        --prefix=${MASON_PREFIX} \
        --enable-static \
        --disable-shared \
        --disable-dependency-tracking

    V=1 make -j${MASON_CONCURRENCY}
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
