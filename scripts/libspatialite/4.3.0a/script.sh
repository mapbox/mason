#!/usr/bin/env bash

MASON_NAME=libspatialite
MASON_VERSION=4.3.0a
MASON_LIB_FILE=lib/libspatialite.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/spatialite.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        http://www.gaia-gis.it/gaia-sins/libspatialite-${MASON_VERSION}.tar.gz \
        48f89c81628f295eec9d239f5e2209a521da053d

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/libspatialite-${MASON_VERSION}
}

function mason_compile {
    # hence we add back the preferred optimization
    CFLAGS="-O3 ${CFLAGS} -DNDEBUG" ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --with-pic \
        --disable-shared \
        --disable-dependency-tracking

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
