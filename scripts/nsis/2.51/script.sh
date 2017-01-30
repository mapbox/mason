#!/usr/bin/env bash

MASON_NAME=nsis
MASON_VERSION=2.51
MASON_LIB_FILE=bin/makensis

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://downloads.sourceforge.net/project/nsis/NSIS%202/2.51/nsis-2.51-src.tar.bz2 \
        8248212429503c18ebb4c7d9b1c3e3c6b142604e

    mason_extract_tar_bz2

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}-src
}

function mason_compile {
    wget http://prdownloads.sourceforge.net/scons/scons-local-2.5.1.tar.gz
    tar xvf scons-local-2.5.1.tar.gz
    perl -i -p -e "s/'__attribute__\(\(__stdcall__\)\)'/'\"__attribute__\(\(__stdcall__\)\)\"'/g" SCons/Config/gnu
    perl -i -p -e "s/'-Wall'/'-Wall','-stdlib=libstdc++','-fpermissive'/g" SCons/Config/gnu
    perl -i -p -e "s/'-pthread'/'-stdlib=libstdc++'/g" SCons/Config/gnu
    python scons.py STRIP=0 SKIPUTILS=all PREFIX=./mason_packages/.link makensis
    mkdir -p ${MASON_PREFIX}/bin
    mkdir -p ${MASON_PREFIX}/share/nsis/Stubs/
    cp ${HOME}/Downloads/nsis-2.51/Stubs/* ${MASON_PREFIX}/share/nsis/Stubs/
    cp build/release/makensis/makensis ${MASON_PREFIX}/bin/
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
