#!/usr/bin/env bash

MASON_NAME=kcov
MASON_VERSION=894e98b
MASON_LIB_FILE=bin/kcov

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/SimonKagstrom/kcov/tarball/${MASON_VERSION} \
        e6265125e3be35cec9f9fdac74c5d92238eafcd5

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/SimonKagstrom-${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    LIBEDIT_VERSION="3.1"
    BINUTILS_VERSION="2.30"
    CMAKE_VERSION="3.8.2"
    ZLIB_VERSION="1.2.8"
    BZIP2_VERSION="1.0.6"
    ELFUTILS_VERSION="0.170"

    ${MASON_DIR}/mason install cmake ${CMAKE_VERSION}
    MASON_CMAKE=$(${MASON_DIR}/mason prefix cmake ${CMAKE_VERSION})
    ${MASON_DIR}/mason install libedit ${LIBEDIT_VERSION}
    MASON_LIBEDIT=$(${MASON_DIR}/mason prefix libedit ${LIBEDIT_VERSION})
    if [[ $(uname -s) == 'Linux' ]]; then
        ${MASON_DIR}/mason install zlib ${ZLIB_VERSION}
        MASON_ZLIB=$(${MASON_DIR}/mason prefix zlib ${ZLIB_VERSION})
        ${MASON_DIR}/mason install binutils ${BINUTILS_VERSION}
        LLVM_BINUTILS_INCDIR=$(${MASON_DIR}/mason prefix binutils ${BINUTILS_VERSION})/include
        MASON_BINUTILS=$(${MASON_DIR}/mason prefix binutils ${BINUTILS_VERSION})
        ${MASON_DIR}/mason install bzip2 ${BZIP2_VERSION}
        MASON_BZIP2=$(${MASON_DIR}/mason prefix bzip2 ${BZIP2_VERSION})
        ${MASON_DIR}/mason install elfutils ${ELFUTILS_VERSION}
        MASON_ELFUTILS=$(${MASON_DIR}/mason prefix elfutils ${ELFUTILS_VERSION})
        #CFLAGS=" ${CFLAGS} -m64 -I${MASON_ZLIB}/include -I${MASON_BINUTILS}/include -I${MASON_BZIP2}/include -I${MASON_ELFUTILS}/include"
        #LDFLAGS="${LDFLAGS}-L${MASON_BZIP2}/lib -L${MASON_ZLIB}/lib -L${MASON_ELFUTILS}/lib -L${MASON_BINUTILS}/lib"

    fi
}

function mason_compile {
    mkdir -p build && cd build
    if [[ $(uname -s) == 'Linux' ]]; then
        ${MASON_CMAKE}/bin/cmake .. \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
          -DCMAKE_CXX_COMPILER="$CXX" -DCMAKE_C_COMPILER="$CC" \
          -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS} ${CFLAGS} -I${MASON_BINUTILS}/include" \
          -DCMAKE_C_FLAGS="${CFLAGS} -I${MASON_BINUTILS}/include" \
          -DLIBELF_LIBRARY=${MASON_ELFUTILS}/lib/libelf.a \
          -DLIBELF_INCLUDE_DIR=${MASON_ELFUTILS}/include \
          -DLIBDW_LIBRARY="${MASON_ELFUTILS}/lib/libdw.a;${MASON_ELFUTILS}/lib/libebl.a" \
          -DLIBDW_INCLUDE_DIR=${MASON_ELFUTILS}/include \
          -DLIBBFD_BFD_LIBRARY=${MASON_BINUTILS}/lib/libbfd.a \
          -DLIBBFD_IBERTY_LIBRARY=${MASON_BINUTILS}/lib/libiberty.a \
          -DLIBBFD_OPCODES_LIBRARY=${MASON_BINUTILS}/lib/libopcodes.a \
          -DLIBBFD_INCLUDE_DIRS=${MASON_BINUTILS}/include
    else
        ${MASON_CMAKE}/bin/cmake .. \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
          -DCMAKE_CXX_COMPILER="$CXX" -DCMAKE_C_COMPILER="$CC" \
          -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}"
    fi
    VERBOSE=1 make
    mkdir -p ${MASON_PREFIX}/bin
    cp src/kcov ${MASON_PREFIX}/bin
    # https://github.com/SimonKagstrom/kcov/issues/166
    if [[ $(uname -s) == 'Darwin' ]]; then
        install_name_tool -change @rpath/LLDB.framework/LLDB /Applications/Xcode.app/Contents/SharedFrameworks/LLDB.framework/LLDB ${MASON_PREFIX}/bin/kcov
    fi
}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_clean {
    cd build
    make clean
}

mason_run "$@"
