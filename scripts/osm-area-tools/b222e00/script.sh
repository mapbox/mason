#!/usr/bin/env bash

MASON_NAME=osm-area-tools
MASON_VERSION=b222e00
MASON_LIB_FILE=bin/oat_problem_report

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/osmcode/${MASON_NAME}/archive/${MASON_VERSION}.tar.gz \
        6f207546992b090a385de864679697520b2e9b89

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-b222e00ba128b0f0254eb8e4d8a1f8f8ba9be8e3
}

function mason_prepare_compile {
    CCACHE_VERSION=3.3.4
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install cmake 3.8.2
    ${MASON_DIR}/mason link cmake 3.8.2
    ${MASON_DIR}/mason install utfcpp 2.3.4
    ${MASON_DIR}/mason link utfcpp 2.3.4
    ${MASON_DIR}/mason install protozero 1.5.2
    ${MASON_DIR}/mason link protozero 1.5.2
    ${MASON_DIR}/mason install rapidjson 2016-07-20-369de87
    ${MASON_DIR}/mason link rapidjson 2016-07-20-369de87
    ${MASON_DIR}/mason install libosmium a70829a
    ${MASON_DIR}/mason link libosmium a70829a
    GDAL_VERSION=2.1.3
    ${MASON_DIR}/mason install libgdal ${GDAL_VERSION}
    ${MASON_DIR}/mason link libgdal ${GDAL_VERSION}
    ${MASON_DIR}/mason install libtiff 4.0.7
    ${MASON_DIR}/mason link libtiff 4.0.7
    ${MASON_DIR}/mason install proj 4.9.3
    ${MASON_DIR}/mason link proj 4.9.3
    ${MASON_DIR}/mason install jpeg_turbo 1.5.1
    ${MASON_DIR}/mason link jpeg_turbo 1.5.1
    ${MASON_DIR}/mason install libpng 1.6.28
    ${MASON_DIR}/mason link libpng 1.6.28
    ${MASON_DIR}/mason install expat 2.2.0
    ${MASON_DIR}/mason link expat 2.2.0
    ${MASON_DIR}/mason install libpq 9.6.2
    ${MASON_DIR}/mason link libpq 9.6.2
    BOOST_VERSION=1.63.0
    ${MASON_DIR}/mason install boost ${BOOST_VERSION}
    ${MASON_DIR}/mason link boost ${BOOST_VERSION}
    ${MASON_DIR}/mason install boost_libprogram_options ${BOOST_VERSION}
    ${MASON_DIR}/mason link boost_libprogram_options ${BOOST_VERSION}
    ${MASON_DIR}/mason install zlib 1.2.8
    ${MASON_DIR}/mason link zlib 1.2.8
    ${MASON_DIR}/mason install expat 2.2.0
    ${MASON_DIR}/mason link expat 2.2.0
    ${MASON_DIR}/mason install bzip2 1.0.6
    ${MASON_DIR}/mason link bzip2 1.0.6
    ${MASON_DIR}/mason install geos 3.6.1
    ${MASON_DIR}/mason link geos 3.6.1
}

function mason_compile {
    rm -rf build
    mkdir -p build
    cd build
    EXTRA_FLAGS=""
    if [[ $(uname -s) == 'Darwin' ]]; then
        EXTRA_FLAGS="-liconv"
    fi
    LINKER_FLAGS="${MASON_ROOT}/.link/lib/libtiff.a ${MASON_ROOT}/.link/lib/libpng.a ${MASON_ROOT}/.link/lib/libjpeg.a ${MASON_ROOT}/.link/lib/libproj.a ${MASON_ROOT}/.link/lib/libpq.a ${EXTRA_FLAGS}"
    if [[ $(uname -s) == 'Linux' ]]; then
        LINKER_FLAGS="-Wl,--start-group ${LINKER_FLAGS} -ldl"
    fi

    CMAKE_PREFIX_PATH=${MASON_ROOT}/.link \
    ${MASON_ROOT}/.link/bin/cmake \
        -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
        -DCMAKE_CXX_COMPILER_LAUNCHER="${MASON_CCACHE}/bin/ccache" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_EXE_LINKER_FLAGS="${LINKER_FLAGS}" \
        ..
    # limit concurrency on travis to avoid heavy jobs being killed
    if [[ ${TRAVIS_OS_NAME:-} ]]; then
        make VERBOSE=1 -j4
    else
        make VERBOSE=1 -j${MASON_CONCURRENCY}
    fi
    make install

}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_static_libs {
    :
}

mason_run "$@"
