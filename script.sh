#!/usr/bin/env bash

MASON_NAME=libuv
MASON_VERSION=0.10.28
MASON_LIB_FILE=lib/libuv.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/libuv.pc

. ~/.mason/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/joyent/libuv/archive/v${MASON_VERSION}.tar.gz \
        a3fc90eca125e49979103d748be436a438083cb7

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/libuv-${MASON_VERSION}
}

function mason_compile {
    make libuv.a -j${MASON_CONCURRENCY}
    mkdir -p lib/pkgconfig
    mv libuv.a lib

    if [ ${MASON_PLATFORM} = 'osx' ]; then
        LIBUV_LIBS="-lpthread -ldl"
    elif [ ${MASON_PLATFORM} = 'ios' ]; then
        LIBUV_LIBS="-lpthread -ldl"
    elif [ ${MASON_PLATFORM} = 'linux' ]; then
        LIBUV_LIBS="-pthread -ldl -lrt"
    fi

    echo 'prefix='${MASON_PREFIX}'
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: '${MASON_NAME}'
Version: '${MASON_VERSION}'
Description: multi-platform support library with a focus on asynchronous I/O.

Libs: -L${libdir} -luv '${LIBUV_LIBS}'
Cflags: -I${includedir}' > lib/pkgconfig/libuv.pc

    mkdir -p "${MASON_PREFIX}"
    cp -rv lib include "${MASON_PREFIX}"
}

function mason_clean {
    make clean
}

mason_run $1
