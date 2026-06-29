#!/usr/bin/env bash

MASON_NAME=zlib-cloudflare
MASON_VERSION=e55212b
MASON_LIB_FILE=lib/libz.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/zlib.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/cloudflare/zlib/tarball/e55212b \
        a76b4cce9dbbe578b72081e92e3c6488ee6d5872

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/cloudflare-zlib-e55212b
}

function mason_compile {
    # Add optimization flags since CFLAGS overrides the default (-g -O2)
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    ./configure \
        --prefix=${MASON_PREFIX} \
        --shared
    make install -j${MASON_CONCURRENCY}
}

mason_run "$@"
