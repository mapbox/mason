#!/usr/bin/env bash

MASON_NAME=pgrouting
MASON_VERSION=2.4.1
MASON_LIB_FILE=lib/worked.txt

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/pgRouting/pgrouting/archive/v${MASON_VERSION}.tar.gz \
       6c5f0429d006b8c5d9d8f5e765113463096abb41

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/pgrouting-${MASON_VERSION}
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
    ${MASON_DIR}/mason install boost_libthread 1.63.0
    BOOST_THREAD_LIB=$(${MASON_DIR}/mason prefix boost_libthread 1.63.0)
    ${MASON_DIR}/mason install postgres 9.6.2
    MASON_POSTGRES=$(${MASON_DIR}/mason prefix postgres 9.6.2)
    export PATH=${MASON_POSTGRES}/bin:${PATH}
}

function mason_compile {
    mason_step "Loading patch"
    mkdir -p build
    rm -rf build/*
    cd build
    export CXXFLAGS="${CXXFLAGS} -I${MASON_GMP}/include -I${MASON_MPFR}/include"
    ${MASON_CMAKE} ../ -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
     -DBoost_USE_STATIC_LIBS=ON \
     -DWITH_DOC=OFF -DBUILD_DOXY=OFF \
     -DBOOST_THREAD_LIBRARIES=${BOOST_THREAD_LIB} \
     -DGMP_LIBRARIES=${MASON_GMP}/lib/libgmp.a \
     -DGMP_INCLUDE_DIR={MASON_GMP}/include \
     -DMPFR_LIBRARIES=${MASON_MPFR}/lib/libmpfr.a \
     -DMPFR_INCLUDE_DIR={MASON_MPFR}/include \
     -DCGAL_INCLUDE_DIR=${MASON_CGAL}/include/ \
     -DCGAL_LIBRARIES=${MASON_CGAL}/lib/ \
     -DCMAKE_CXX_COMPILER_LAUNCHER="${MASON_CCACHE}/bin/ccache" \
     -DCMAKE_BUILD_TYPE=Release \
     -DBoost_INCLUDE_DIR=${MASON_ROOT}/.link/include \
     -DBOOST_LIBRARYDIR=${MASON_ROOT}/.link/lib \
     -DSFCGAL_USE_STATIC_LIBS=ON

    make VERBOSE=1 -j${MASON_CONCURRENCY}

    mkdir -p ${MASON_PREFIX}/lib/
    touch ${MASON_PREFIX}/lib/worked.txt
    # TODO: currently gets installed inside inside postgres: let's try to package separately or with postgis?
    make install
}

function mason_ldflags {
    : # We're only using the full path to the archive, which is output in static_libs
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}


mason_run "$@"
