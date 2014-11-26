#!/usr/bin/env bash

MASON_NAME=jpeg
MASON_VERSION=v8d
MASON_LIB_FILE=lib/libjpeg.a

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        http://www.ijg.org/files/jpegsrc.v8d.tar.gz \
        8847587af6570b90595105dc6824188b16015c22

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/jpeg-8d
}


function mason_compile {
    CFLAGS="-fPIC" ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --with-pic \
        --disable-shared \
        --disable-dependency-tracking

    make install -j${MASON_CONCURRENCY}
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    echo -L${MASON_PREFIX}/lib -ljpeg
}

function mason_clean {
    make clean
}

mason_run "$@"
