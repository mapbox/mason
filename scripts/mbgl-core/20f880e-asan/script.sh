#!/usr/bin/env bash

MASON_NAME=mbgl-core
MASON_VERSION=20f880e-asan
MASON_LIB_FILE=lib/libmbgl-core.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/mapbox-gl-native/tarball/20f880e \
        6a90311c6f6edf36f4b1d85efabda78ade427765

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/mapbox-mapbox-gl-native-20f880e
}

function mason_prepare_compile {
    CCACHE_VERSION=3.3.4
    CMAKE_VERSION=3.8.2
    NINJA_VERSION=1.7.2
    LLVM_VERSION=6.0.1
    ${MASON_DIR}/mason install clang++ ${LLVM_VERSION}
    MASON_LLVM=$(${MASON_DIR}/mason prefix clang++ ${LLVM_VERSION})
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install cmake ${CMAKE_VERSION}
    MASON_CMAKE=$(${MASON_DIR}/mason prefix cmake ${CMAKE_VERSION})
    ${MASON_DIR}/mason install ninja ${NINJA_VERSION}
    MASON_NINJA=$(${MASON_DIR}/mason prefix ninja ${NINJA_VERSION})
}

function mason_compile {
    mkdir -p build
    cd build
    export CXXFLAGS="-fsanitize=address,undefined,integer,leak ${CXXFLAGS}"
    export LDFLAGS="-fsanitize=address,undefined,integer,leak ${LDFLAGS}"
    ${MASON_CMAKE}/bin/cmake ../ \
      -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} -DCMAKE_BUILD_TYPE=Debug \
      -DWITH_NODEJS=OFF -DWITH_ERROR=OFF \
      -G Ninja -DCMAKE_MAKE_PROGRAM=${MASON_NINJA}/bin/ninja \
      -DCMAKE_CXX_COMPILER_LAUNCHER=${MASON_CCACHE}/bin/ccache \
      -DCMAKE_CXX_COMPILER="${MASON_LLVM}/bin/clang++" \
      -DCMAKE_C_COMPILER="${MASON_LLVM}/bin/clang" \
      -DCMAKE_MODULE_LINKER_FLAGS="${LDFLAGS}" \
      -DCMAKE_SHARED_LINKER_FLAGS="${LDFLAGS}" \
      -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
      -DCMAKE_CXX_FLAGS="${CXXFLAGS}"
    ${MASON_NINJA}/bin/ninja mbgl-core -j4
    mkdir -p ${MASON_PREFIX}/include
    mkdir -p ${MASON_PREFIX}/share
    mkdir -p ${MASON_PREFIX}/lib
    cp libmbgl-core.a ${MASON_PREFIX}/lib/
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
