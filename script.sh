#!/usr/bin/env bash

MASON_NAME=zlib
MASON_VERSION=system
MASON_SYSTEM_PACKAGE=true

. ${MASON_DIR:-~/.mason}/mason.sh

if [[ ${MASON_PLATFORM} = 'osx' || ${MASON_PLATFORM} = 'ios' ]]; then
    MASON_HEADER_FILE="${MASON_SDK_PATH}/usr/include/zlib.h"
    if [ ! -f "${MASON_HEADER_FILE}" ]; then
        mason_error "Can't find header file ${MASON_HEADER_FILE}"
        exit 1
    fi

    MASON_LIBRARY_FILE="${MASON_SDK_PATH}/usr/lib/libz.dylib"
    if [ ! -f "${MASON_LIBRARY_FILE}" ]; then
        mason_error "Can't find library file ${MASON_LIBRARY_FILE}"
        exit 1
    fi

    MASON_CFLAGS=
    MASON_LDFLAGS=-lz
elif [[ ${MASON_PLATFORM} = 'android' ]]; then
    MASON_HEADER_FILE="${MASON_SDK_PATH}/usr/include/zlib.h"
    if [ ! -f "${MASON_HEADER_FILE}" ]; then
        mason_error "Can't find header file ${MASON_HEADER_FILE}"
        exit 1
    fi

    MASON_LIBRARY_FILE="${MASON_SDK_PATH}/usr/lib/libz.so"
    if [ ! -f "${MASON_LIBRARY_FILE}" ]; then
        mason_error "Can't find library file ${MASON_LIBRARY_FILE}"
        exit 1
    fi

    MASON_CFLAGS=
    MASON_LDFLAGS=-lz
else
    MASON_CFLAGS=`pkg-config zlib --cflags`
    MASON_LDFLAGS=`pkg-config zlib --libs`
fi

function mason_system_version {
    mkdir -p "${MASON_PREFIX}"
    cd "${MASON_PREFIX}"
    if [ ! -f version ]; then
        echo "#include <zlib.h>
#include <stdio.h>
#include <assert.h>
int main() {
    assert(ZLIB_VERSION[0] == zlibVersion()[0]);
    printf(\"%s\", ZLIB_VERSION);
    return 0;
}
" > version.c && ${CC:-cc} version.c $(mason_cflags) $(mason_ldflags) -o version
    fi
    ./version
}

function mason_compile {
    :
}

function mason_cflags {
    echo ${MASON_CFLAGS}
}

function mason_ldflags {
    echo ${MASON_LDFLAGS}
}

mason_run "$@"
