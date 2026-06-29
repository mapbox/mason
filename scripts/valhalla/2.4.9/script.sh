#!/usr/bin/env bash

MASON_NAME=valhalla
MASON_VERSION=2.4.9
MASON_LIB_FILE=lib/libvalhalla.a
#MASON_PKGCONFIG_FILE=lib/pkgconfig/libvalhalla.pc


. ${MASON_DIR}/mason.sh

function mason_load_source {
#    mason_download \
#        https://github.com/valhalla/${MASON_NAME}/archive/${MASON_VERSION}.tar.gz \
#        12718a7f8d26f707469895fb2a7e69f748356f7d
#
#    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}

    if [ ! -d "$MASON_BUILD_PATH" ] ; then
        mkdir -p "$MASON_BUILD_PATH"
        git clone --branch "$MASON_VERSION" --recursive https://github.com/valhalla/valhalla.git "$MASON_BUILD_PATH"
    fi
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

    ${MASON_DIR}/mason install lz4 1.8.2
    ${MASON_DIR}/mason link lz4 1.8.2

    ${MASON_DIR}/mason install protobuf 3.5.1
    ${MASON_DIR}/mason link protobuf 3.5.1

    ${MASON_DIR}/mason install boost 1.66.0
    ${MASON_DIR}/mason link boost 1.66.0
    ${MASON_DIR}/mason install boost_libprogram_options 1.66.0
    ${MASON_DIR}/mason link boost_libprogram_options 1.66.0
    ${MASON_DIR}/mason install boost_libsystem 1.66.0
    ${MASON_DIR}/mason link boost_libsystem 1.66.0
    ${MASON_DIR}/mason install boost_libthread 1.66.0
    ${MASON_DIR}/mason link boost_libthread 1.66.0
    ${MASON_DIR}/mason install boost_libfilesystem 1.66.0
    ${MASON_DIR}/mason link boost_libfilesystem 1.66.0
    ${MASON_DIR}/mason install boost_libregex_icu57 1.66.0
    ${MASON_DIR}/mason link boost_libregex_icu57 1.66.0
    ${MASON_DIR}/mason install boost_libregex 1.66.0
    ${MASON_DIR}/mason link boost_libregex 1.66.0
    ${MASON_DIR}/mason install boost_libdate_time 1.66.0
    ${MASON_DIR}/mason link boost_libdate_time 1.66.0
    ${MASON_DIR}/mason install boost_libiostreams 1.66.0
    ${MASON_DIR}/mason link boost_libiostreams 1.66.0

    ${MASON_DIR}/mason install lua 5.3.0
    ${MASON_DIR}/mason link lua 5.3.0

    ${MASON_DIR}/mason install sqlite 3.21.0
    ${MASON_DIR}/mason link sqlite 3.21.0

    if [ ${MASON_PLATFORM} = 'osx' ]; then
        ${MASON_DIR}/mason install libcurl system
        ${MASON_DIR}/mason link libcurl system
    else
        ${MASON_DIR}/mason install libcurl 7.50.2
        ${MASON_DIR}/mason link libcurl 7.50.2
    fi

    # set up to fix libtool .la files
    # https://github.com/mapbox/mason/issues/61
    if [[ $(uname -s) == 'Darwin' ]]; then
        FIND="\/Users\/travis\/build\/mapbox\/mason"
    else
        FIND="\/home\/travis\/build\/mapbox\/mason"
    fi
    REPLACE="$(pwd)"
    REPLACE=${REPLACE////\\/}

    ${MASON_DIR}/mason install geos 3.6.2
    ${MASON_DIR}/mason link geos 3.6.2
    MASON_GEOS=$(${MASON_DIR}/mason prefix geos 3.6.2)
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_GEOS}/bin/geos-config
}

function mason_compile {
    export CXXFLAGS="-isystem ${MASON_ROOT}/.link/include ${CXXFLAGS:-} -D_GLIBCXX_USE_CXX11_ABI=0"
    export CFLAGS="-isystem ${MASON_ROOT}/.link/include ${CFLAGS:-}"
    export LDFLAGS="-L${MASON_ROOT}/.link/lib ${LDFLAGS:-}"
    export PATH="${MASON_ROOT}/.link/bin:${PATH}"
    export LUA="${MASON_ROOT}/.link/bin/lua"
    export LUA_INCLUDE="-isystem ${MASON_ROOT}/.link/include"
    export LUA_LIB="-llua"

#declare -x MASON_BUILD_PATH="/Users/danpat/mapbox/mason/mason_packages/.build/valhalla-2.4.9"
#declare -x MASON_DIR="/Users/danpat/mapbox/mason"
#declare -x MASON_DYNLIB_SUFFIX="dylib"
#declare -x MASON_HOST_ARG="--host=x86_64-apple-darwin"
#declare -x MASON_PLATFORM_VERSION="x86_64"
#declare -x MASON_ROOT="/Users/danpat/mapbox/mason/mason_packages"

export

    patch -N -p1 < ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff

    NOCONFIGURE=1 ./autogen.sh


    PKG_CONFIG_PATH="${MASON_ROOT}/.link/lib/pkgconfig" \
    ./configure \
        --prefix="$MASON_PREFIX" \
        ${MASON_HOST_ARG} \
        --enable-static \
        --with-pic \
        --disable-shared \
        --disable-services \
        --disable-data_tools \
        --disable-dependency-tracking \
        --disable-python-bindings \
        --with-pkgconfigdir="${MASON_ROOT}/.link/lib/pkgconfig" \
        --with-protoc="$MASON_ROOT/.link/bin/protoc" \
        --with-protobuf-includes="$MASON_ROOT/.link/include" \
        --with-protobuf-libdir="$MASON_ROOT/.link/lib" \
        --with-boost=$(${MASON_DIR}/mason prefix boost 1.66.0) \
        --with-boost-libdir="${MASON_ROOT}/.link/lib" \
        --with-boost-python=no \
        --with-sqlite3=$(${MASON_DIR}/mason prefix sqlite 3.21.0) \
        --with-geos=${MASON_GEOS}/bin/geos-config

    V=1 VERBOSE=1 make install -j${MASON_CONCURRENCY}
}

function mason_strip_ldflags {
    :
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
