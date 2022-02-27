#!/usr/bin/env bash

MASON_NAME=libcurl
MASON_VERSION=7.81.0
MASON_LIB_FILE=lib/libcurl.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/libcurl.pc

OPENSSL_VERSION=1.0.2d

. ${MASON_DIR}/mason.sh


function mason_load_source {
    mason_download \
        https://curl.haxx.se/download/curl-${MASON_VERSION}.tar.gz \
        926f8259afe72766a8f24618a439f894122d74dd

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/curl-${MASON_VERSION}
}

function mason_prepare_compile {
    ${MASON_DIR}/mason install openssl ${OPENSSL_VERSION}
    MASON_OPENSSL=`${MASON_DIR}/mason prefix openssl ${OPENSSL_VERSION}`

    if [ ${MASON_PLATFORM} = 'linux' ]; then
        LIBS="-ldl ${LIBS=}"
    fi
}

function mason_compile {
    LIBS="${LIBS=}" ./configure \
        --prefix=${MASON_PREFIX} \
        ${MASON_HOST_ARG} \
        --enable-static \
        --disable-shared \
        --with-pic \
        --enable-manual \
        --with-ssl=${MASON_OPENSSL} \
        --without-ca-bundle \
        --without-ca-path \
        --without-gnutls \
        --without-polarssl \
        --without-cyassl \
        --without-nss \
        --without-axtls \
        --without-libssh2 \
        --without-librtmp \
        --without-winidn \
        --without-libidn \
        --without-nghttp2 \
        --disable-ldap \
        --disable-ldaps \
        --disable-ldap \
        --disable-ftp \
        --disable-file \
        --disable-rtsp \
        --disable-proxy \
        --disable-dict \
        --disable-telnet \
        --disable-tftp \
        --disable-pop3 \
        --disable-imap \
        --disable-smtp \
        --disable-gopher \
        --disable-libcurl-option \
        --disable-sspi \
        --disable-crypto-auth \
        --disable-ntlm-wb \
        --disable-tls-srp \
        --disable-cookies

    make -j${MASON_CONCURRENCY}
    make install
}

function mason_clean {
    make clean
}

mason_run "$@"