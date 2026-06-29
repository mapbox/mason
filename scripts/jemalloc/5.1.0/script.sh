#!/usr/bin/env bash

MASON_NAME=jemalloc
MASON_VERSION=5.1.0
MASON_LIB_FILE=lib/libjemalloc.${MASON_DYNLIB_SUFFIX}

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/jemalloc/jemalloc/archive/${MASON_VERSION}.tar.gz \
        58a6dc72ed15b914148f063f537e030ca45b2c97

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    # need to call autogen.sh when building from a gitsha only
    ./autogen.sh
    # oddly DNDEBUG is not automatically in the jemalloc flags, so we add it here for best perf/just to be safe (to 100% ensure asserts are removed)
    # note: as of jemalloc 4.5.0 CFLAGS no longer overwrites but appends.
    # so we don't mess with CFLAGS here like previous packages where we needed to manually re-add the jemalloc CFLAGS that were lost
    export CFLAGS="${CFLAGS:-} -DNDEBUG"

    # note: the below malloc-conf changes are based on reading https://github.com/jemalloc/jemalloc/pull/1179/files
    # and noting that fb defaults to background_thread:true: https://github.com/jemalloc/jemalloc/issues/1128#issuecomment-378439640
    ./configure --prefix=${MASON_PREFIX} --disable-stats \
      --with-malloc-conf=background_thread:true,abort_conf:true
    make -j${MASON_CONCURRENCY} VERBOSE=1 install_lib
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
