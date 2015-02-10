#!/usr/bin/env bash

MASON_NAME=mapnik
MASON_VERSION=dev
MASON_LIB_FILE=lib/libmapnik-wkt.a

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/mapnik-3.x
    if [[ ! -d ${MASON_BUILD_PATH} ]]; then
        git clone --depth 1 https://github.com/mapnik/mapnik.git ${MASON_BUILD_PATH}
    else
        (cd ${MASON_BUILD_PATH} && git pull)
    fi
}

function mason_prepare_compile {
    source bootstrap.sh
}

function mason_compile {
    ./configure PREFIX=${MASON_PREFIX} PYTHON_PREFIX=${MASON_PREFIX}
    JOBS=${MASON_CONCURRENCY} make
    make install
}

function mason_cflags {
    ""
}

function mason_ldflags {
    ""
}

function mason_clean {
    make clean
}

mason_run "$@"
