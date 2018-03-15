#!/usr/bin/env bash

MASON_NAME=kcov
MASON_VERSION=894e98b
MASON_LIB_FILE=bin/kcov

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/SimonKagstrom/kcov/tarball/${MASON_VERSION} \
        e6265125e3be35cec9f9fdac74c5d92238eafcd5

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/SimonKagstrom-${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    ${MASON_DIR}/mason install cmake 3.8.2
    MASON_CMAKE=$(${MASON_DIR}/mason prefix cmake 3.8.2)
}

function mason_compile {
    mkdir -p build && cd build
    ${MASON_CMAKE}/bin/cmake .. -DCMAKE_BUILD_TYPE=Relelease
    make
    mkdir -p ${MASON_PREFIX}/bin
    cp src/kcov ${MASON_PREFIX}/bin
    # https://github.com/SimonKagstrom/kcov/issues/166
    if [[ $(uname -s) == 'Darwin' ]]; then
        install_name_tool -change @rpath/LLDB.framework/LLDB /Applications/Xcode.app/Contents/SharedFrameworks/LLDB.framework/LLDB ${MASON_PREFIX}/bin/kcov
    fi
}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_clean {
    cd build
    make clean
}

mason_run "$@"
