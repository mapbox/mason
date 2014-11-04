#!/usr/bin/env bash

MASON_NAME=boost
MASON_VERSION=1.57.07

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        http://downloads.sourceforge.net/project/boost/boost/1.57.0/boost_1_57_0.tar.bz2 \
        a97bbc05eeae7a7a6384b3f8c9ff551cf381f041

    mason_extract_tar_bz2

    cp -r ${MASON_ROOT}/.build/boost_1_57_0/boost ${MASON_PREFIX}/include/boost
}

mason_run "$@"
