#!/usr/bin/env bash

MASON_NAME=mesa
MASON_VERSION=19.1.6
MASON_LIB_FILE=lib/x86_64-linux-gnu/libOSMesa.so.8.0.0

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://mesa.freedesktop.org/archive/mesa-${MASON_VERSION}.tar.xz \
        9849dc6e3f2f6daa30a69dddefb2a1e25f1dfec7

    mason_extract_tar_xz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/mesa-${MASON_VERSION}
}

function mason_prepare_compile {
    python3 -m pip install meson mako
}

function mason_compile {
    meson builddir/ \
      -D shader-cache=true \
      -D buildtype=release \
      -D gles2=true \
      -D shared-llvm=false \
      -D osmesa=gallium \
      -D dri-drivers=[] \
      -D vulkan-drivers=[] \
      -D glx=gallium-xlib \
      -D gallium-drivers=swrast,swr \
      -D prefix=${MASON_PREFIX}
    ninja -C builddir/
    ninja -C builddir/ install
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    # We include just the library path. Users are expected to provide additional flags
    # depending on which of the packaged libraries they actually want to link:
    #
    #    * For GLX: -lGL -lX11
    #    * For EGL: -lGLESv2 -lEGL -lgbm
    #    * For OSMesa: -lOSMesa
    #
    echo -L${MASON_PREFIX}/lib
}

mason_run "$@"
