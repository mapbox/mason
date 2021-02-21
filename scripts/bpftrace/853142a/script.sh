#!/usr/bin/env bash

MASON_NAME=bpftrace
MASON_VERSION=853142a
MASON_LIB_FILE=bin/bpftrace

. ${MASON_DIR}/mason.sh

function mason_load_source {
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
    if [[ ! -d ${MASON_BUILD_PATH} ]]; then
        git clone https://github.com/iovisor/bpftrace.git ${MASON_BUILD_PATH}
    fi
    (cd ${MASON_BUILD_PATH} && git checkout ${MASON_VERSION})
}

function mason_prepare_compile {
    CCACHE_VERSION=4.0
    NINJA_VERSION=1.10.1
    LLVM_VERSION=11.0.0
    ZLIB_VERSION=1.2.8
    ELF_VERSION=0.170
    BCC_VERSION=b231786
    BINUTILS_VERSION=2.35
    FLEX_VERSION=2.6.4
    ${MASON_DIR}/mason install flex ${FLEX_VERSION}
    MASON_FLEX=$(${MASON_DIR}/mason prefix flex ${FLEX_VERSION})
    ${MASON_DIR}/mason install llvm ${LLVM_VERSION}
    MASON_LLVM=$(${MASON_DIR}/mason prefix llvm ${LLVM_VERSION})
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install ninja ${NINJA_VERSION}
    MASON_NINJA=$(${MASON_DIR}/mason prefix ninja ${NINJA_VERSION})
    ${MASON_DIR}/mason install elfutils ${ELF_VERSION}
    MASON_ELFUTILS=$(${MASON_DIR}/mason prefix elfutils ${ELF_VERSION})
    ${MASON_DIR}/mason install zlib ${ZLIB_VERSION}
    MASON_ZLIB=$(${MASON_DIR}/mason prefix zlib ${ZLIB_VERSION})
    ${MASON_DIR}/mason install bcc ${BCC_VERSION}
    MASON_BCC=$(${MASON_DIR}/mason prefix bcc ${BCC_VERSION})
    ${MASON_DIR}/mason install binutils ${BINUTILS_VERSION}
    LLVM_BINUTILS_INCDIR=$(${MASON_DIR}/mason prefix binutils ${BINUTILS_VERSION})/include
}

function mason_compile {
    export CXX="${CUSTOM_CXX:-${MASON_LLVM}/bin/clang++}"
    export CC="${CUSTOM_CC:-${MASON_LLVM}/bin/clang}"
    echo "using CXX=${CXX}"
    echo "using CC=${CC}"
    echo "creating build directory"
    mkdir -p ./build
    cd ./build
    export PATH=${MASON_FLEX}/bin:${PATH}
    which flex
    perl -i -p -e "s/stdc\+\+fs/c\+\+fs/g;" ../src/CMakeLists.txt
    LINKER_FLAGS="-Wl,--start-group -L${MASON_ELFUTILS}/lib -lelf -lz -L${MASON_LLVM}/lib -lc++ -lc++abi -pthread -lc -lgcc_s"
    cmake ../ \
      -DCMAKE_PREFIX_PATH="${MASON_LLVM};${MASON_ELFUTILS}" \
      -DLIBELF_LIBRARIES=${MASON_ELFUTILS}/lib/libelf.a \
      -DLIBELF_INCLUDE_DIRS=${MASON_ELFUTILS}/include \
      -G Ninja -DCMAKE_MAKE_PROGRAM=${MASON_NINJA}/bin/ninja \
      -DCMAKE_CXX_COMPILER_LAUNCHER=${MASON_CCACHE}/bin/ccache \
      -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_COMPILER="$CXX" \
      -DCMAKE_C_COMPILER="$CC" \
      -DCMAKE_MODULE_LINKER_FLAGS="${LDFLAGS} ${LINKER_FLAGS}" \
      -DCMAKE_SHARED_LINKER_FLAGS="${LDFLAGS} ${LINKER_FLAGS}" \
      -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} ${LINKER_FLAGS}" \
      -DLIBBCC_LIBRARIES="${MASON_BCC}/lib/libbcc.a" \
      -DLIBBCC_INCLUDE_DIRS="${MASON_BCC}/include" \
      -DLIBBPF_LIBRARIES="${MASON_BCC}/lib/libbcc_bpf.a" \
      -DLIBBPF_INCLUDE_DIRS="${MASON_BCC}/include" \
      -DCMAKE_CXX_FLAGS="${CXXFLAGS} -I${LLVM_BINUTILS_INCDIR} -stdlib=libc++"
    ${MASON_NINJA}/bin/ninja bpftrace -j${MASON_CONCURRENCY}
    ${MASON_NINJA}/bin/ninja install
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
