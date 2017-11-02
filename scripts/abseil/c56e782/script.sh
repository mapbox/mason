#!/usr/bin/env bash

MASON_NAME=abseil
MASON_VERSION=c56e782
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/abseil/abseil-cpp/tarball/${MASON_VERSION} \
        87d6b71062e172731aa13513d0eff3015a7f6085

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/abseil-abseil-cpp-${MASON_VERSION}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r absl ${MASON_PREFIX}/include/absl
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}

mason_run "$@"
