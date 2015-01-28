#!/usr/bin/env bash

MASON_NAME=jpeg
MASON_VERSION=v8d
MASON_LIB_FILE=lib/libjpeg.a

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        http://www.ijg.org/files/jpegsrc.v9a.tar.gz \
        fc3b1eefda3d8a193f9f92a16a1b0c9f56304b6d

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/jpeg-9a
}


function mason_compile {
    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --with-pic \
        --disable-shared \
        --disable-dependency-tracking

    V=1 make install -j${MASON_CONCURRENCY}
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
