#!/usr/bin/env bash

MASON_NAME=libspatialite
MASON_VERSION=4.3.0a
MASON_LIB_FILE=lib/libspatialite.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/spatialite.pc

# Used when cross compiling to cortex_a9
ZLIB_SHARED_VERSION=1.2.8

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        http://www.gaia-gis.it/gaia-sins/libspatialite-${MASON_VERSION}.tar.gz \
        48f89c81628f295eec9d239f5e2209a521da053d

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/libspatialite-${MASON_VERSION}
}

function mason_prepare_compile {

    # Install the zlib dependency when cross compiling as usually the host system only
    # provides the zlib headers and libraries in the path for the host architecture.
    if [ ${MASON_PLATFORM_VERSION} == "cortex_a9" ] || [ ${MASON_PLATFORM_VERSION} == "i686" ]; then
        cd $(dirname ${MASON_ROOT})
        ${MASON_DIR}/mason install zlib_shared ${ZLIB_SHARED_VERSION}
        ${MASON_DIR}/mason link zlib_shared ${ZLIB_SHARED_VERSION}

        MASON_ZLIB_CFLAGS="$(${MASON_DIR}/mason cflags zlib_shared ${ZLIB_SHARED_VERSION})"
        MASON_ZLIB_LDFLAGS="-L$(${MASON_DIR}/mason prefix zlib_shared ${ZLIB_SHARED_VERSION})/lib"
    fi

    ${MASON_DIR}/mason install sqlite 3.21.0
    ${MASON_DIR}/mason link sqlite 3.21.0
}

function mason_compile {

    export CXXFLAGS="-isystem ${MASON_ROOT}/.link/include ${CXXFLAGS:-} -D_GLIBCXX_USE_CXX11_ABI=0"
    export CFLAGS="-isystem ${MASON_ROOT}/.link/include ${CFLAGS:-}"
    export LDFLAGS="-L${MASON_ROOT}/.link/lib ${LDFLAGS:-}"
    export PATH="${MASON_ROOT}/.link/bin:${PATH}"

    # hence we add back the preferred optimization
    CFLAGS="-O3 ${CFLAGS} -DNDEBUG" ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --with-pic \
        --disable-shared \
        --disable-dependency-tracking

    make install -j${MASON_CONCURRENCY}
}

function mason_ldflags {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
