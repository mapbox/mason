#!/usr/bin/env bash

MASON_NAME=sqlite
MASON_VERSION=system
MASON_SYSTEM_PACKAGE=true

. ${MASON_DIR:-~/.mason}/mason.sh


if [[ ${MASON_PLATFORM} = 'android' ]]; then
    mason_error "Unavailable on platform \"${MASON_PLATFORM}\""
    exit 1
fi

MASON_CFLAGS="-I${MASON_PREFIX}/include"
MASON_LDFLAGS="-L${MASON_PREFIX}/lib"

if [[ ${MASON_PLATFORM} = 'osx' || ${MASON_PLATFORM} = 'ios' ]]; then
    SQLITE_INCLUDE_PREFIX="${MASON_SDK_PATH}/usr/include"
    SQLITE_LIBRARY="${MASON_SDK_PATH}/usr/lib/libsqlite3.${MASON_DYNLIB_SUFFIX}"
    MASON_LDFLAGS="${MASON_LDFLAGS} -lsqlite3"
else
    SQLITE_INCLUDE_PREFIX="`pkg-config sqlite3 --variable=includedir`"
    SQLITE_LIBRARY="`pkg-config sqlite3 --variable=libdir`/libsqlite3.${MASON_DYNLIB_SUFFIX}"
    MASON_CFLAGS="${MASON_CFLAGS} `pkg-config sqlite3 --cflags-only-other`"
    MASON_LDFLAGS="${MASON_LDFLAGS} `pkg-config sqlite3 --libs-only-other --libs-only-l`"
fi

if [ ! -f "${SQLITE_INCLUDE_PREFIX}/sqlite3.h" ]; then
    mason_error "Can't find header file ${SQLITE_INCLUDE_PREFIX}/sqlite3.h"
    exit 1
fi

if [ ! -f "${SQLITE_LIBRARY}" ]; then
    mason_error "Can't find library file ${SQLITE_LIBRARY}"
    exit 1
fi

function mason_system_version {
    mkdir -p "${MASON_PREFIX}"
    cd "${MASON_PREFIX}"
    if [ ! -f version ]; then
        echo "#include <sqlite3.h>
#include <stdio.h>
int main() {
    printf(\"%s\", SQLITE_VERSION);
    return 0;
}
" > version.c && cc version.c $(mason_cflags) -o version
    fi
    ./version
}

function mason_build {
    mkdir -p ${MASON_PREFIX}/{include,lib}
    ln -sf ${SQLITE_INCLUDE_PREFIX}/sqlite3.h ${MASON_PREFIX}/include/
    ln -sf ${SQLITE_LIBRARY} ${MASON_PREFIX}/lib/
}

function mason_cflags {
    echo ${MASON_CFLAGS}
}

function mason_ldflags {
    echo ${MASON_LDFLAGS}
}

mason_run "$@"
