#!/usr/bin/env bash

MASON_NAME=aws-sdk-cpp
MASON_VERSION=1.8.122
MASON_LIB_FILE=lib/libaws-cpp-sdk-core.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/aws/aws-sdk-cpp/archive/${MASON_VERSION}.tar.gz \
        51a732cefcd9bf0cd117d3bc1edb58b639f519b1

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    CCACHE_VERSION=3.7.2
    CMAKE_VERSION=3.15.2
    LLVM_VERSION=11.0.0
    ${MASON_DIR}/mason install clang++ ${LLVM_VERSION}
    MASON_LLVM=$(${MASON_DIR}/mason prefix clang++ ${LLVM_VERSION})
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install cmake ${CMAKE_VERSION}
    MASON_CMAKE=$(${MASON_DIR}/mason prefix cmake ${CMAKE_VERSION})
}

function mason_compile {
    mkdir -p build
    cd build

    # Take the C++ Standard OUT of CXXFLAGS (it is specified below).
    CXXFLAGS=${CXXFLAGS//-std=c++11/}
    CXXFLAGS=${CXXFLAGS//-stdlib=libc++/}

    CFLAGS=${CXXFLAGS//-mmacosx-version-min=10.8/-mmacosx-version-min=10.13}
    CXXFLAGS=${CXXFLAGS//-mmacosx-version-min=10.8/-mmacosx-version-min=10.13}
    CXXFLAGS="${CXXFLAGS} -stdlib=libc++" # Force use of libc++ (not libstdc++).

    ${MASON_CMAKE}/bin/cmake ../ \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${MASON_PREFIX}" \
        -DCMAKE_INSTALL_MESSAGE="NEVER" \
        -DCMAKE_CXX_COMPILER_LAUNCHER=${MASON_CCACHE}/bin/ccache \
        -DCMAKE_C_COMPILER_LAUNCHER=${MASON_CCACHE}/bin/ccache \
        -DCMAKE_CXX_COMPILER="${MASON_LLVM}/bin/clang++" \
        -DCMAKE_C_COMPILER="${MASON_LLVM}/bin/clang" \
        -DCMAKE_C_FLAGS="${CFLAGS}" \
        -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
        -DCPP_STANDARD=20 \
        -DBUILD_SHARED_LIBS=OFF \
        -DENABLE_TESTING=OFF

    VERBOSE=1 make -j${MASON_CONCURRENCY}
    make install
}

function mason_cflags {
    echo "-isystem ${MASON_PREFIX}/include"
}

function mason_ldflags {
    echo "-L${MASON_PREFIX}/lib -laws-cpp-sdk-core -laws-c-event-stream -laws-c-common -laws-checksums"
}

function mason_static_libs {
   echo "${MASON_PREFIX}/${MASON_LIB_FILE} ${MASON_PREFIX}/lib/libaws-c-event-stream.a ${MASON_PREFIX}/lib/libaws-c-common.a ${MASON_PREFIX}/lib/libaws-checksums.a"
}

function mason_clean {
    make clean
}

mason_run "$@"
