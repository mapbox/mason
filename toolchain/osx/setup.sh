#!/usr/bin/env bash

if [ "$1" == "publish" ]; then
    hdiutil detach ${MASON_PREFIX}/root
elif [ ! -f "${MASON_PREFIX}/${MASON_LIB_FILE}" ] ; then
    URL=https://mason-binaries.s3.amazonaws.com/prebuilt/arm-cortex_a9-linux-gnueabihf.dmg
    FILE="${MASON_ROOT}/.cache/arm-cortex_a9-linux-gnueabihf.dmg"
    mkdir -p ${MASON_ROOT}/.cache
    if [ ! -f ${FILE} ] ; then
        mason_step "Downloading ${URL}..."
        curl --retry 3 ${MASON_CURL_ARGS} -f -L ${URL} -o ${FILE}.tmp && \
            mv ${FILE}.tmp ${FILE}
    fi
    mkdir -p ${MASON_PREFIX}/root
    hdiutil attach -quiet -readonly -mountpoint ${MASON_PREFIX}/root ${FILE}
fi
