#!/usr/bin/env bash

MASON_NAME=clang
MASON_VERSION=4.x
MASON_LIB_FILE=bin/clang

. ${MASON_DIR}/mason.sh

# options
ENABLE_LLDB=false

function git_get() {
    if [ ! -d ${2} ] ; then
        mason_step "Downloading $1 to ${2}"
        git clone --depth 1 ${1} ${2}
    else
        mason_step "Already downloaded $1 to ${2}"
    fi
}

function setup() {
    LLVM_RELEASE=$1
    BUILD_PATH=$2
    git_get http://llvm.org/git/llvm.git ${LLVM_RELEASE}/llvm
    git_get http://llvm.org/git/clang.git ${LLVM_RELEASE}/llvm/tools/clang
    if [[ ${ENABLE_LLDB} == true ]]; then
        git_get http://llvm.org/git/lldb.git ${LLVM_RELEASE}/llvm/tools/lldb
    fi
    git_get http://llvm.org/git/clang-tools-extra.git ${LLVM_RELEASE}/llvm/tools/clang/tools/extra
    git_get https://github.com/include-what-you-use/include-what-you-use.git ${LLVM_RELEASE}/llvm/tools/clang/tools/include-what-you-use
    #git_get http://llvm.org/git/libcxx.git ${LLVM_RELEASE}/llvm/projects/libcxx
    #git_get http://llvm.org/git/libcxxabi.git ${LLVM_RELEASE}/llvm/projects/libcxxabi
    #git_get http://llvm.org/git/libunwind.git ${LLVM_RELEASE}/llvm/projects/libunwind
    # git_get http://llvm.org/git/lld.git ${LLVM_RELEASE}/llvm/projects/lld
    git_get http://llvm.org/git/compiler-rt.git ${LLVM_RELEASE}/llvm/projects/compiler-rt
    cp -r ${LLVM_RELEASE}/llvm/* ${BUILD_PATH}/
}

function mason_load_source {
    mkdir -p "${MASON_ROOT}/.cache"
    cd "${MASON_ROOT}/.cache"
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/llvm-${MASON_VERSION}
    if [[ -d ${MASON_BUILD_PATH}/ ]]; then
        rm -rf ${MASON_BUILD_PATH}/
    fi
    mkdir -p ${MASON_BUILD_PATH}/
    setup ${MASON_VERSION} ${MASON_BUILD_PATH}
}

function mason_prepare_compile {
    ${MASON_DIR}/mason install ccache 3.3.0
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache 3.3.0)
    ${MASON_DIR}/mason install clang 3.8.0
    MASON_CLANG=$(${MASON_DIR}/mason prefix clang 3.8.0)
    ${MASON_DIR}/mason install cmake 3.5.2
    MASON_CMAKE=$(${MASON_DIR}/mason prefix cmake 3.5.2)
    ${MASON_DIR}/mason install ninja 1.7.1
    MASON_NINJA=$(${MASON_DIR}/mason prefix ninja 1.7.1)
}

function mason_compile {
    export CXX="${MASON_CLANG}/bin/clang++"
    export CC="${MASON_CLANG}/bin/clang"
    CLANG_GIT_REV=$(git -C tools/clang/ rev-list --max-count=1 HEAD)
    mkdir -p ./build
    cd ./build
    CMAKE_EXTRA_ARGS=""
    ## TODO: CLANG_DEFAULT_CXX_STDLIB and CLANG_APPEND_VC_REV not available in clang-3.8 cmake files
    if [[ $(uname -s) == 'Darwin' ]]; then
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DCLANG_DEFAULT_CXX_STDLIB=libc++"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DC_INCLUDE_DIRS=:/usr/include:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1/:/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk/usr/include/"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DDEFAULT_SYSROOT=/"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DCMAKE_OSX_DEPLOYMENT_TARGET=10.11"
    fi
    CXXFLAGS="${CXXFLAGS//-mmacosx-version-min=10.8}"
    ${MASON_CMAKE}/bin/cmake ../ -G Ninja -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
     -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_CXX_COMPILER_LAUNCHER="${MASON_CCACHE}/bin/ccache" \
     -DCMAKE_CXX_COMPILER="$CXX" \
     -DCMAKE_C_COMPILER="$CC" \
     -DLLVM_ENABLE_ASSERTIONS=OFF \
     -DCLANG_VENDOR=mapbox/mason \
     -DCLANG_REPOSITORY_STRING=https://github.com/mapbox/mason \
     -DCLANG_APPEND_VC_REV=$CLANG_GIT_REV \
     -DCLANG_VENDOR_UTI=org.mapbox.clang \
     -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
     -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
     -DLLVM_OPTIMIZED_TABLEGEN=ON \
     -DCMAKE_MAKE_PROGRAM=${MASON_NINJA}/bin/ninja \
     ${CMAKE_EXTRA_ARGS}
    ${MASON_NINJA}/bin/ninja -j${MASON_CONCURRENCY} -k5
    ${MASON_NINJA}/bin/ninja install -k5
    cd ${MASON_PREFIX}/bin/
    rm -f "clang++-4.0"
    ln -s "clang++" "clang++-4.0"
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
