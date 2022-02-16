#!/usr/bin/env bash

LIB_VERSION=1.6.0

MASON_NAME=mbgl-core
MASON_VERSION=${LIB_VERSION}-cxx11abi
# used to target future release
SHA=bf4c734
MASON_LIB_FILE=lib/libmbgl-core.a

. ${MASON_DIR}/mason.sh


function mason_load_source {
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/mapbox-gl-native-maps-v${LIB_VERSION}
     if [[ ! -d ${MASON_BUILD_PATH} ]]; then
        git clone https://github.com/mapbox/mapbox-gl-native ${MASON_BUILD_PATH}
    fi
    (cd ${MASON_BUILD_PATH} && git fetch -v && git checkout ${SHA} && git submodule update --init --recursive)
}

function mason_prepare_compile {
    NINJA_VERSION=1.9.0
    ${MASON_DIR}/mason install ninja ${NINJA_VERSION}
    MASON_NINJA=$(${MASON_DIR}/mason prefix ninja ${NINJA_VERSION})
}

function mason_compile {
    mkdir -p build
    cd build
    cmake ../ \
      -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} -DCMAKE_BUILD_TYPE=Release \
      -DMBGL_WITH_CORE_ONLY=ON \
      -DMBGL_WITH_OPENGL=OFF \
      -DMBGL_WITH_WERROR=OFF \
      -G Ninja -DCMAKE_MAKE_PROGRAM=${MASON_NINJA}/bin/ninja \
      -DCMAKE_CXX_COMPILER="$CXX" \
      -DCMAKE_C_COMPILER="$CC"
    ${MASON_NINJA}/bin/ninja mbgl-core -j4
    echo "making directories at ${MASON_PREFIX}/"
    mkdir -p ${MASON_PREFIX}/include
    mkdir -p ${MASON_PREFIX}/lib
    echo "copying libraries to ${MASON_PREFIX}/lib/"
    cp *.a ${MASON_PREFIX}/lib/
    echo "copying source files to ${MASON_PREFIX}/"
    cp -r ../include ${MASON_PREFIX}/
    cp -r ../platform ${MASON_PREFIX}/
    cp -r ../src ${MASON_PREFIX}/
    cp -r ../vendor ${MASON_PREFIX}/include/mbgl/
}

function mason_cflags {
    :
}

function mason_static_libs {
    :
}

function mason_ldflags {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
