#!/usr/bin/env bash

MASON_NAME=or-tools
MASON_VERSION=5.1
MASON_LIB_FILE=lib/libortools.dylib

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/google/or-tools/archive/v5.1.tar.gz \
        3d30004e60acfb27776fc7a8d135adb2e1924dde

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/or-tools-${MASON_VERSION}
}

function mason_prepare_compile {
    cd ${MASON_ROOT}/.build/or-tools-${MASON_VERSION}

    # The following patch to the build script disables some of the more useless
    # and heavyweight parts of the build, like building the automake and autoconf
    # .info docs with TeXinfo.
    SOURCE="${BASH_SOURCE[0]}"
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    patch -p0 < $DIR/patch.diff

}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    echo "-L${MASON_PREFIX}/lib -lortools -lz"
}

function mason_compile {

    make third_party
    make ortoolslibs
    make create_dirs
    make cc_archive

    OR_ARCHIVE_DIR="temp/$(ls -1 temp | head -1)"

    if [[ $(uname -s) == "Linux" ]] ; then
        bash tools/fix_libraries_on_linux.sh
    else
        cp tools/install_libortools_mac.sh ${OR_ARCHIVE_DIR}
        chmod 775 ${OR_ARCHIVE_DIR}/install_libortools_mac.sh
        cd ${OR_ARCHIVE_DIR} && bash ./install_libortools_mac.sh && rm install_libortools_mac.sh
    fi

    mkdir -p "${MASON_PREFIX}/lib"
    mkdir -p "${MASON_PREFIX}/include"

    cp -r "${OR_ARCHIVE_DIR}/lib" "${MASON_PREFIX}/lib"
    cp -r "${OR_ARCHIVE_DIR}/include" "${MASON_PREFIX}/include"

}

function mason_static_libs {
    :
}


echo $DIR

mason_run "$@"
