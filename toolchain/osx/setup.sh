#!/usr/bin/env bash

if [ ! -f "${MASON_PREFIX}/${MASON_LIB_FILE}" ] ; then
    URL=https://mason-binaries.s3.amazonaws.com/prebuilt/arm-cortex_a9-linux-gnueabihf.dmg
    FILE="${MASON_ROOT}/.cache/arm-cortex_a9-linux-gnueabihf.dmg"
    mkdir -p `dirname ${FILE}`
    if [ ! -f ${FILE} ] ; then
        mason_step "Downloading ${URL}..."
        curl --retry 3 ${MASON_CURL_ARGS} -f -L ${URL} -o ${FILE}.tmp && \
            mv ${FILE}.tmp ${FILE}.dmg
    fi
    mkdir -p ${MASON_PREFIX}/root
    hdiutil attach -quiet -readonly -mountpoint ${MASON_PREFIX}/root ${FILE}
fi
