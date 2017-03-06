#!/usr/bin/env bash

MASON_NAME=broken
MASON_VERSION=0.0.0
MASON_LIB_FILE=${UNBOUND_VARIABLE}

. ${MASON_DIR}/mason.sh

function mason_load_source {
    echo ${UNBOUND_VARIABLE}
}

function mason_compile {
    :
}

function mason_ldflags {
    echo ${UNBOUND_VARIABLE}
}

mason_run "$@"
