#!/usr/bin/env bash

MASON_NAME=android-ndk
MASON_VERSION=$(basename $(dirname "${BASH_SOURCE[0]}"))
MASON_LIB_FILE=

export MASON_ANDROID_TOOLCHAIN="arm-linux-android"
export MASON_CFLAGS="-target arm-none-linux-android"
export MASON_LDFLAGS=""
export MASON_ANDROID_ABI="arm"
export MASON_ANDROID_NDK_ARCH="arm"

. ${MASON_DIR}/scripts/android-ndk/script-${MASON_VERSION##*-}.sh