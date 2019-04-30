#!/usr/bin/env bash

MASON_NAME=protobuf_c
MASON_VERSION=1.3.0
MASON_LIB_FILE=lib/libprotobuf-c.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/libprotobuf-c.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/protobuf-c/protobuf-c/releases/download/v${MASON_VERSION}/protobuf-c-${MASON_VERSION}.tar.gz \
        54284246d3da84f9987888462199762bf654e132

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/protobuf-c-${MASON_VERSION}
}

PROTOBUF_VERSION="3.4.1"

function mason_prepare_compile {
    cd $(dirname ${MASON_ROOT})
    ${MASON_DIR}/mason install protobuf ${PROTOBUF_VERSION}
    MASON_PROTOBUF=$(${MASON_DIR}/mason prefix protobuf ${PROTOBUF_VERSION})
    export PKG_CONFIG_PATH=${MASON_PROTOBUF}/lib/pkgconfig:${PKG_CONFIG_PATH:-}
    if [[ $(uname -s) == 'Darwin' ]]; then
        FIND="\/Users\/travis\/build\/mapbox\/mason"
    else
        FIND="\/home\/travis\/build\/mapbox\/mason"
    fi
    REPLACE="$(pwd)"
    REPLACE=${REPLACE////\\/}
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_PROTOBUF}/lib/pkgconfig/protobuf.pc
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_PROTOBUF}/lib/pkgconfig/protobuf-lite.pc
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_PROTOBUF}/lib/libprotobuf.la
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_PROTOBUF}/lib/libprotoc.la
}

function mason_compile {
    export PATH=${MASON_PROTOBUF}/bin:${PATH}
    # note CFLAGS overrides defaults (-O2 -g -DNDEBUG) so we need to add optimization flags back
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    export CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG"
    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static --disable-shared \
        --disable-dependency-tracking

    make V=1 install -j${MASON_CONCURRENCY}
}

function mason_clean {
    make clean
}

mason_run "$@"
