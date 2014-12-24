#!/usr/bin/env bash

set -x

MASON_NAME=boringssl
MASON_VERSION=d3bcf13
MASON_LIB_FILE=lib/libssl.a

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    git clone https://github.com/ljbade/boringssl.git ${MASON_ROOT}/.build/boringssl/src
    pushd ${MASON_ROOT}/.build/boringssl/src
    git checkout a6aabff2e6e95a71b2f966447eebd53e57d8bf83
    popd
    
    cp -r gyp/* ${MASON_ROOT}/.build/boringssl

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/boringssl
}

function mason_compile {
    if [[ "${MASON_PLATFORM}" == "android" ]]; then
        if [[ "${MASON_ANDROID_ARCH}" == "arm" ]]; then
            export GYP_DEFINES="component=static_library OS=android target_arch=arm"
        elif [[ "${MASON_ANDROID_ARCH}" == "x86" ]]; then
            export GYP_DEFINES="component=static_library OS=android target_arch=ia32"
        else
            # Note: mips will be arch "mipsel"
            export GYP_DEFINES="component=static_library OS=android target_arch=${MASON_ANDROID_ARCH}"
        fi
    else
        export GYP_DEFINES="component=static_library target_arch=`uname -m | sed -e "s/i.86/ia32/;s/x86_64/x64/;s/amd64/x64/;s/arm.*/arm/;s/i86pc/ia32/"`"
    fi
    
    export CXX="${MASON_ANDROID_TOOLCHAIN}-g++"
    export CC="${MASON_ANDROID_TOOLCHAIN}-gcc"

    mkdir -p build
    # TODO: this probably doesn't work outside of travis
    ${MASON_DIR:-~/build/mapbox/mason}/deps/run_gyp boringssl.gyp --depth=. --generator-output=./build --format=make
    
    pushd build
    make V=1
    popd
    
    mkdir -p ${MASON_PREFIX}/lib
    if [[ "${MASON_PLATFORM}" == "osx" ]]; then
        cp build/out/Default/libboringssl.a ${MASON_PREFIX}/lib/libssl.a
        cp build/out/Default/libboringssl.a ${MASON_PREFIX}/lib/libcrypto.a
    else
        cp build/out/Default/obj.target/libboringssl.a ${MASON_PREFIX}/lib/libssl.a
        cp build/out/Default/obj.target/libboringssl.a ${MASON_PREFIX}/lib/libcrypto.a
    fi
    cp -r src/include ${MASON_PREFIX}/include
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    echo -L${MASON_PREFIX}/lib -lssl -lcrypto
}

function mason_clean {
    make clean
}

mason_run "$@"
