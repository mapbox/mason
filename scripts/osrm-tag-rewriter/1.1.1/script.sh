#!/usr/bin/env bash

MASON_NAME=osrm-tag-rewriter
MASON_VERSION=1.1.1
MASON_LIB_FILE=bin/osrm-tag-rewriter

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/osrm-tag-rewriter/archive/v${MASON_VERSION}.tar.gz \
        2f8d76252fb2e6cfe059d5d8df6c12b51dad7f84

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    ${MASON_DIR}/mason install cmake 3.7.1
    ${MASON_DIR}/mason link cmake 3.7.1

    ${MASON_DIR}/mason install libosmium 2.13.1
    ${MASON_DIR}/mason link libosmium 2.13.1
    ${MASON_DIR}/mason install utfcpp 2.3.4
    ${MASON_DIR}/mason link utfcpp 2.3.4
    BOOST_VERSION=1.65.1
    ${MASON_DIR}/mason install boost ${BOOST_VERSION}
    ${MASON_DIR}/mason link boost ${BOOST_VERSION}
    ${MASON_DIR}/mason install boost_libprogram_options ${BOOST_VERSION}
    ${MASON_DIR}/mason link boost_libprogram_options ${BOOST_VERSION}
    ${MASON_DIR}/mason install protozero 1.5.2
    ${MASON_DIR}/mason link protozero 1.5.2
    ${MASON_DIR}/mason install expat 2.2.0
    ${MASON_DIR}/mason link expat 2.2.0
    ${MASON_DIR}/mason install bzip2 1.0.6
    ${MASON_DIR}/mason link bzip2 1.0.6
    ${MASON_DIR}/mason install zlib 1.2.8
    ${MASON_DIR}/mason link zlib 1.2.8


    # osrm-tag-rewriter expects a plain unpacking of the upstream libosmium tarball, the mason
    # package strips out some of the cmake stuff that is expected to still be there

    pushd "${MASON_BUILD_PATH}"
    curl -skL "https://github.com/osmcode/libosmium/archive/v2.13.1.tar.gz" -o "${MASON_BUILD_PATH}/osmium.tar.gz"
    gzip -cd osmium.tar.gz | tar xf -
    mkdir -p third_party/libosmium
    mv libosmium-2.13.1/* third_party/libosmium
    rm -rf libosmium-2.13.1
    popd

}

function mason_compile {
    rm -rf build
    mkdir -p build
    cd build
    CMAKE_PREFIX_PATH=${MASON_ROOT}/.link \
    ${MASON_ROOT}/.link/bin/cmake \
        -DENABLE_MASON=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        ..
    # limit concurrency on travis to avoid heavy jobs being killed
    if [[ ${TRAVIS_OS_NAME:-} ]]; then
        make VERBOSE=1 -j4
    else
        make VERBOSE=1 -j${MASON_CONCURRENCY}
    fi

    mkdir -p ${MASON_PREFIX}/bin
    mv osrm-tag-rewriter ${MASON_PREFIX}/bin/osrm-tag-rewriter
}

function mason_clean {
    make clean
}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

mason_run "$@"
