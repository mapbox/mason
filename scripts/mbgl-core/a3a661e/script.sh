#!/usr/bin/env bash

MASON_NAME=mbgl-core
MASON_VERSION=a3a661e
MASON_LIB_FILE=lib/libmbgl-core.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
  export MASON_BUILD_PATH=${MASON_ROOT}/.build/mbgl-${MASON_VERSION}
   if [[ ! -d ${MASON_BUILD_PATH} ]]; then
      git clone https://github.com/mapbox/mapbox-gl-native ${MASON_BUILD_PATH}
      (cd ${MASON_BUILD_PATH} && git checkout ${MASON_VERSION} && git submodule update --init)
  fi
}

function mason_prepare_compile {
    CCACHE_VERSION=3.7.2
    CMAKE_VERSION=3.15.2
    NINJA_VERSION=1.9.0
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install cmake ${CMAKE_VERSION}
    MASON_CMAKE=$(${MASON_DIR}/mason prefix cmake ${CMAKE_VERSION})
    ${MASON_DIR}/mason install ninja ${NINJA_VERSION}
    MASON_NINJA=$(${MASON_DIR}/mason prefix ninja ${NINJA_VERSION})
}

function mason_compile {
    mkdir -p build
    rm -rf build/*
    cd build
    # MBGL uses c++14
    export CXXFLAGS="${CXXFLAGS//-std=c++11}"
    # MBGL uses 10.11
    export CXXFLAGS="${CXXFLAGS//-mmacosx-version-min=10.8}"
    
    ${MASON_CMAKE}/bin/cmake ../ \
      -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} -DCMAKE_BUILD_TYPE=Release \
      -DWITH_NODEJS=OFF -DWITH_ERROR=OFF \
      -G Ninja -DCMAKE_MAKE_PROGRAM=${MASON_NINJA}/bin/ninja \
      -DCMAKE_CXX_COMPILER_LAUNCHER=${MASON_CCACHE}/bin/ccache \
      -DCMAKE_CXX_COMPILER="$CXX" \
      -DCMAKE_C_COMPILER="$CC"
    ${MASON_NINJA}/bin/ninja mbgl-core -j4 -v
    mkdir -p ${MASON_PREFIX}/include
    mkdir -p ${MASON_PREFIX}/share
    mkdir -p ${MASON_PREFIX}/lib
    cp libmbgl-core.a ${MASON_PREFIX}/lib/
    # linux does not vendor icu, but rather pulls from mason
    if [ ${MASON_PLATFORM} != 'linux' ]; then
      cp libicu.a ${MASON_PREFIX}/lib/
    fi
    cp -r ../include ${MASON_PREFIX}/
    cp -r ../platform ${MASON_PREFIX}/include/mbgl/
    cp -r ../src ${MASON_PREFIX}/include/mbgl/
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
