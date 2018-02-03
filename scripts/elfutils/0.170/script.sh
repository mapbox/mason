#!/usr/bin/env bash

MASON_NAME=elfutils
MASON_VERSION=0.170
MASON_LIB_FILE=lib/libelf.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://sourceware.org/elfutils/ftp/${MASON_VERSION}/${MASON_NAME}-${MASON_VERSION}.tar.bz2 \
        cb9b96544eeadc0677148aeddca16ec314bc9f67

    mason_extract_tar_bz2

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    ${MASON_DIR}/mason install xz 5.2.3
    MASON_XZ=$(${MASON_DIR}/mason prefix xz 5.2.3)
    ${MASON_DIR}/mason install bzip2 1.0.6
    MASON_BZIP2=$(${MASON_DIR}/mason prefix bzip2 1.0.6)
    ${MASON_DIR}/mason install zlib 1.2.8
    MASON_ZLIB=$(${MASON_DIR}/mason prefix zlib 1.2.8)
}


# note: must be compiled with gcc due to variable length array usage
# clang at configure time will fail the gnu99 check with:
# conftest.c:26:18: error: fields must have a constant size: 'variable length array in structure' extension will never be supported
function mason_compile {
    # knock out -Werror
    perl -i -p -e "s/,,-Werror/,,/g;" config/eu.am
    perl -i -p -e "s/,,-Werror/,,/g;" libdwfl/Makefile.in
    perl -i -p -e "s/,,-Werror/,,/g;" backends/Makefile.in
    perl -i -p -e "s/,,-Werror/,,/g;" lib/Makefile.in
    perl -i -p -e "s/,,-Werror/,,/g;" libasm/Makefile.in
    perl -i -p -e "s/,,-Werror/,,/g;" libcpu/Makefile.in
    perl -i -p -e "s/,,-Werror/,,/g;" libdwelf/Makefile.in
    perl -i -p -e "s/,,-Werror/,,/g;" libdw/Makefile.in
    perl -i -p -e "s/,,-Werror/,,/g;" libebl/Makefile.in
    perl -i -p -e "s/,,-Werror/,,/g;" libelf/Makefile.in
    perl -i -p -e "s/,,-Werror/,,/g;" src/Makefile.in
    perl -i -p -e "s/,,-Werror/,,/g;" tests/Makefile.in


    # Note CXXFLAGS overrides the default of `-O2 -g`
    export CFLAGS="${CFLAGS:-} -O3 -DNDEBUG -I${MASON_ZLIB}/include -I${MASON_BZIP2}/include -I${MASON_XZ}/include"
    export LDFLAGS="${LDFLAGS:-} -L${MASON_ZLIB}/lib -L${MASON_BZIP2}/lib -L${MASON_XZ}/lib"

    ./configure --prefix=${MASON_PREFIX} ${MASON_HOST_ARG} \
     --with-lzma=${MASON_XZ} \
     --with-bzlib=${MASON_BZIP2} \
     --with-zlib=${MASON_ZLIB} \
     --without-biarch \
     --disable-shared \
     --disable-dependency-tracking

    make -j${MASON_CONCURRENCY} V=1
    make install
    rm ${MASON_PREFIX}/lib/*so
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}

mason_run "$@"
