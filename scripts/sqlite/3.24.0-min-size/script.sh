#!/usr/bin/env bash

MASON_NAME=sqlite
MASON_VERSION=3.24.0-min-size
MASON_LIB_FILE=lib/libsqlite3.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/sqlite3.pc

SQLITE_FILE_VERSION=3240000

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://www.sqlite.org/2018/sqlite-autoconf-${SQLITE_FILE_VERSION}.tar.gz \
        ad4be6eaaa45b26edb54d95d4de9debbd3704c9e

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/sqlite-autoconf-${SQLITE_FILE_VERSION}
}

function mason_compile {
    # Note: setting CFLAGS overrides the default in sqlite of `-g -O2`
    # hence we add back the preferred optimization
    CFLAGS="${CFLAGS} -Os -DNDEBUG" ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --with-pic \
        --disable-shared \
        --disable-dependency-tracking || cat ${MASON_BUILD_PATH}/config.log

    make install -j${MASON_CONCURRENCY}
}

function mason_strip_ldflags {
    shift # -L...
    shift # -lsqlite3
    echo "$@"
}

function mason_ldflags {
    mason_strip_ldflags $(`mason_pkgconfig` --static --libs)
}

function mason_clean {
    make clean
}

mason_run "$@"
