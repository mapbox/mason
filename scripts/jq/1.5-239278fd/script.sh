#!/usr/bin/env bash

MASON_NAME=jq
MASON_VERSION=239278fd3a02dc1ae0521a7a57d573dbf977b2d9
MASON_LIB_FILE=bin/jq

. ${MASON_DIR}/mason.sh

function mason_load_source {
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}

    if [[ ! -d ${MASON_BUILD_PATH} ]]; then
        git clone git://github.com/stedolan/${MASON_NAME}.git ${MASON_BUILD_PATH}
    fi
    cd ${MASON_BUILD_PATH}
    git checkout ${MASON_VERSION}

    cd ../
}

function mason_compile {
    git submodule update --init
    autoreconf -fi

    ./configure \
        --prefix ${MASON_PREFIX} \
        --with-oniguruma=builtin \
        --disable-maintainer-mode

    export LDFLAGS="-all-static ${LDFLAGS:-}"
    make -j${MASON_CONCURRENCY}

    make install
}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
