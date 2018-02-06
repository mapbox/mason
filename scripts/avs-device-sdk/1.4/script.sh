#!/usr/bin/env bash

MASON_NAME=avs-device-sdk
MASON_VERSION=1.4
MASON_LIB_FILE=lib/libDefaultClient.so
MASON_PKGCONFIG_FILE=lib/pkgconfig/AlexaClientSDK.pc

OPENSSL_VERSION=1.0.2d
LIBCURL_VERSION=7.50.2
NGHTTP2_VERSION=1.26.0
SQLITE_VERSION=3.21.0

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/alexa/avs-device-sdk/archive/v${MASON_VERSION}.tar.gz \
        efc642f4d7f24dba5240a8595c7b7576d9f0aa4f

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    # Install CMake
    CMAKE_VERSION=3.8.2
    $(MASON_PLATFORM= MASON_PLATFORM_VERSION= ${MASON_DIR}/mason install cmake ${CMAKE_VERSION})
    MASON_CMAKE=$(MASON_PLATFORM= MASON_PLATFORM_VERSION= ${MASON_DIR}/mason prefix cmake ${CMAKE_VERSION})
    $(MASON_PLATFORM= MASON_PLATFORM_VERSION= ${MASON_DIR}/mason link cmake ${CMAKE_VERSION})

    # Install dependencies
    ${MASON_DIR}/mason install openssl ${OPENSSL_VERSION}
    MASON_LIBOPENSSL=$(${MASON_DIR}/mason prefix openssl ${OPENSSL_VERSION})
    ${MASON_DIR}/mason install libcurl ${LIBCURL_VERSION}
    MASON_LIBCURL=$(${MASON_DIR}/mason prefix libcurl ${LIBCURL_VERSION})
    ${MASON_DIR}/mason install libnghttp2 ${NGHTTP2_VERSION}
    MASON_NGHTTP2=$(${MASON_DIR}/mason prefix libnghttp2 ${NGHTTP2_VERSION})
    ${MASON_DIR}/mason install sqlite ${SQLITE_VERSION}
    MASON_SQLITE=$(${MASON_DIR}/mason prefix sqlite ${SQLITE_VERSION})
}

function mason_compile {
    # Create build directory
    BUILD_DIR=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}-build
    mkdir -p ${BUILD_DIR}
    cd ${BUILD_DIR}

    echo "Running CMake ${MASON_CMAKE}/bin/cmake from ${BUILD_DIR} on source ${MASON_BUILD_PATH}"

    if [ ${MASON_PLATFORM} = 'android' ]; then
        # Create toolchain
        ${MASON_DIR}/utils/android.sh > toolchain.cmake
        cat toolchain.cmake

        # Run cmake
        LINKER_FLAGS="-L${MASON_LIBOPENSSL}/lib -L${MASON_LIBCURL}/lib -L${MASON_NGHTTP2}/lib -L${MASON_SQLITE}/lib -lz"
        CMAKE_PREFIX_PATH=${MASON_ROOT}/.link \
        ${MASON_ROOT}/.link/bin/cmake \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_PREFIX_PATH="${MASON_SQLITE};${MASON_LIBOPENSSL};${MASON_LIBCURL};${MASON_NGHTTP2}" \
            -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
            -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
            -DCMAKE_CXX_FLAGS="${CXXFLAGS} -std=c++11" \
            -DCMAKE_MODULE_LINKER_FLAGS="${LDFLAGS} ${LINKER_FLAGS}" \
            -DCMAKE_SHARED_LINKER_FLAGS="${LDFLAGS} ${LINKER_FLAGS}" \
            -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} ${LINKER_FLAGS}" \
            -DCMAKE_CXX_STANDARD_LIBRARIES="-lssl -lcrypto" \
            ${MASON_BUILD_PATH}
    else
        # Generic build
        CMAKE_PREFIX_PATH=${MASON_ROOT}/.link \
        ${MASON_ROOT}/.link/bin/cmake \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
            ${MASON_BUILD_PATH}
    fi

    echo "Running make"
    make AVSCommon
    make ACL
    make AuthDelegate
    make ADSL
    make AFML
    make CertifiedSender
    make ContextManager
    make PlaylistParser
    make KWD
    make AIP
    make Alerts
    make AudioPlayer
    make Notifications
    make PlaybackController
    make Settings
    make SpeakerManager
    make SpeechSynthesizer
    make AVSSystem
    make TemplateRuntime
    make DefaultClient
    make AudioResources
    make SQLiteStorage
    make AlexaClientSDK.pc
    make install
}

function mason_clean {
    make clean
}

mason_run "$@"
