#!/usr/bin/env bash

MASON_NAME=popt
MASON_VERSION=1.16
MASON_LIB_FILE=lib/libpopt.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/popt.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://fossies.org/linux/misc/popt-${MASON_VERSION}.tar.gz \
        598c52b4e1085e5e9e8323642ed73302b69cadc3

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/popt-${MASON_VERSION}
}

function mason_compile {
    export CFLAGS="${CFLAGS:-} -O3 -DNDEBUG"

    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --with-pic \
        --disable-shared \
        --disable-dependency-tracking

    V=1 VERBOSE=1 make install -j${MASON_CONCURRENCY}
}

function mason_strip_ldflags {
    shift # -L...
    shift # -lpng16
    echo "$@"
}

function mason_ldflags {
    mason_strip_ldflags $(`mason_pkgconfig` --static --libs)
}

function mason_clean {
    make clean
}

mason_run "$@"
