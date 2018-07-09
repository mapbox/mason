#!/usr/bin/env bash

LIB_VERSION=3.5.1

MASON_NAME=protobuf
MASON_VERSION=${LIB_VERSION}

if [ "${MASON_PLATFORM}" == "ios" ]; then
    MASON_LIB_FILE=lib-isim-i386/libprotobuf.a
    MASON_PKGCONFIG_FILE=lib-isim-i386/pkgconfig/protobuf.pc
else
    MASON_LIB_FILE=lib/libprotobuf.a
    MASON_PKGCONFIG_FILE=lib/pkgconfig/protobuf.pc
fi

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/google/protobuf/releases/download/v${LIB_VERSION}/protobuf-cpp-${LIB_VERSION}.tar.gz \
        567b4000dc3666fb9de712beddfcf24a80e857f0

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${LIB_VERSION}
}

function mason_compile {
    # note CFLAGS overrides defaults (-O2 -g -DNDEBUG) so we need to add optimization flags back
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    export CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG"

    if [ "${MASON_PLATFORM}" == "android" ]; then
        export LDFLAGS="${LDFLAGS} -llog"
    fi

    if [ ${MASON_PLATFORM} == 'android' ] || [ ${MASON_PLATFORM} == 'ios' ]; then
        local PREFIX=$(MASON_PLATFORM= MASON_PLATFORM_VERSION= ${MASON_DIR}/mason prefix ${MASON_NAME} ${MASON_VERSION})
        if [ ! -d ${PREFIX} ]; then
            $(MASON_PLATFORM= MASON_PLATFORM_VERSION= ${MASON_DIR}/mason install ${MASON_NAME} ${MASON_VERSION})
        fi
        export PROTOBUF_XC_ARG="--with-protoc=${PREFIX}/bin/protoc"
    fi

    if [ "${MASON_PLATFORM}" == "ios" ]; then
        export MACOSX_DEPLOYMENT_TARGET="10.8"
    fi

    if [ -f Makefile ]; then
        make distclean
    fi

    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        ${PROTOBUF_XC_ARG:-} \
        --enable-static --disable-shared \
        --disable-debug --without-zlib \
        --disable-dependency-tracking

    make V=1 -j${MASON_CONCURRENCY}
    make install -j${MASON_CONCURRENCY}
}

function mason_clean {
    make clean
}

function mason_config_custom {
    if [ ${MASON_PLATFORM} == 'android' ]; then
        MASON_CONFIG_LDFLAGS="${MASON_CONFIG_LDFLAGS} -llog"
    fi
}

mason_run "$@"
