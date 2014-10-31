#!/usr/bin/env bash

MASON_NAME=jpeg
MASON_VERSION=v8d
MASON_LIB_FILE=libjpeg.a

. ~/.mason/mason.sh

function mason_load_source {
    mason_download \
        http://www.ijg.org/files/jpegsrc.v8d.tar.gz \
        8847587af6570b90595105dc6824188b16015c22

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/jpeg-8d
}


function mason_compile {
    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --disable-shared \
        --disable-dependency-tracking

    make install -j${MASON_CONCURRENCY}
}

function mason_cflags {
    echo $(`mason_pkgconfig` --static --libs)
}

function mason_ldflags {
    echo $(`mason_pkgconfig` --static --libs)
}

function mason_clean {
    make clean
}

mason_run "$@"