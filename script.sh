#!/usr/bin/env bash

MASON_NAME=libcurl
MASON_VERSION=7.38.0-boringssl
MASON_LIB_FILE=lib/libcurl.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/libcurl.pc

MASON_PWD=`pwd`

. ${MASON_DIR:-~/.mason}/mason.sh


function mason_load_source {
    mason_download \
        http://curl.haxx.se/download/curl-7.38.0.tar.gz \
        5463f1b9dc807e4ae8be2ef4ed57e67f677f4426

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/curl-7.38.0
}

function mason_prepare_compile {
    ${MASON_DIR:-~/.mason}/mason install boringssl d3bcf13
    MASON_OPENSSL=`~/.mason/mason prefix boringssl d3bcf13`

    if [ ${MASON_PLATFORM} = 'linux' ]; then
        LIBS="-ldl ${LIBS=}"
    fi
}

function mason_compile {
    mason_step "Loading install script 'https://github.com/mapbox/mason/blob/${MASON_SLUG}/openssl.patch'..."
    curl --retry 3 -s -f -# -L \
      https://raw.githubusercontent.com/mapbox/mason/${MASON_SLUG}/openssl.patch \
      -O || (mason_error "Could not find patch for ${MASON_SLUG}" && exit 1)
    patch ${MASON_ROOT}/.build/curl-7.38.0/lib/vtls/openssl.c < ${MASON_PWD}/openssl.patch

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
        --without-darwinssl \
        --without-gnutls \
        --without-polarssl \
        --without-cyassl \
        --without-nss \
        --without-axtls \
        --without-libmetalink \
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
