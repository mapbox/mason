#!/usr/bin/env bash

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"

# inherit from boost base (used for all boost library packages)
source ${HERE}/base.sh

# this package is the one that is header-only
MASON_NAME=boost
MASON_HEADER_ONLY=true

# setup mason env
. ${MASON_DIR}/mason.sh

# source common build functions
source ${HERE}/common.sh

# override default unpacking to just unpack headers
function mason_load_source {
    mason_download \
        https://dl.bintray.com/boostorg/release/${BOOST_VERSION}/source/boost_${BOOST_VERSION_UC}.tar.bz2 \
        ${BOOST_SHASUM}

    mason_extract_tar_bz2 boost_${BOOST_VERSION_UC}/boost

    MASON_BUILD_PATH=${MASON_ROOT}/.build/boost_${BOOST_VERSION_UC}
}

# override default "compile" target for just the header install
function mason_compile {
    patch -N -p1  < ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff
    mkdir -p ${MASON_PREFIX}/include
    cp -r ${MASON_ROOT}/.build/boost_${BOOST_VERSION_UC}/boost ${MASON_PREFIX}/include
}

function mason_ldflags {
    :
}

function mason_static_libs {
    :
}

mason_run "$@"
