#!/usr/bin/env bash

MASON_NAME=cgal
MASON_VERSION=4.9
MASON_LIB_FILE=lib/libCGAL.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/CGAL/cgal/releases/download/releases/CGAL-${MASON_VERSION}/CGAL-${MASON_VERSION}.tar.xz \
        d18e4cd2eb5de9937073c8dc0bc16aa4cf12dd64

    mason_extract_tar_xz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/CGAL-${MASON_VERSION}
}

function mason_prepare_compile {
    CCACHE_VERSION=3.3.1
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install cmake 3.7.2
    MASON_CMAKE=$(${MASON_DIR}/mason prefix cmake 3.7.2)/bin/cmake
    ${MASON_DIR}/mason install gmp 6.1.2
    MASON_GMP=$(${MASON_DIR}/mason prefix gmp 6.1.2)
    ${MASON_DIR}/mason install mpfr 3.1.5
    MASON_MPFR=$(${MASON_DIR}/mason prefix mpfr 3.1.5)
    ${MASON_DIR}/mason install boost 1.63.0
    ${MASON_DIR}/mason link boost 1.63.0
    ${MASON_DIR}/mason install boost_libsystem 1.63.0
    ${MASON_DIR}/mason link boost_libsystem 1.63.0
    ${MASON_DIR}/mason install boost_libthread 1.63.0
    ${MASON_DIR}/mason link boost_libthread 1.63.0
}

function mason_compile {
    mkdir -p build
    rm -rf build/*
    cd build
    # -DCGAL_HEADER_ONLY=ON \
    ${MASON_CMAKE} ../ -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
     -DBoost_USE_STATIC_LIBS=ON \
     -DBUILD_SHARED_LIBS=FALSE \
     -DCMAKE_CXX_COMPILER_LAUNCHER="${MASON_CCACHE}/bin/ccache" \
     -DCMAKE_BUILD_TYPE=Release \
     -DMPFR_LIBRARIES=${MASON_MPFR}/lib \
     -DMPFR_INCLUDE_DIR=${MASON_MPFR}/include \
     -DBoost_INCLUDE_DIR=${MASON_ROOT}/.link/include \
     -DBOOST_LIBRARYDIR=${MASON_ROOT}/.link/lib \
     -DGMP_LIBRARIES=${MASON_GMP}/lib \
     -DGMP_INCLUDE_DIR=${MASON_GMP}/include \

    make -j${MASON_CONCURRENCY} VERBOSE=1
    make install
}

function mason_ldflags {
    : # We're only using the full path to the archive, which is output in static_libs
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}


mason_run "$@"
