#!/usr/bin/env bash

LIB_VERSION=0.4.2
CXXABI=-D_GLIBCXX_USE_CXX11_ABI=1

MASON_NAME=geojson
MASON_VERSION=${LIB_VERSION}
MASON_LIB_FILE=lib/libgeojson.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/geojson-cpp/archive/v${LIB_VERSION}.tar.gz \
        786325c363ed4f11459132181f32a5346dd73527
    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/geojson-cpp-${LIB_VERSION}
}

function mason_compile {
    make clean
    # TODO: we should be using mason provided deps here rather than letting the makefile control them
    # otherwise it is not obvious what rapidjson version geojson-cpp is using
    CXXFLAGS="$CXXFLAGS $CXXABI" MASON=${MASON_DIR}/mason make
    mkdir -p ${MASON_PREFIX}/{include,lib}
    cp -r include/mapbox ${MASON_PREFIX}/include/mapbox
    mv build/libgeojson.a ${MASON_PREFIX}/lib
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    :
}

function mason_static_libs {
    echo ${MASON_PREFIX}/lib/libgeojson.a
}

mason_run "$@"
