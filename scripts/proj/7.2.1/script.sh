#!/usr/bin/env bash

MASON_NAME=proj
MASON_VERSION=7.2.1
MASON_LIB_FILE=lib/libproj.a
GRID_VERSION="1.8"
SQLITE_VERSION=3.34.0
LIBTIFF_VERSION=4.0.7
JPEG_TURBO_VERSION=1.5.1

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://download.osgeo.org/proj/proj-${MASON_VERSION}.tar.gz \
        92b57d23bf86fc985bf33f5bf82b3ada0820cab0

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    ${MASON_DIR}/mason install sqlite ${SQLITE_VERSION}
    MASON_SQLITE=$(${MASON_DIR}/mason prefix sqlite ${SQLITE_VERSION})
    ${MASON_DIR}/mason install libtiff ${LIBTIFF_VERSION}
    MASON_LIBTIFF=$(${MASON_DIR}/mason prefix libtiff ${LIBTIFF_VERSION})
    ${MASON_DIR}/mason install jpeg_turbo ${JPEG_TURBO_VERSION}
}

function mason_compile {
    export PATH="${MASON_ROOT}/.link/bin:${PATH}"
    export PKG_CONFIG_PATH="${MASON_SQLITE}/lib/pkgconfig:${MASON_LIBTIFF}/lib/pkgconfig"
    export CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG"
    ./configure --prefix=${MASON_PREFIX} \
    ${MASON_HOST_ARG} \
    --enable-static \
    --disable-shared \
    --disable-dependency-tracking \
    --without-curl

    make -j${MASON_CONCURRENCY}
    make install
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    echo "-lproj"
}

function mason_clean {
    make clean
}

mason_run "$@"
