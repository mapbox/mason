#!/usr/bin/env bash

MASON_NAME=postgres
MASON_VERSION=10.3
MASON_LIB_FILE=bin/psql
MASON_PKGCONFIG_FILE=lib/pkgconfig/libpq.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://ftp.postgresql.org/pub/source/v${MASON_VERSION}/postgresql-${MASON_VERSION}.tar.bz2 \
        e1590a4b2167dcdf164eb887cf83e7da9e155771

    mason_extract_tar_bz2

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/postgresql-${MASON_VERSION}
}

function mason_prepare_compile {
    LIBEDIT_VERSION="3.1"
    NCURSES_VERSION="6.1"
    CCACHE_VERSION=3.3.1
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install libedit ${LIBEDIT_VERSION}
    MASON_LIBEDIT=$(${MASON_DIR}/mason prefix libedit ${LIBEDIT_VERSION})
    ${MASON_DIR}/mason install ncurses ${NCURSES_VERSION}
    MASON_NCURSES=$(${MASON_DIR}/mason prefix ncurses ${NCURSES_VERSION})
}

function mason_compile {
    if [[ ${MASON_PLATFORM} == 'linux' ]]; then
        mason_step "Loading patch"
        patch src/include/pg_config_manual.h ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff
    fi

    # note CFLAGS overrides defaults (-Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -Wno-unused-command-line-argument) so we need to add optimization flags back
    export CFLAGS="${CFLAGS}  -O3 -DNDEBUG -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -Wno-unused-command-line-argument"
    export CFLAGS="-I${MASON_LIBEDIT}/include -I${MASON_NCURSES}/include ${CFLAGS}"
    export LDFLAGS="-L${MASON_LIBEDIT}/lib -L${MASON_NCURSES}/lib ${LDFLAGS}"
    ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-thread-safety \
        --enable-largefile \
        --with-python \
        --with-zlib \
        --without-bonjour \
        --without-openssl \
        --without-pam \
        --without-gssapi \
        --without-ossp-uuid \
        --with-readline \
        --with-libedit-preferred \
        --without-ldap \
        --without-libxml \
        --without-libxslt \
        --without-selinux \
        --without-perl \
        --without-tcl \
        --disable-rpath \
        --disable-debug \
        --disable-profiling \
        --disable-coverage \
        --disable-dtrace \
        --disable-depend \
        --disable-cassert

    make -j${MASON_CONCURRENCY} -C src/interfaces/libpq/ install
    rm -f src/interfaces/libpq{*.so*,*.dylib}
    rm -f ${MASON_PREFIX}/lib/libpq{*.so*,*.dylib}
    MASON_LIBPQ_PATH=${MASON_PREFIX}/lib/libpq.a
    MASON_LIBPQ_PATH2=${MASON_LIBPQ_PATH////\\/}
    MASON_LIBEDIT_PATH=${MASON_LIBEDIT}/lib/libedit.a
    MASON_LIBEDIT_PATH=${MASON_LIBEDIT_PATH////\\/}
    MASON_NCURSES_PATH=${MASON_NCURSES}/lib/libncurses.a
    MASON_NCURSES_PATH=${MASON_NCURSES_PATH////\\/}
    perl -i -p -e "s/\-lncurses/${MASON_NCURSES_PATH}/g;" src/backend/Makefile
    perl -i -p -e "s/\-lncurses/${MASON_NCURSES_PATH}/g;" src/Makefile.global
    perl -i -p -e "s/\-lncurses/${MASON_NCURSES_PATH}/g;" configure
    perl -i -p -e "s/\-lncurses/${MASON_NCURSES_PATH}/g;" config/programs.m4
    perl -i -p -e "s/\-ledit/${MASON_LIBEDIT_PATH}/g;" src/Makefile.global.in
    perl -i -p -e "s/\-ledit/${MASON_LIBEDIT_PATH}/g;" src/Makefile.global
    perl -i -p -e "s/\-lpq/${MASON_LIBPQ_PATH2} -pthread/g;" src/Makefile.global.in
    perl -i -p -e "s/\-lpq/${MASON_LIBPQ_PATH2} -pthread/g;" src/Makefile.global
    make -j${MASON_CONCURRENCY} install
    make -j${MASON_CONCURRENCY} -C contrib install
    rm -f ${MASON_PREFIX}/lib/lib{*.so*,*.dylib}
}

function mason_clean {
    make clean
}

mason_run "$@"
