#!/usr/bin/env bash

MASON_NAME=protobuf
MASON_VERSION=3.5.1

if [ ${MASON_PLATFORM} == 'ios' ]; then
    MASON_LIB_FILE=lib-isim-i386/libprotobuf-lite.a
    MASON_PKGCONFIG_FILE=lib-isim-i386/pkgconfig/protobuf-lite.pc
else
    MASON_LIB_FILE=lib/libprotobuf-lite.a
    MASON_PKGCONFIG_FILE=lib/pkgconfig/protobuf-lite.pc
fi

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/google/protobuf/releases/download/v${MASON_VERSION}/protobuf-cpp-${MASON_VERSION}.tar.gz \
        567b4000dc3666fb9de712beddfcf24a80e857f0

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    # note CFLAGS overrides defaults (-O2 -g -DNDEBUG) so we need to add optimization flags back
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    export CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG"

    if [ ${MASON_PLATFORM} == 'android' ]; then
        export LDFLAGS="${LDFLAGS} -llog"
    fi

    export PROTOBUF_XC_ARG=""
    if [ ${MASON_PLATFORM} == 'android' ] || [ ${MASON_PLATFORM} == 'ios' ]; then
        export PROTOBUF_XC_ARG="${PROTOBUF_XC_ARG} --with-protoc=protoc"
    fi

    if [ ${MASON_PLATFORM} == 'ios' ]; then
        export MACOSX_DEPLOYMENT_TARGET="10.8"
    fi

    if [ -f Makefile ]; then
        make distclean
    fi

    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        ${PROTOBUF_XC_ARG} \
        --enable-static --disable-shared \
        --disable-debug --without-zlib \
        --disable-dependency-tracking

    make V=1 -j${MASON_CONCURRENCY}
    make install -j${MASON_CONCURRENCY}
}

function mason_clean {
    make clean
}

mason_run "$@"
