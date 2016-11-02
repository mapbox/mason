#!/usr/bin/env bash

MASON_NAME=mesa
MASON_VERSION=13.0.0
MASON_LIB_FILE=lib/libOSMesa.so
MASON_PKGCONFIG_FILE=lib/pkgconfig/osmesa.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://mesa.freedesktop.org/archive/${MASON_VERSION}/mesa-${MASON_VERSION}.tar.gz \
        bba4f687bc0b0066961424dd0ae2ca053ffc1fcb

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/mesa-${MASON_VERSION}
}

function mason_prepare_compile {
    true
}

function mason_compile {
    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --disable-gles1 \
        --disable-gles2 \
        --disable-dri \
        --disable-dri3 \
        --disable-glx \
        --disable-egl \
        --disable-driglx-direct \
        --enable-gallium-osmesa \
        --enable-texture-float \
        --with-gallium-drivers=swrast

    make
    make install
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    echo $(`mason_pkgconfig` --libs)
}

function mason_clean {
    make clean
}

mason_run "$@"
