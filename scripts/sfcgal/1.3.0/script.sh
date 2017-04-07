#!/usr/bin/env bash

MASON_NAME=sfcgal
MASON_VERSION=1.3.0
MASON_LIB_FILE=lib/libSFCGAL.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/Oslandia/SFCGAL/archive/v${MASON_VERSION}.tar.gz \
        b447a0470cc769b1dee7c6bf7f823388161d859c

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/SFCGAL-${MASON_VERSION}
}

function mason_prepare_compile {
    CCACHE_VERSION=3.3.1
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install cmake 3.7.2
    MASON_CMAKE=$(${MASON_DIR}/mason prefix cmake 3.7.2)/bin/cmake
    ${MASON_DIR}/mason install cgal 4.9
    MASON_CGAL=$(${MASON_DIR}/mason prefix cgal 4.9)
    ${MASON_DIR}/mason install gmp 6.1.2
    MASON_GMP=$(${MASON_DIR}/mason prefix gmp 6.1.2)
    ${MASON_DIR}/mason install mpfr 3.1.5
    MASON_MPFR=$(${MASON_DIR}/mason prefix mpfr 3.1.5)
    ${MASON_DIR}/mason install boost 1.63.0
    ${MASON_DIR}/mason link boost 1.63.0
    ${MASON_DIR}/mason install boost_libdate_time 1.63.0
    ${MASON_DIR}/mason link boost_libdate_time 1.63.0
    ${MASON_DIR}/mason install boost_libserialization 1.63.0
    ${MASON_DIR}/mason link boost_libserialization 1.63.0
}

function mason_compile {
    mason_step "Loading patch"
    patch -N -p1 < ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff
    mkdir -p build
    rm -rf build/*
    cd build
    ${MASON_CMAKE} ../ -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
     -DBoost_USE_STATIC_LIBS=ON \
     -DCGAL_VERSION=4.9 \
     -DCGAL_LIBRARIES=${MASON_CGAL}/lib/ \
     -DCGAL_Core_LIBRARY=${MASON_CGAL}/lib/libCGAL.a \
     -DCGAL_DIR=${MASON_CGAL} \
     -DCGAL_USE_AUTOLINK=OFF \
     -DCGAL_LIBRARY_DIRS=${MASON_CGAL}/lib \
     -DMPFR_DIR=${MASON_MPFR} \
     -DGMP_DIR=${MASON_GMP} \
     -DCMAKE_CXX_COMPILER_LAUNCHER="${MASON_CCACHE}/bin/ccache" \
     -DCMAKE_BUILD_TYPE=Release \
     -DBoost_INCLUDE_DIR=${MASON_ROOT}/.link/include \
     -DBOOST_LIBRARYDIR=${MASON_ROOT}/.link/lib \
     -DSFCGAL_USE_STATIC_LIBS=ON


    # limit concurrency on travis to avoid heavy jobs hanging
    if [[ ${TRAVIS_OS_NAME:-} ]]; then
        make VERBOSE=1 -j4
    else
        make VERBOSE=1 -j${MASON_CONCURRENCY}
    fi
    make install
}

function mason_ldflags {
    : # We're only using the full path to the archive, which is output in static_libs
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}


mason_run "$@"
