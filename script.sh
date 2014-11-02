#!/usr/bin/env bash

MASON_NAME=openssl
MASON_VERSION=1.0.1i
MASON_LIB_FILE=lib/libssl.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/openssl.pc

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        https://www.openssl.org/source/openssl-1.0.1i.tar.gz \
        c4aeb799f5eec8fe43559e2ff63e0ab4672ab3c2

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/openssl-${MASON_VERSION}
}

function mason_prepare_compile {
    MASON_MAKEDEPEND="gccmakedep"

    if [ ${MASON_PLATFORM} = 'osx' ]; then
        MASON_MAKEDEPEND="makedepend"
        MASON_OS_COMPILER="darwin64-x86_64-cc enable-ec_nistp_64_gcc_128"
    elif [ ${MASON_PLATFORM} = 'linux' ]; then
        MASON_OS_COMPILER="linux-x86_64 enable-ec_nistp_64_gcc_128"
    elif [[ ${MASON_PLATFORM} == 'android' ]]; then
        MASON_OS_COMPILER="android-armv7"
    fi
}

function mason_compile {
    ./Configure \
        --prefix=${MASON_PREFIX} \
        enable-tlsext \
        -no-dso \
        -no-hw \
        -no-comp \
        -no-idea \
        -no-mdc2 \
        -no-rc5 \
        -no-zlib \
        -no-shared \
        -no-ssl2 \
        -no-ssl3 \
        -no-krb5 \
        -fPIC \
        -DOPENSSL_PIC \
        -DOPENSSL_NO_DEPRECATED \
        -DOPENSSL_NO_COMP \
        -DOPENSSL_NO_HEARTBEATS \
        --openssldir=${MASON_PREFIX}/etc/openssl \
        ${MASON_OS_COMPILER}

    make depend MAKEDEPPROG=${MASON_MAKEDEPEND}

    make

    # https://github.com/openssl/openssl/issues/57
    make install_sw
}

function mason_clean {
    make clean
}

mason_run "$@"
