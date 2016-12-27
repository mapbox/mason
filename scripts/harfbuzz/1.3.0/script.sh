#!/usr/bin/env bash

MASON_NAME=harfbuzz
MASON_VERSION=1.3.0
MASON_LIB_FILE=lib/libharfbuzz.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/harfbuzz.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-${MASON_VERSION}.tar.bz2 \
        f5674500c67484caa2c9936270d0a100e52f56f0

    mason_extract_tar_bz2

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    FREETYPE_VERSION="2.6.5"
    ${MASON_DIR}/mason install freetype ${FREETYPE_VERSION}
    MASON_FREETYPE=$(${MASON_DIR}/mason prefix freetype ${FREETYPE_VERSION})
    MASON_PLATFORM= ${MASON_DIR}/mason install ragel 6.9
    export PATH=$(MASON_PLATFORM= ${MASON_DIR}/mason prefix ragel 6.9)/bin:$PATH
    export PKG_CONFIG_PATH="$(${MASON_DIR}/mason prefix freetype ${FREETYPE_VERSION})/lib/pkgconfig":$PKG_CONFIG_PATH
    export C_INCLUDE_PATH="${MASON_FREETYPE}/include/freetype2"
    export CPLUS_INCLUDE_PATH="${MASON_FREETYPE}/include/freetype2"
    export LIBRARY_PATH="${MASON_FREETYPE}/lib"
    if [[ ! `which pkg-config` ]]; then
        echo "harfbuzz configure needs pkg-config, please install pkg-config"
        exit 1
    fi
}

function mason_compile {
    export FREETYPE_CFLAGS="-I${MASON_FREETYPE}/include/freetype2"
    export FREETYPE_LIBS="-L${MASON_FREETYPE}/lib -lfreetype -lz"
    export CXXFLAGS="${CXXFLAGS} ${FREETYPE_CFLAGS}"
    export CFLAGS="${CFLAGS} ${FREETYPE_CFLAGS}"
    export LDFLAGS="${LDFLAGS} ${FREETYPE_LIBS}"

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
    : # We're only using the full path to the archive, which is output in static_libs
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_clean {
    make clean
}

mason_run "$@"
