#!/usr/bin/env bash

# dynamically determine the path to this package
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
# dynamically take name of package from directory
MASON_NAME=$(basename $(dirname $HERE))
# dynamically take the version of the package from directory
MASON_VERSION=$(basename $HERE)
# inherit all functions from llvm base
source ${HERE}/../../${MASON_NAME}/base/common.sh

function setup_release() {
    curl_get_and_uncompress "http://llvm.org/releases/${MASON_VERSION}/llvm-${MASON_VERSION}.src.tar.xz"              ${MASON_BUILD_PATH}/                        f2093e98060532449eb7d2fcfd0bc6c6
    curl_get_and_uncompress "http://llvm.org/releases/${MASON_VERSION}/cfe-${MASON_VERSION}.src.tar.xz"               ${MASON_BUILD_PATH}/tools/clang             29e1d86bee422ab5345f5e9fb808d2dc
    curl_get_and_uncompress "http://llvm.org/releases/${MASON_VERSION}/compiler-rt-${MASON_VERSION}.src.tar.xz"       ${MASON_BUILD_PATH}/projects/compiler-rt    b7ea34c9d744da16ffc0217b6990d095
    curl_get_and_uncompress "http://llvm.org/releases/${MASON_VERSION}/libcxx-${MASON_VERSION}.src.tar.xz"            ${MASON_BUILD_PATH}/projects/libcxx         0a11efefd864ce6f321194e441f7e569
    curl_get_and_uncompress "http://llvm.org/releases/${MASON_VERSION}/libcxxabi-${MASON_VERSION}.src.tar.xz"         ${MASON_BUILD_PATH}/projects/libcxxabi      d02642308e22e614af6b061b9b4fedfa
    curl_get_and_uncompress "http://llvm.org/releases/${MASON_VERSION}/libunwind-${MASON_VERSION}.src.tar.xz"         ${MASON_BUILD_PATH}/projects/libunwind      3e5c87c723a456be599727a444b1c166
    curl_get_and_uncompress "http://llvm.org/releases/${MASON_VERSION}/lld-${MASON_VERSION}.src.tar.xz"               ${MASON_BUILD_PATH}/tools/lld               c23c895c0d855a0dc426af686538a95e
    curl_get_and_uncompress "http://llvm.org/releases/${MASON_VERSION}/clang-tools-extra-${MASON_VERSION}.src.tar.xz" ${MASON_BUILD_PATH}/tools/clang/tools/extra f4f663068c77fc742113211841e94d5e
}

mason_run "$@"
