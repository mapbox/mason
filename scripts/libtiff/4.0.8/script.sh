#!/usr/bin/env bash

MASON_NAME=libtiff
MASON_VERSION=4.0.8
MASON_LIB_FILE=lib/libtiff.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/libtiff-4.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        http://download.osgeo.org/libtiff/tiff-${MASON_VERSION}.tar.gz \
        eb172e79e887fc3b9e4b3e9639c49182ffe563a0

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/tiff-${MASON_VERSION}
}

function mason_prepare_compile {
    JPEG_VERSION=1.5.2
    ${MASON_DIR}/mason install jpeg_turbo ${JPEG_VERSION}
    MASON_JPEG=$(${MASON_DIR}/mason prefix jpeg_turbo ${JPEG_VERSION})
    # depends on sudo apt-get install zlib1g-dev
    ${MASON_DIR}/mason install zlib system
    MASON_ZLIB=$(${MASON_DIR}/mason prefix zlib system)
}


function mason_compile {
    # note CFLAGS overrides defaults (-g -O2 -Wall -W) so we need to add optimization flags back
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    ./configure --prefix=${MASON_PREFIX} \
    ${MASON_HOST_ARG} \
    --enable-static --disable-shared \
    --enable-largefile \
    --enable-defer-strile-load \
    --enable-chunky-strip-read \
    --disable-jpeg12 \
    --disable-dependency-tracking \
    --disable-cxx \
    --with-jpeg-include-dir=${MASON_JPEG}/include \
    --with-jpeg-lib-dir=${MASON_JPEG}/lib \
    --with-zlib-include-dir=${MASON_ZLIB}/include \
    --with-zlib-lib-dir=${MASON_ZLIB}/lib \
    --disable-lzma --disable-jbig --disable-mdi \
    --without-x --disable-pixarlog --disable-next --disable-old-jpeg --disable-logluv \
    --disable-thunder --disable-packbits --disable-ccitt

    make -j${MASON_CONCURRENCY} V=1
    make install
}

function mason_ldflags {
    echo "-ltiff -ljpeg -lz"
}

function mason_clean {
    make clean
}

mason_run "$@"
