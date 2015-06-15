#!/usr/bin/env bash

MASON_NAME=geojsonvt
MASON_VERSION=1.1.0
MASON_LIB_FILE=lib/libgtest.a

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/geojson-vt-cpp/archive/v1.1.0.tar.gz \
        8d81b78e7fca0bcbd4b34ddbfbd421773f83dc00

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/geojson-vt-cpp-${MASON_VERSION}
}

function mason_compile {
    # setup mason
    rm -rf .mason
    ln -s ${MASON_DIR:-~/.mason} .mason

    # build
    ./configure
    make -j${MASON_CONCURRENCY}

    # install
    mkdir -p ${MASON_PREFIX}/lib
    cp -v build/Release/libgeojsonvt.a ${MASON_PREFIX}/lib
    cp -vr include ${MASON_PREFIX}
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    :
}

function mason_static_libs {
    echo ${MASON_PREFIX}/lib/libgeojsonvt.a
}

mason_run "$@"
