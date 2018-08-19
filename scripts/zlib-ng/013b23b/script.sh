#!/usr/bin/env bash

MASON_NAME=zlib-ng
MASON_VERSION=013b23b
MASON_LIB_FILE=lib/libz.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/zlib.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/Dead2/zlib-ng/tarball/013b23b \
        873a7c61470786f87917e2b98bc87cd9fa6b8bf8

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/Dead2-zlib-ng-013b23b
}

function mason_compile {
    # Add optimization flags since CFLAGS overrides the default (-g -O2)
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    ./configure \
        --prefix=${MASON_PREFIX} \
        --shared \
        --zlib-compat --64
    make install -j${MASON_CONCURRENCY}
}

mason_run "$@"
