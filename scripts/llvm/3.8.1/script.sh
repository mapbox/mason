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
    curl_get_and_uncompress "http://llvm.org/releases/${MASON_VERSION}/llvm-${MASON_VERSION}.src.tar.xz"              ${MASON_BUILD_PATH}/                        538467e6028bbc9259b1e6e015d25845
    curl_get_and_uncompress "http://llvm.org/releases/${MASON_VERSION}/cfe-${MASON_VERSION}.src.tar.xz"               ${MASON_BUILD_PATH}/tools/clang             4ff2f8844a786edb0220f490f7896080
    curl_get_and_uncompress "http://llvm.org/releases/${MASON_VERSION}/compiler-rt-${MASON_VERSION}.src.tar.xz"       ${MASON_BUILD_PATH}/projects/compiler-rt    f140db073d2453f854fbe01cc46f3110
    curl_get_and_uncompress "http://llvm.org/releases/${MASON_VERSION}/libcxx-${MASON_VERSION}.src.tar.xz"            ${MASON_BUILD_PATH}/projects/libcxx         1bc60150302ff76a0d79d6f9db22332e
    curl_get_and_uncompress "http://llvm.org/releases/${MASON_VERSION}/libcxxabi-${MASON_VERSION}.src.tar.xz"         ${MASON_BUILD_PATH}/projects/libcxxabi      3c63b03ba2f30a01279ca63384a67773
    curl_get_and_uncompress "http://llvm.org/releases/${MASON_VERSION}/libunwind-${MASON_VERSION}.src.tar.xz"         ${MASON_BUILD_PATH}/projects/libunwind      d66e2387e1d37a8a0c8fe6a0063a3bab
    curl_get_and_uncompress "http://llvm.org/releases/${MASON_VERSION}/lld-${MASON_VERSION}.src.tar.xz"               ${MASON_BUILD_PATH}/tools/lld               68cd069bf99c71ebcfbe01d557c0e14d
    curl_get_and_uncompress "http://llvm.org/releases/${MASON_VERSION}/clang-tools-extra-${MASON_VERSION}.src.tar.xz" ${MASON_BUILD_PATH}/tools/clang/tools/extra 6e49f285d0b366cc3cab782d8c92d382
}

mason_run "$@"
