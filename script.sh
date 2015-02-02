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

function mason_load_source {
    :
}

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

function mason_compile {
    mkdir -p ${MASON_PREFIX}/{include,lib}
    ln -sf ${BOOST_ROOT}/include/boost ${MASON_PREFIX}/include/
    ln -sf ${BOOST_ROOT}/lib/libboost_* ${MASON_PREFIX}/lib/
}

function mason_prefix {
    echo "${BOOST_ROOT}"
}

function mason_cflags {
    echo "-I${BOOST_ROOT}/include"
}

function mason_ldflags {
    echo "-L${BOOST_ROOT}/lib"
}

mason_run "$@"
