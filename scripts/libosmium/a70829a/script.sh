#!/usr/bin/env bash

MASON_NAME=libosmium
MASON_VERSION=a70829a
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/osmcode/${MASON_NAME}/archive/${MASON_VERSION}.tar.gz \
        0e9afddf610af1aa7783733710baa5b089ed5419

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-a70829a42251b45c73fa584444aa0e6c064292da
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r include/osmium ${MASON_PREFIX}/include/osmium
    cp include/gdalcpp.hpp ${MASON_PREFIX}/include/
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}

mason_run "$@"
