#!/usr/bin/env bash

MASON_NAME=pcp
MASON_VERSION=4.0.1
MASON_LIB_FILE=bin/pcp

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/performancecopilot/pcp/archive/${MASON_VERSION}.tar.gz \
        861e2459023417c1777daff47b9bfd9f2cd083b2

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    # this ensures we shared mason_packages dir
    cd $(dirname ${MASON_ROOT})
    LIBMMICRO_VERSION="0.9.59"
    BOOST_VERSION="1.66.0"
    ${MASON_DIR}/mason install boost ${BOOST_VERSION}
    ${MASON_DIR}/mason link boost ${BOOST_VERSION}
    ${MASON_DIR}/mason install libmicrohttpd ${LIBMMICRO_VERSION}
    ${MASON_DIR}/mason link libmicrohttpd ${LIBMMICRO_VERSION}
    export MASON_LINKED_REL=$(pwd)/mason_packages/.link
    export CFLAGS="${CFLAGS:-} -I${MASON_LINKED_REL}/include -O3 -DNDEBUG"
    export CXXFLAGS="${CXXFLAGS:-} -I${MASON_LINKED_REL}/include -O3 -DNDEBUG"
    export LDFLAGS="${LDFLAGS:-} -L${MASON_LINKED_REL}/lib"
    # breaks being able to find system pkgconfig paths since it looses default
    # PKGCONFIG_VERSION="0.29.1"
    # ${MASON_DIR}/mason install pkgconfig ${PKGCONFIG_VERSION}
    # export PATH=$(${MASON_DIR}/mason prefix pkgconfig ${PKGCONFIG_VERSION})/bin:${PATH}
    export PKG_CONFIG_PATH="${MASON_LINKED_REL}/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
}

function mason_compile {
    # export CFLAGS="${CFLAGS:-} -O3 -DNDEBUG"
    # export LDFLAGS="${CFLAGS:-}"
    # avoid fat binaries on OS X
    perl -i -p -e "s/ -arch i386//g;" ./configure
    ./configure \
        ${MASON_HOST_ARG} \
        --prefix=${MASON_PREFIX} \
        --sysconfdir=${MASON_PREFIX}/etc \
        --localstatedir=${MASON_PREFIX}/var \
        --with-webapi

    V=1 VERBOSE=1 make install -j${MASON_CONCURRENCY}
}

function mason_strip_ldflags {
    shift # -L...
    shift # -lpng16
    echo "$@"
}

function mason_ldflags {
    mason_strip_ldflags $(`mason_pkgconfig` --static --libs)
}

function mason_clean {
    make clean
}

mason_run "$@"
