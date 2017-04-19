#!/usr/bin/env bash

MASON_NAME=mesa
MASON_VERSION=12.0.1

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://mesa.freedesktop.org/archive/${MASON_VERSION}/mesa-${MASON_VERSION}.tar.gz \
        5b5c79bdcd7b32aaac128216ef3fb465831d8cb7

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/mesa-${MASON_VERSION}
}

function mason_prepare_compile {
    ${MASON_DIR}/mason install libdrm 2.4.70
    MASON_LIBDRM=$(${MASON_DIR}/mason prefix libdrm 2.4.70)

    ${MASON_DIR}/mason install glproto 1.4.17
    MASON_GLPROTO=$(${MASON_DIR}/mason prefix glproto 1.4.17)

    ${MASON_DIR}/mason install dri2proto 2.8
    MASON_DRI2PROTO=$(${MASON_DIR}/mason prefix dri2proto 2.8)
}

function mason_compile {
    LIBDRM_CFLAGS="-I${MASON_LIBDRM}/include -I${MASON_LIBDRM}/include/libdrm" \
    LIBDRM_LIBS="-L${MASON_LIBDRM}/lib -ldrm" \
    GLPROTO_CFLAGS="-I${MASON_GLPROTO}/include" \
    GLPROTO_LIBS="-L${MASON_GLPROTO}/lib" \
    DRI2PROTO_CFLAGS="-I${MASON_DRI2PROTO}/include" \
    DRI2PROTO_LIBS="-L${MASON_DRI2PROTO}/lib" \
    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --disable-dri3 \
        --with-egl-platforms=drm \
        --with-dri-drivers=swrast \
        --with-gallium-drivers=swrast \
        --with-llvm-prefix=/usr/lib/llvm-3.4

    make
    make install
}

function mason_clean {
    make clean
}

mason_run "$@"
