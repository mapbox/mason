#!/usr/bin/env bash

MASON_NAME=readline
MASON_VERSION=8.0
MASON_PKGCONFIG_FILE=lib/pkgconfig/readline.pc
MASON_LIB_FILE=lib/libreadline.so

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        ftp://ftp.gnu.org/gnu/readline/readline-${MASON_VERSION}.tar.gz \
        a7447a3c8dff6a1ad436af54f488195bf93f775e

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/readline-${MASON_VERSION}
}

function mason_prepare_compile {
    LIBEDIT_VERSION="3.1"
    NCURSES_VERSION="6.1"
    ${MASON_DIR}/mason install libedit ${LIBEDIT_VERSION}
    MASON_LIBEDIT=$(${MASON_DIR}/mason prefix libedit ${LIBEDIT_VERSION})
    ${MASON_DIR}/mason install ncurses ${NCURSES_VERSION}
    MASON_NCURSES=$(${MASON_DIR}/mason prefix ncurses ${NCURSES_VERSION})
}

function mason_compile {
    # note CFLAGS overrides defaults (-Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -Wno-unused-command-line-argument) so we need to add optimization flags back
    export CFLAGS="${CFLAGS}  -O3 -DNDEBUG -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -Wno-unused-command-line-argument"
    export CFLAGS="-I${MASON_LIBEDIT}/include -I${MASON_NCURSES}/include ${CFLAGS}"
    export LDFLAGS="-L${MASON_LIBEDIT}/lib -L${MASON_NCURSES}/lib ${LDFLAGS}"

    ./configure \
        --prefix=${MASON_PREFIX} \
        --with-curses \
        ${MASON_HOST_ARG} 

    make -j${MASON_CONCURRENCY} install
}

function mason_clean {
    make clean
}

mason_run "$@"
