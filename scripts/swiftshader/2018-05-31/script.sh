#!/usr/bin/env bash

MASON_NAME=swiftshader
MASON_VERSION=2018-05-31
MASON_LIB_FILE=lib/libGLESv2.${MASON_DYNLIB_SUFFIX}

. ${MASON_DIR}/mason.sh

function mason_load_source {
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/swiftshader-${MASON_VERSION}
    if [ ! -d "${MASON_BUILD_PATH}" ]; then
        git clone --branch release-${MASON_VERSION} https://github.com/mapbox/swiftshader.git "${MASON_BUILD_PATH}"
    fi
    git -C "${MASON_BUILD_PATH}" clean -fdxebuild
    git -C "${MASON_BUILD_PATH}" checkout release-${MASON_VERSION}
    git -C "${MASON_BUILD_PATH}" submodule update --init
}

function mason_compile {
    cmake -H. -Bbuild \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${MASON_PREFIX}" \
        -DBUILD_GLES_CM=NO \
        -DBUILD_SAMPLES=NO \
        -DREACTOR_BACKEND=LLVM
    make -C build -j${MASON_CONCURRENCY} libEGL libGLESv2

    rm -rf "${MASON_PREFIX}"
    mkdir -p "${MASON_PREFIX}/lib"
    cp -av build/lib{EGL,GLESv2}.*${MASON_DYNLIB_SUFFIX}* "${MASON_PREFIX}/lib/"
    rsync -av "include" "${MASON_PREFIX}" --exclude Direct3D --exclude GL --exclude GLES
}

function mason_cflags {
    echo "-isystem ${MASON_PREFIX}/include"
}

function mason_ldflags {
    echo "-L${MASON_PREFIX}/lib -lEGL -lGLESv2"
}

function mason_static_libs {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
