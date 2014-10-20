#!/usr/bin/env bash

MASON_NAME=boost
MASON_VERSION=system
MASON_CACHABLE=false

. ~/.mason/mason.sh

function mason_load_source {
    :
}

function mason_compile {
    if [ -z `which curl-config` ]; then
        mason_error "Cannot find curl-config."
        exit 1
    else
        mason_substep "Using system-provided $(curl-config --version)"
    fi
}

function mason_pkgconfig {
    mason_error "No pkg-config support"
    exit 1
}

function mason_cflags {
    curl-config --cflags
}

function mason_ldflags {
    curl-config --libs
}

mason_run "$@"
