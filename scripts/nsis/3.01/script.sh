#!/usr/bin/env bash

MASON_NAME=nsis
MASON_VERSION=3.01
MASON_LIB_FILE=bin/makensis

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://downloads.sourceforge.net/project/nsis/NSIS%203/${MASON_VERSION}/nsis-${MASON_VERSION}-src.tar.bz2 \
        99614aa0831b1cd93d13c479beda4f424b3e5875

    mason_extract_tar_bz2

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}-src
}

function mason_compile {
    wget http://prdownloads.sourceforge.net/scons/scons-local-2.5.1.tar.gz
    tar xvf scons-local-2.5.1.tar.gz
    perl -i -p -e "s/'__attribute__\(\(__stdcall__\)\)'/'\"__attribute__\(\(__stdcall__\)\)\"'/g" SCons/Config/gnu
    if [[ $(uname -s) == 'Darwin' ]]; then
        perl -i -p -e "s/'-Wall'/'-Wall','-stdlib=libstdc++','-fpermissive'/g" SCons/Config/gnu
        perl -i -p -e "s/'-pthread'/'-stdlib=libstdc++'/g" SCons/Config/gnu
    else
        perl -i -p -e "s/'-Wall'/'-Wall','-fpermissive'/g" SCons/Config/gnu
        perl -i -p -e "s/'-m32'/'-m64'/g" SCons/Config/gnu
    fi
    python scons.py STRIP=0 SKIPUTILS=all PREFIX=/tmp/makensis-data makensis
    mkdir -p ${MASON_PREFIX}/bin
    cp build/urelease/makensis/makensis ${MASON_PREFIX}/bin/
    mkdir -p ${MASON_PREFIX}/share/nsis/Stubs/
    wget https://downloads.sourceforge.net/project/nsis/NSIS%203/${MASON_VERSION}/nsis-${MASON_VERSION}.zip
    unzip nsis-${MASON_VERSION}.zip
    cp nsis-${MASON_VERSION}/Stubs/* ${MASON_PREFIX}/share/nsis/Stubs/
    # note: upon install this needs to be copied in place:
    # mkdir -p /tmp/makensis-data/share/nsis/Stubs/
    # cp -r $(./mason prefix nsis 3.01)/share/nsis/Stubs/* /tmp/makensis-data/share/nsis/Stubs/
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
