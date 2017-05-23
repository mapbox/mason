#!/usr/bin/env bash

MASON_NAME=pixman
MASON_VERSION=0.34.0
MASON_LIB_FILE=lib/libpixman-1.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/pixman-1.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        http://cairographics.org/releases/pixman-${MASON_VERSION}.tar.gz \
        022e9e5856f4c5a8c9bdea3996c6b199683fce78

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    # Add optimization flags since CFLAGS overrides the default (-g -O2)
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --disable-shared \
        --disable-dependency-tracking \
        --disable-mmx \
        --disable-ssse3 \
        --disable-libpng \
        --disable-gtk

    # The -i and -k flags are to workaround osx bug in pixman tests: Undefined symbols for architecture x86_64: "_prng_state
    V=1 make -j${MASON_CONCURRENCY} -i -k
    make install -i -k
}

mason_run "$@"
