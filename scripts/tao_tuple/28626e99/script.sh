#!/usr/bin/env bash

MASON_NAME=tao_tuple
MASON_VERSION=28626e99
MASON_HEADER_ONLY=true

GIT_HASH="28626e9956a5ef7e6985dbb614c62221513e072a"

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/taocpp/tuple/archive/${GIT_HASH}.tar.gz \
        b4dc8562eeb8e9c26d0ca600313d07891ff59e0b

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/tuple-${GIT_HASH}
}

function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -rL include/tao ${MASON_PREFIX}/include/
    cp -r LICENSE ${MASON_PREFIX}/
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}


mason_run "$@"
