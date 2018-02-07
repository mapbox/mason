#!/usr/bin/env bash

MASON_NAME=optional
MASON_VERSION=f27e7908
MASON_HEADER_ONLY=true

GIT_HASH="f27e79084a9176672ed1eae50b3397fa8035d50d"

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/akrzemi1/Optional/archive/${GIT_HASH}.tar.gz \
        fb66013bae4c2a04ba88ee8229d55aed156e7ecd

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/Optional-${GIT_HASH}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/experimental
    cp -r optional.hpp ${MASON_PREFIX}/include/experimental/optional
    cp -r LICENSE ${MASON_PREFIX}
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}


mason_run "$@"
