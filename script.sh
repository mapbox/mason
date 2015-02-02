#!/usr/bin/env bash

MASON_NAME=sqlite
MASON_VERSION=system
MASON_SYSTEM_PACKAGE=true
MASON_LIB_FILE=include/sqlite3.h

. ${MASON_DIR:-~/.mason}/mason.sh

if [[ ${MASON_PLATFORM} = 'osx' || ${MASON_PLATFORM} = 'ios' ]]; then
    SQLITE_HEADER_DIR="${MASON_SDK_PATH}/usr/include"
    SQLITE_LIBRARY_DIR="${MASON_SDK_PATH}/usr/lib"
    MASON_CFLAGS="-I${MASON_PREFIX}/include"
    MASON_LDFLAGS="-L${MASON_PREFIX}/lib -lsqlite3"

    MASON_HEADER_FILE="${SQLITE_HEADER_DIR}/sqlite3.h"
    if [ ! -f "${MASON_HEADER_FILE}" ]; then
        mason_error "Can't find header file ${MASON_HEADER_FILE}"
        exit 1
    fi

    MASON_LIBRARY_FILE="${SQLITE_LIBRARY_DIR}/libsqlite3.dylib"
    if [ ! -f "${MASON_LIBRARY_FILE}" ]; then
        mason_error "Can't find library file ${MASON_LIBRARY_FILE}"
        exit 1
    fi
else
    SQLITE_HEADER_DIR="`pkg-config sqlite3 --variable=includedir`"
    SQLITE_LIBRARY_DIR="`pkg-config sqlite3 --variable=libdir`"
    MASON_CFLAGS="-I${MASON_PREFIX}/include `pkg-config sqlite3 --cflags-only-other`"
    MASON_LDFLAGS="-I${MASON_PREFIX}/lib `pkg-config sqlite3 --libs-only-other --libs-only-l`"
fi

function mason_system_version {
    mkdir -p "${MASON_PREFIX}"
    cd "${MASON_PREFIX}"
    if [ ! -f version ]; then
        echo "#include <sqlite3.h>
#include <stdio.h>
int main() {
    printf(\"%s\", sqlite3_libversion());
    return 0;
}
" > version.c && ${CC:-cc} version.c $(mason_cflags) $(mason_ldflags) -o version
    fi
    ./version
}

function mason_build {
    mkdir -p ${MASON_PREFIX}/{include,lib}
    ln -sf ${SQLITE_HEADER_DIR}/sqlite3.h ${MASON_PREFIX}/include/
    ln -sf ${SQLITE_LIBRARY_DIR}/libsqlite.* ${MASON_PREFIX}/lib/
}

function mason_cflags {
    echo ${MASON_CFLAGS}
}

function mason_ldflags {
    echo ${MASON_LDFLAGS}
}

mason_run "$@"
