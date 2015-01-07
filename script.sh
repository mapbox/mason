#!/usr/bin/env bash

MASON_NAME=harfbuzz
MASON_VERSION=2cd5323531dcd800549b2cb1cb51d708e72ab2d8
MASON_LIB_FILE=lib/libharfbuzz.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/harfbuzz.pc

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/behdad/harfbuzz/archive/${MASON_VERSION}.tar.gz \
        671c4cd7d31013de720e98c7e1f4bbfa06871fce

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    ${MASON_DIR:-~/.mason}/mason install freetype 2.5.4
    MASON_FREETYPE=$(${MASON_DIR:-~/.mason}/mason prefix freetype 2.5.4)
}

function mason_compile {
    FREETYPE_CFLAGS="-I${MASON_FREETYPE}/include/freetype2"
    FREETYPE_LIBS="-L${MASON_FREETYPE}/lib -lfreetype -lz"
    CXXFLAGS="${CXXFLAGS} -DHB_NO_MT ${FREETYPE_CFLAGS}"
    CFLAGS="${CFLAGS} -DHB_NO_MT ${FREETYPE_CFLAGS}"
    LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS} ${FREETYPE_LIBS}"

    NOCONFIGURE=1 ./autogen.sh ${HOST_ARG}
    ./configure --prefix=${MASON_PREFIX} ${MASON_HOST_ARG} \
     --enable-static \
     --disable-shared \
     --disable-dependency-tracking \
     --with-icu=no \
     --with-cairo=no \
     --with-glib=no \
     --with-gobject=no \
     --with-graphite2=no \
     --with-freetype \
     --with-uniscribe=no \
     --with-coretext=no

    make -j${MASON_CONCURRENCY} V=1
    make install
}

function mason_ldflags {
    echo "-lharfbuzz"
}

function mason_clean {
    make clean
}

mason_run "$@"
