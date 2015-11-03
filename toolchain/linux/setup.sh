#!/usr/bin/env bash

if [ "$1" == "publish" ]; then
    sudo rm -rf ${MASON_PREFIX}/root
    MASON_LIB_FILE=
elif [ ! -f "${MASON_PREFIX}/${MASON_LIB_FILE}" ] ; then
    URL=https://mason-binaries.s3.amazonaws.com/prebuilt/linux-$(uname -m)/gcc-4.9.2-i686.tgz
    FILE="${MASON_ROOT}/.cache/linux-$(uname -m)-gcc-4.9.2-i686.tgz"
    mkdir -p ${MASON_ROOT}/.cache
    if [ ! -f ${FILE} ] ; then
        mason_step "Downloading ${URL}..."
        curl --retry 3 ${MASON_CURL_ARGS} -f -L ${URL} -o ${FILE}.tmp && \
            mv ${FILE}.tmp ${FILE}
    fi
    mkdir -p ${MASON_PREFIX}/root
    tar xf "${FILE}" --directory "${MASON_PREFIX}/root" --strip-components=1
fi
