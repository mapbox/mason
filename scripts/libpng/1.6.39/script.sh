#!/usr/bin/env bash

MASON_NAME=libpng
MASON_VERSION=1.6.39
MASON_LIB_FILE=lib/libpng.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/libpng.pc

# Used when cross compiling to cortex_a9
ZLIB_SHARED_VERSION=1.2.8

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://downloads.sourceforge.net/project/libpng/libpng16/${MASON_VERSION}/libpng-${MASON_VERSION}.tar.gz \
        d7381b740d41de6ca31eec5143205c1a75b0f445

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/libpng-${MASON_VERSION}
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
}

function mason_compile {
    export CFLAGS="${CFLAGS:-} ${MASON_ZLIB_CFLAGS:-} -O3 -DNDEBUG"
    export LDFLAGS="${CFLAGS:-} ${MASON_ZLIB_LDFLAGS:-}"

    if [ ${MASON_PLATFORM_VERSION} == "cortex_a9" ] || [ ${MASON_PLATFORM_VERSION} == "i686" ]; then
        # XXX: This hack is because libpng does not respect CFLAGS
        # for all the files. Bruteforce in the compiler command line.
        export CC="${CC:-} ${CFLAGS}"
    fi

    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --with-pic \
        --disable-shared \
        --disable-dependency-tracking

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
