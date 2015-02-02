#!/usr/bin/env bash

MASON_NAME=libcurl
MASON_VERSION=system
MASON_SYSTEM_PACKAGE=true
MASON_LIB_FILE=include/curl/curl.h

. ${MASON_DIR:-~/.mason}/mason.sh

if [[ ${MASON_PLATFORM} = 'osx' || ${MASON_PLATFORM} = 'ios' ]]; then
    CURL_HEADER_DIR="${MASON_SDK_PATH}/usr/include"
    CURL_LIBRARY_DIR="${MASON_SDK_PATH}/usr/lib"
    MASON_CFLAGS="-I${MASON_PREFIX}/include"
    MASON_LDFLAGS="-L${MASON_PREFIX}/lib -lcurl"

    MASON_HEADER_FILE="${CURL_HEADER_DIR}/curl/curl.h"
    if [ ! -f "${MASON_HEADER_FILE}" ]; then
        mason_error "Can't find header file ${MASON_HEADER_FILE}"
        exit 1
    fi

    MASON_LIBRARY_FILE="${CURL_LIBRARY_DIR}/libcurl.dylib"
    if [ ! -f "${MASON_LIBRARY_FILE}" ]; then
        mason_error "Can't find library file ${MASON_LIBRARY_FILE}"
        exit 1
    fi
else
    CURL_HEADER_DIR="`pkg-config libcurl --variable=includedir`"
    CURL_LIBRARY_DIR="`pkg-config libcurl --variable=libdir`"
    MASON_CFLAGS="-I${MASON_PREFIX}/include `pkg-config libcurl --cflags-only-other`"
    MASON_LDFLAGS="-I${MASON_PREFIX}/lib `pkg-config libcurl --libs-only-other --libs-only-l`"
fi

function mason_system_version {
    mkdir -p "${MASON_PREFIX}"
    cd "${MASON_PREFIX}"
    if [ ! -f version ]; then
        echo "#include <curl/curl.h>
#include <stdio.h>
int main() {
    printf(\"%s\", curl_version_info(CURLVERSION_NOW)->version);
    return 0;
}
" > version.c && ${CC:-cc} version.c $(mason_cflags) $(mason_ldflags) -o version
    fi
    ./version
}

function mason_build {
    mkdir -p ${MASON_PREFIX}/{include,lib}
    ln -sf ${CURL_HEADER_DIR}/curl ${MASON_PREFIX}/include/
    ln -sf ${CURL_LIBRARY_DIR}/libcurl.* ${MASON_PREFIX}/lib/
}

function mason_cflags {
    echo ${MASON_CFLAGS}
}

function mason_ldflags {
    echo ${MASON_LDFLAGS}
}

mason_run "$@"
