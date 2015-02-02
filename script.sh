#!/usr/bin/env bash

MASON_NAME=boost
MASON_VERSION=system
MASON_SYSTEM_PACKAGE=true
MASON_LIB_FILE=include/boost/version.hpp

. ${MASON_DIR:-~/.mason}/mason.sh

if [ -d '/usr/local/include/boost' ]; then
    BOOST_ROOT='/usr/local'
elif [ -d '/usr/include/boost' ]; then
    BOOST_ROOT='/usr'
else
    mason_error "Cannot find Boost"
    exit 1
fi

function mason_system_version {
    mkdir -p "${MASON_PREFIX}"
    cd "${MASON_PREFIX}"
    if [ ! -f version ]; then
        echo "#include <boost/version.hpp>
#include <stdio.h>
int main() {
    printf(\"%d.%d.%d\", BOOST_VERSION / 100000, BOOST_VERSION / 100 % 1000, BOOST_VERSION % 100);
    return 0;
}
" > version.c && cc version.c $(mason_cflags) $(mason_ldflags) -o version
    fi
    ./version
}

function mason_build {
    if [ ${MASON_PLATFORM} = 'ios' ]; then
        mkdir -p ${MASON_PREFIX}/include
        ln -sf ${BOOST_ROOT}/include/boost ${MASON_PREFIX}/include/
    else
        mkdir -p ${MASON_PREFIX}/{include,lib}
        ln -sf ${BOOST_ROOT}/include/boost ${MASON_PREFIX}/include/
        ln -sf ${BOOST_ROOT}/lib/libboost_* ${MASON_PREFIX}/lib/
    fi
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    if [ ${MASON_PLATFORM} = 'ios' ]; then
        echo ""
    else
        echo "-L${MASON_PREFIX}/lib"
    fi
}

mason_run "$@"
