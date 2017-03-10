export MASON_ANDROID_PLATFORM_VERSION=${MASON_VERSION%-*}
export MASON_ANDROID_NDK_VERSION=${MASON_VERSION##*-}
export MASON_ANDROID_NDK_API_LEVEL=${MASON_ANDROID_PLATFORM_VERSION##*-}

. ${MASON_DIR}/mason.sh

function mason_load_source {
    if [ ${MASON_PLATFORM} = 'osx' ]; then
        mason_download \
            http://dl.google.com/android/repository/android-ndk-${MASON_ANDROID_NDK_VERSION}-darwin-x86_64.zip \
            8ace11815fb839a94ee5601c523ddb629f46232b
    elif [ ${MASON_PLATFORM} = 'linux' ]; then
        mason_download \
            http://dl.google.com/android/repository/android-ndk-${MASON_ANDROID_NDK_VERSION}-linux-x86_64.zip \
            a8eca41e6a8d6f8776834261d3d0363b9a1abe19
    fi

    mason_setup_build_dir
    rm -rf ./android-ndk-${MASON_ANDROID_NDK_VERSION}
    unzip -q ../.cache/${MASON_SLUG} $@

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/android-ndk-${MASON_ANDROID_NDK_VERSION}
}

function mason_compile {
    rm -rf ${MASON_PREFIX}
    mkdir -p ${MASON_PREFIX}

    ${MASON_BUILD_PATH}/build/tools/make_standalone_toolchain.py \
        --force \
        --arch ${MASON_ANDROID_NDK_ARCH} \
        --api ${MASON_ANDROID_NDK_API_LEVEL} \
        --stl libc++ \
        --install-dir "${MASON_PREFIX}"

    # NDK r12 ships with .so files which are preferred when linking, but cause
    # errors on devices when it's not present.
    find "${MASON_PREFIX}" -name "libstdc++.so" -delete

    # Add a toolchain.sh and toolchain.cmake file.
    ROOT="${MASON_PREFIX}" ${MASON_DIR}/scripts/android-ndk/write_toolchain-${MASON_ANDROID_NDK_VERSION}.sh

    # Copy the gdbserver
    mkdir -p "${MASON_PREFIX}/prebuilt"
    cp -rv "${MASON_BUILD_PATH}/prebuilt/android-${MASON_ANDROID_NDK_ARCH}/gdbserver" "${MASON_PREFIX}/prebuilt"
}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
