#!/usr/bin/env bash

if [ "$1" == "publish" ]; then
    if [ -f "${MASON_PREFIX}/${MASON_LIB_FILE}" ] ; then
        hdiutil detach ${MASON_PREFIX}/root
    fi
    MASON_LIB_FILE=
elif [ ! -f "${MASON_PREFIX}/${MASON_LIB_FILE}" ] ; then
    URL=https://mason-binaries.s3.amazonaws.com/prebuilt/osx-x86_64/gcc-4.9.2-i686.dmg
    FILE="${MASON_ROOT}/.cache/osx-x86_64-gcc-4.9.2-i686.dmg"
    mkdir -p ${MASON_ROOT}/.cache
    if [ ! -f ${FILE} ] ; then
        mason_step "Downloading ${URL}..."
        curl --retry 3 ${MASON_CURL_ARGS} -f -L ${URL} -o ${FILE}.tmp && \
            mv ${FILE}.tmp ${FILE}
    fi
    mkdir -p ${MASON_PREFIX}/root
    hdiutil attach -quiet -readonly -mountpoint ${MASON_PREFIX}/root ${FILE}
fi
