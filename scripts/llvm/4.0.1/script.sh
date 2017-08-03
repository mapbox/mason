#!/usr/bin/env bash

# For context on this file see https://github.com/mapbox/mason/blob/master/scripts/llvm/base/README.md

# dynamically determine the path to this package
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
# dynamically take name of package from directory
MASON_NAME=$(basename $(dirname $HERE))
# dynamically take the version of the package from directory
MASON_VERSION=$(basename $HERE)
# inherit all functions from llvm base
source ${HERE}/../../${MASON_NAME}/base/common.sh

function setup_release() {
    # usage: get_llvm_project [url or git url] [path to download to] <optional hash of download> <optional gitsha to pin to> 
    get_llvm_project "http://llvm.org/releases/${MASON_VERSION}/llvm-${MASON_VERSION}.src.tar.xz"              ${MASON_BUILD_PATH}/                        
    get_llvm_project "http://llvm.org/releases/${MASON_VERSION}/cfe-${MASON_VERSION}.src.tar.xz"               ${MASON_BUILD_PATH}/tools/clang             
    get_llvm_project "http://llvm.org/releases/${MASON_VERSION}/compiler-rt-${MASON_VERSION}.src.tar.xz"       ${MASON_BUILD_PATH}/projects/compiler-rt    
    if [[ ${BUILD_AND_LINK_LIBCXX} == true ]]; then
        get_llvm_project "http://llvm.org/releases/${MASON_VERSION}/libcxx-${MASON_VERSION}.src.tar.xz"        ${MASON_BUILD_PATH}/projects/libcxx     
        get_llvm_project "http://llvm.org/releases/${MASON_VERSION}/libcxxabi-${MASON_VERSION}.src.tar.xz"     ${MASON_BUILD_PATH}/projects/libcxxabi  
        get_llvm_project "http://llvm.org/releases/${MASON_VERSION}/libunwind-${MASON_VERSION}.src.tar.xz"     ${MASON_BUILD_PATH}/projects/libunwind  
    fi
    get_llvm_project "http://llvm.org/releases/${MASON_VERSION}/lld-${MASON_VERSION}.src.tar.xz"               ${MASON_BUILD_PATH}/tools/lld               
    get_llvm_project "http://llvm.org/releases/${MASON_VERSION}/clang-tools-extra-${MASON_VERSION}.src.tar.xz" ${MASON_BUILD_PATH}/tools/clang/tools/extra 
    get_llvm_project "http://llvm.org/releases/${MASON_VERSION}/lldb-${MASON_VERSION}.src.tar.xz"              ${MASON_BUILD_PATH}/tools/lldb              
    get_llvm_project "https://github.com/include-what-you-use/include-what-you-use/archive/clang_${MAJOR_MINOR}.tar.gz" ${MASON_BUILD_PATH}/tools/clang/tools/include-what-you-use
    # Note: the below commented line uses a custom gitsha to pin to a working commit if the include-what-you-use team has not yet created a tag for the given clang major version
    # This happended previously a https://github.com/include-what-you-use/include-what-you-use/issues/397#issuecomment-313479507
    #get_llvm_project "https://github.com/include-what-you-use/include-what-you-use.git"  ${MASON_BUILD_PATH}/tools/clang/tools/include-what-you-use "" 45e1264507f5e2725289ca3a0f4de98108e964c7
}

mason_run "$@"
