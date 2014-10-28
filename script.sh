#!/usr/bin/env bash

MASON_NAME=libpng
MASON_VERSION=system
MASON_SYSTEM_PACKAGE=true

. ~/.mason/mason.sh

if [ ! $(pkg-config libpng --exists; echo $?) = 0 ]; then
    mason_error "Cannot find libpng with pkg-config"
    exit 1
fi

function mason_system_version {
    mkdir -p "${MASON_PREFIX}"
    cd "${MASON_PREFIX}"
    if [ ! -f version ]; then
        echo "#include <png.h>
#include <stdio.h>
#include <assert.h>
int main() {
    assert(PNG_LIBPNG_VER == png_access_version_number());
    printf(\"%s\", PNG_LIBPNG_VER_STRING);
    return 0;
}
" > version.c && ${CC:-cc} version.c $(mason_cflags) $(mason_ldflags) -o version
    fi
    ./version
}

function mason_compile {
    :
}

function mason_pkgconfig {
    echo 'pkg-config libpng'
}

mason_run "$@"
