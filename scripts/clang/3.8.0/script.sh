#!/usr/bin/env bash

MASON_NAME=clang
MASON_VERSION=3.8.0
MASON_LIB_FILE=bin/clang

. ${MASON_DIR}/mason.sh


# options
ENABLE_LLDB=false

function curl_get() {
    if [ ! -f $(basename ${1}) ] ; then
        mason_step "Downloading $1 to $(pwd)/$(basename ${1})"
        curl --retry 3 -f -L -O "$1"
    else
        echo "already downloaded $1 to $(pwd)/$(basename ${1})"
    fi
}

function setup_release() {
    LLVM_RELEASE=$1
    BUILD_PATH=$2
    curl_get "http://llvm.org/releases/${LLVM_RELEASE}/llvm-${LLVM_RELEASE}.src.tar.xz"
    curl_get "http://llvm.org/releases/${LLVM_RELEASE}/cfe-${LLVM_RELEASE}.src.tar.xz"
    curl_get "http://llvm.org/releases/${LLVM_RELEASE}/compiler-rt-${LLVM_RELEASE}.src.tar.xz"
    curl_get "http://llvm.org/releases/${LLVM_RELEASE}/libcxx-${LLVM_RELEASE}.src.tar.xz"
    curl_get "http://llvm.org/releases/${LLVM_RELEASE}/libcxxabi-${LLVM_RELEASE}.src.tar.xz"
    curl_get "http://llvm.org/releases/${LLVM_RELEASE}/libunwind-${LLVM_RELEASE}.src.tar.xz"
    curl_get "http://llvm.org/releases/${LLVM_RELEASE}/lld-${LLVM_RELEASE}.src.tar.xz"
    if [[ ${ENABLE_LLDB} == true ]]; then
        curl_get "http://llvm.org/releases/${LLVM_RELEASE}/lldb-${LLVM_RELEASE}.src.tar.xz"
    fi
    curl_get "http://llvm.org/releases/${LLVM_RELEASE}/openmp-${LLVM_RELEASE}.src.tar.xz"
    curl_get "http://llvm.org/releases/${LLVM_RELEASE}/clang-tools-extra-${LLVM_RELEASE}.src.tar.xz"
    for i in $(ls *.xz); do
        echo "unpacking $i"
        tar xf $i;
    done
    mv llvm-${LLVM_RELEASE}.src/* ${BUILD_PATH}/
    ls ${BUILD_PATH}/
    mv cfe-${LLVM_RELEASE}.src ${BUILD_PATH}/tools/clang
    mv compiler-rt-${LLVM_RELEASE}.src ${BUILD_PATH}/projects/compiler-rt
    mv libcxx-${LLVM_RELEASE}.src ${BUILD_PATH}/projects/libcxx
    mv libcxxabi-${LLVM_RELEASE}.src ${BUILD_PATH}/projects/libcxxabi
    mv libunwind-${LLVM_RELEASE}.src ${BUILD_PATH}/projects/libunwind
    mv lld-${LLVM_RELEASE}.src ${BUILD_PATH}/tools/lld
    if [[ ${ENABLE_LLDB} == true ]]; then
        mv lldb-${LLVM_RELEASE}.src ${BUILD_PATH}/tools/lldb
    fi
    mv openmp-${LLVM_RELEASE}.src ${BUILD_PATH}/projects/openmp
    mv clang-tools-extra-${LLVM_RELEASE}.src ${BUILD_PATH}/tools/clang/tools/extra
    cd ../
}


function mason_load_source {
    mkdir -p "${MASON_ROOT}/.cache"
    cd "${MASON_ROOT}/.cache"
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/llvm-${MASON_VERSION}
    mkdir -p ${MASON_BUILD_PATH}/
    setup_release ${MASON_VERSION} ${MASON_BUILD_PATH}
}

function mason_compile {
    CLANG_GIT_REV=$(git -C tools/clang/ rev-list --max-count=1 HEAD)
    mkdir -p ./build
    cd ./build
    CMAKE_EXTRA_ARGS=""
    if [[ $(uname -s) == 'Darwin' ]]; then
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DCLANG_DEFAULT_CXX_STDLIB=libc++"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DC_INCLUDE_DIRS=:/usr/include:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1/"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DDEFAULT_SYSROOT=/"
    fi
    cmake ../ -G Ninja -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
     -DCMAKE_BUILD_TYPE=Release \
     -DLLVM_ENABLE_ASSERTIONS=OFF \
     -DCLANG_VENDOR=mapbox/mason \
     -DCLANG_REPOSITORY_STRING=https://github.com/mapbox/mason \
     -DCLANG_APPEND_VC_REV=$CLANG_GIT_REV \
     -DCLANG_VENDOR_UTI=org.mapbox.clang \
     -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
     -DCMAKE_CXX_FLAGS_RELEASE="${CXXFLAGS}" \
     -DLLVM_OPTIMIZED_TABLEGEN=ON \
     ${CMAKE_EXTRA_ARGS}
    ninja -j${JOBS} -k5
    ninja install -k5
    # manual install of tools that don't get installed right
    cp build/Release/bin/include-what-you-use ${MASON_PREFIX}/bin

}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_static_libs {
    :
}

mason_run "$@"
