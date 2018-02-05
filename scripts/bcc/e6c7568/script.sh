#!/usr/bin/env bash

MASON_NAME=bcc
MASON_VERSION=e6c7568
MASON_LIB_FILE=lib/libbcc.so

. ${MASON_DIR}/mason.sh

function mason_load_source {
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
    if [[ ! -d ${MASON_BUILD_PATH} ]]; then
        git clone https://github.com/iovisor/bcc.git ${MASON_BUILD_PATH}
    fi
    (cd ${MASON_BUILD_PATH} && git checkout ${MASON_VERSION})
}

function mason_prepare_compile {
    CCACHE_VERSION=3.3.4
    CMAKE_VERSION=3.8.2
    NINJA_VERSION=1.7.2
    LLVM_VERSION=5.0.0
    ZLIB_VERSION=1.2.8
    ELF_VERSION=0.170
    ${MASON_DIR}/mason install llvm ${LLVM_VERSION}
    MASON_LLVM=$(${MASON_DIR}/mason prefix llvm ${LLVM_VERSION})
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install cmake ${CMAKE_VERSION}
    MASON_CMAKE=$(${MASON_DIR}/mason prefix cmake ${CMAKE_VERSION})
    ${MASON_DIR}/mason install ninja ${NINJA_VERSION}
    MASON_NINJA=$(${MASON_DIR}/mason prefix ninja ${NINJA_VERSION})
    ${MASON_DIR}/mason install elfutils ${ELF_VERSION}
    MASON_ELFUTILS=$(${MASON_DIR}/mason prefix elfutils ${ELF_VERSION})
    ${MASON_DIR}/mason install zlib ${ZLIB_VERSION}
    MASON_ZLIB=$(${MASON_DIR}/mason prefix zlib ${ZLIB_VERSION})

}

function mason_compile {
    echo "creating build directory"
    mkdir -p ./build
    cd ./build
    LINKER_FLAGS="-Wl,--start-group -L${MASON_ELFUTILS}/lib -L${MASON_LLVM}/lib -lc++ -lc++abi -pthread -lc -lgcc_s"
    ${MASON_CMAKE}/bin/cmake ../ \
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
      -DCMAKE_CXX_FLAGS="${CXXFLAGS} -stdlib=libc++ -include sched.h -include errno.h"
    # TODO: remove -include: https://github.com/iovisor/bcc/pull/1573
    ${MASON_NINJA}/bin/ninja libbcc.a -j${MASON_CONCURRENCY}
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
