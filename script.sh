#!/usr/bin/env bash

MASON_NAME=sqlite
MASON_VERSION=system
MASON_CACHABLE=false

. ~/.mason/mason.sh

if [[ ${MASON_PLATFORM} = 'osx' || ${MASON_PLATFORM} = 'ios' ]]; then
    MASON_HEADER_FILE="${MASON_SDK_PATH}/usr/include/sqlite3.h"
    if [ ! -f "${MASON_HEADER_FILE}" ]; then
        mason_error "Can't find header file ${MASON_HEADER_FILE}"
        exit 1
    fi

    MASON_LIBRARY_FILE="${MASON_SDK_PATH}/usr/lib/libsqlite3.dylib"
    if [ ! -f "${MASON_LIBRARY_FILE}" ]; then
        mason_error "Can't find library file ${MASON_LIBRARY_FILE}"
        exit 1
    fi

    MASON_CFLAGS=
    MASON_LDFLAGS=-lsqlite3
else
    MASON_CFLAGS=`pkg-config sqlite3 --cflags`
    MASON_LDFLAGS=`pkg-config sqlite3 --libs`
fi

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
