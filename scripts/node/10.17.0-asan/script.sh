#!/usr/bin/env bash

MASON_NAME=node
MASON_VERSION=10.17.0-asan
MASON_VERSION2=10.17.0
MASON_LIB_FILE=bin/node

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/nodejs/node/archive/v${MASON_VERSION2}.tar.gz \
        7dae43db0a4046317056950f4b8ca616f5e16138

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/node-${MASON_VERSION2}
}

function mason_prepare_compile {
    CCACHE_VERSION=3.7.6
    CLANG_VERSION=8.0.0

    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install clang++ ${CLANG_VERSION}
    MASON_CLANG=$(${MASON_DIR}/mason prefix clang++ ${CLANG_VERSION})

    export CXX="${MASON_CCACHE}/bin/ccache ${MASON_CLANG}/bin/clang++"
    export CC="${MASON_CCACHE}/bin/ccache ${MASON_CLANG}/bin/clang"
    export LINK=${CXX}
}

function mason_compile {
    # clean up config from any previous build
    rm -f config.mk
    
    # https://github.com/nodejs/node/commit/1f143b8625c2985b4317a40f279232f562417077
    perl -i -p -e "s/Apple LLVM version/Apple \(\?:clang|LLVM\) version/g;" configure.py
    
    # don't worry about old compilers
    perl -i -p -e "s/gnu\+\+1y/c\+\+14/g;" common.gypi
    
    # strip optimization flags
    perl -i -p -e "s/self\._Appendf\(cflags, 'GCC_OPTIMIZATION_LEVEL/#/g;" tools/gyp/pylib/gyp/xcode_emulation.py
    perl -i -p -e "s/-O3/-O1/g;" node.gypi
    perl -i -p -e "s/-O3/-O1/g;" common.gypi
    perl -i -p -e "s/-O3/-O1/g;" deps/uv/common.gypi
    perl -i -p -e "s/-O3/-O1/g;" deps/v8/gypfiles/toolchain.gypi
    
    # remove hardcoding on -gdwarf-2
    perl -i -p -e "s/-gdwarf-2//g;" tools/gyp/pylib/gyp/xcode_emulation.py

    # init a git repo to avoid the nodejs Makefile
    # complaining about changes that it detects from our patches or from the parent directory
    git init .

    # disable icu
    export BUILD_INTL_FLAGS="--with-intl=none"
    export BUILD_DOWNLOAD_FLAGS=" "
    export DISABLE_V8_I18N=1
    export TAG=
    # Builds both release and debug builds
    export BUILDTYPE=Release
    export DISTTYPE=release
    export CONFIG_FLAGS="--shared-zlib"

    # remove -std=c++11, let variable in common.gypi win
    SANITIZERS="-fsanitize=address,leak,undefined,integer"
    export CXXFLAGS="${CXXFLAGS//-std=c++11} -Wno-defaulted-function-deleted -g -fno-omit-frame-pointer -O1 -D_LIBCPP_HAS_NO_ASAN=1 ${SANITIZERS} -fsanitize-recover=unsigned-integer-overflow -fno-sanitize=vptr,function -fsanitize-address-use-after-scope"
    export CFLAGS="${CFLAGS} -g -fno-omit-frame-pointer -O1 -D_LIBCPP_HAS_NO_ASAN=1 ${SANITIZERS} -fsanitize-recover=unsigned-integer-overflow -fno-sanitize=vptr,function -fsanitize-address-use-after-scope"
    export LDFLAGS="${LDFLAGS} ${SANITIZERS}"

    echo "making binary"
    # we use `make binary` to hook into PORTABLE=1
    # note, pass V=1 to see compile args (default off to avoid breaking the 4 GB log limit on travis)
    V=1  PREFIX=${MASON_PREFIX}  make binary -j2
    #${MASON_CONCURRENCY}
    ls
    echo "uncompressing binary"
    tar -xf *.tar.gz
    echo "making dir"
    mkdir -p ${MASON_PREFIX}
    echo "copying over"
    cp -r node-v${MASON_VERSION2}*/* ${MASON_PREFIX}/
}

function mason_cflags {
    :
}

function mason_static_libs {
    :
}


function mason_ldflags {
    :
}

mason_run "$@"
