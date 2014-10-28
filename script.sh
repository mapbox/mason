#!/usr/bin/env bash

MASON_NAME=libcurl
MASON_VERSION=system
MASON_SYSTEM_PACKAGE=true

. ~/.mason/mason.sh

if [[ ${MASON_PLATFORM} = 'osx' || ${MASON_PLATFORM} = 'ios' ]]; then
    MASON_HEADER_FILE="${MASON_SDK_PATH}/usr/include/curl/curl.h"
    if [ ! -f "${MASON_HEADER_FILE}" ]; then
        mason_error "Can't find header file ${MASON_HEADER_FILE}"
        exit 1
    fi

    MASON_LIBRARY_FILE="${MASON_SDK_PATH}/usr/lib/libcurl.dylib"
    if [ ! -f "${MASON_LIBRARY_FILE}" ]; then
        mason_error "Can't find library file ${MASON_LIBRARY_FILE}"
        exit 1
    fi

    MASON_CFLAGS=
    MASON_LDFLAGS=-lcurl
else
    MASON_CFLAGS=`pkg-config libcurl --cflags`
    MASON_LDFLAGS=`pkg-config libcurl --libs`
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
