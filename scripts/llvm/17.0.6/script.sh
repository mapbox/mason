#!/usr/bin/env bash

# LLVM 17.0.6 - Uses monorepo structure (different from older LLVM versions)

# dynamically determine the path to this package
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
MASON_NAME=$(basename $(dirname $HERE))
MASON_VERSION=$(basename $HERE)
MASON_LIB_FILE=bin/clang

. ${MASON_DIR}/mason.sh

export MASON_BASE_VERSION=${MASON_BASE_VERSION:-${MASON_VERSION}}
export MAJOR_MINOR=$(echo ${MASON_BASE_VERSION} | cut -d '.' -f1-2)

if [[ $(uname -s) == 'Darwin' ]]; then
    export BUILD_AND_LINK_LIBCXX=true
    export INSTALL_LIBCXX=true
else
    export BUILD_AND_LINK_LIBCXX=${BUILD_AND_LINK_LIBCXX:-true}
    export INSTALL_LIBCXX=${INSTALL_LIBCXX:-true}
fi

function mason_load_source {
    mkdir -p "${MASON_ROOT}/.cache"
    cd "${MASON_ROOT}/.cache"

    # LLVM 17 uses a single monorepo tarball
    local LLVM_TARBALL="llvm-project-${MASON_VERSION}.src.tar.xz"
    local LLVM_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-${MASON_VERSION}/${LLVM_TARBALL}"

    if [ ! -f "${LLVM_TARBALL}" ]; then
        mason_step "Downloading ${LLVM_URL}..."
        curl -f -L -o "${LLVM_TARBALL}" "${LLVM_URL}"
    fi

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/llvm-project-${MASON_VERSION}.src
    mkdir -p "${MASON_ROOT}/.build"

    if [[ -d ${MASON_BUILD_PATH}/ ]]; then
        rm -rf ${MASON_BUILD_PATH}/
    fi

    cd "${MASON_ROOT}/.build"
    mason_step "Extracting ${LLVM_TARBALL}..."
    tar xf "../.cache/${LLVM_TARBALL}"
}

function mason_prepare_compile {
    CCACHE_VERSION=4.0
    CMAKE_VERSION=3.31.0
    NINJA_VERSION=1.10.1
    LIBEDIT_VERSION=3.1
    NCURSES_VERSION=6.1
    BINUTILS_VERSION=2.35

    # Only install dependencies, skip bootstrap LLVM if using custom compiler
    if [[ -z "${CUSTOM_CC:-}" ]] && [[ -z "${CUSTOM_CXX:-}" ]]; then
        mason_error "LLVM 17.0.6 requires a C++17 compiler."
        mason_error "Please set CUSTOM_CC and CUSTOM_CXX environment variables:"
        mason_error "  export CUSTOM_CC=/usr/bin/clang"
        mason_error "  export CUSTOM_CXX=/usr/bin/clang++"
        mason_error ""
        mason_error "Or install LLVM 11.0.0 first:"
        mason_error "  ./mason install llvm 11.0.0"
        exit 1
    else
        mason_step "Using custom compiler: CC=${CUSTOM_CC} CXX=${CUSTOM_CXX}"
    fi

    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install cmake ${CMAKE_VERSION}
    MASON_CMAKE=$(${MASON_DIR}/mason prefix cmake ${CMAKE_VERSION})
    ${MASON_DIR}/mason install ninja ${NINJA_VERSION}
    MASON_NINJA=$(${MASON_DIR}/mason prefix ninja ${NINJA_VERSION})
    ${MASON_DIR}/mason install libedit ${LIBEDIT_VERSION}
    MASON_LIBEDIT=$(${MASON_DIR}/mason prefix libedit ${LIBEDIT_VERSION})
    ${MASON_DIR}/mason install ncurses ${NCURSES_VERSION}
    MASON_NCURSES=$(${MASON_DIR}/mason prefix ncurses ${NCURSES_VERSION})

    if [[ $(uname -s) == 'Linux' ]]; then
        ${MASON_DIR}/mason install binutils ${BINUTILS_VERSION}
        LLVM_BINUTILS_INCDIR=$(${MASON_DIR}/mason prefix binutils ${BINUTILS_VERSION})/include
    fi
}

function mason_compile {
    export CXX="${CUSTOM_CXX:-clang++}"
    export CC="${CUSTOM_CC:-clang}"
    echo "using CXX=${CXX}"
    echo "using CC=${CC}"

    CMAKE_EXTRA_ARGS=""

    if [[ $(uname -s) == 'Darwin' ]]; then
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLDB_USE_SYSTEM_DEBUGSERVER=ON"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DC_INCLUDE_DIRS=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DDEFAULT_SYSROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DCLANG_DEFAULT_CXX_STDLIB=libc++"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLVM_CREATE_XCODE_TOOLCHAIN=OFF -DLLVM_EXTERNALIZE_DEBUGINFO=ON"
    fi

    if [[ $(uname -s) == 'Linux' ]]; then
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLVM_BINUTILS_INCDIR=${LLVM_BINUTILS_INCDIR}"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DCLANG_DEFAULT_CXX_STDLIB=libstdc++"
    fi

    if [[ ${INSTALL_LIBCXX} == false ]]; then
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLIBCXX_INSTALL_LIBRARY=OFF -DLIBCXX_INSTALL_HEADERS=OFF"
    fi

    # Strip old deployment target flags
    if [[ $(uname -s) == 'Darwin' ]]; then
        export CXXFLAGS="${CXXFLAGS//-mmacosx-version-min=10.8}"
        export LDFLAGS="${LDFLAGS//-mmacosx-version-min=10.8}"
    fi

    export CXXFLAGS="${CXXFLAGS//-std=c++11}"

    if [[ ${BUILD_AND_LINK_LIBCXX} == true ]]; then
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLIBCXX_ENABLE_ASSERTIONS=OFF -DLIBUNWIND_ENABLE_ASSERTIONS=OFF"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLIBCXXABI_USE_COMPILER_RT=ON -DLIBCXX_USE_COMPILER_RT=ON"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLIBCXXABI_ENABLE_ASSERTIONS=OFF -DLIBCXX_ENABLE_SHARED=OFF"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLIBCXX_ENABLE_STATIC=ON -DLIBCXXABI_ENABLE_SHARED=OFF"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLIBCXXABI_USE_LLVM_UNWINDER=ON -DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLIBUNWIND_USE_COMPILER_RT=ON -DLIBUNWIND_ENABLE_STATIC=ON"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLIBUNWIND_ENABLE_SHARED=OFF"
    fi

    if [[ $(uname -s) == 'Linux' ]]; then
        export CXXFLAGS="${CXXFLAGS} -I${MASON_LIBEDIT}/include/ -I${MASON_NCURSES}/include/ -I${MASON_NCURSES}/include/ncursesw/"
    fi

    if [[ ${BUILD_AND_LINK_LIBCXX} == true ]]; then
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLVM_ENABLE_LIBCXX=ON"
        if [[ $(uname -s) == 'Linux' ]]; then
            CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLVM_ENABLE_LLD=ON"
            # Only add MASON_LLVM to path if it's set (when using bootstrap LLVM)
            if [[ -n "${MASON_LLVM:-}" ]]; then
                export PATH=${MASON_LLVM}/bin:${PATH}
            fi
        fi
    fi

    echo "creating build directory"
    mkdir -p ./build
    cd ./build

    # Key difference: For monorepo, we need to specify which projects to build
    export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -G Ninja -DCMAKE_MAKE_PROGRAM=${MASON_NINJA}/bin/ninja"
    export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;lld;lldb;polly'"
    export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLVM_ENABLE_RUNTIMES='compiler-rt;libcxx;libcxxabi;libunwind;openmp'"
    export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLVM_ENABLE_ASSERTIONS=OFF -DCLANG_VENDOR=mapbox/mason"
    export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} -DCMAKE_BUILD_TYPE=MinSizeRel"
    export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLVM_INCLUDE_DOCS=OFF -DLLVM_TARGETS_TO_BUILD=BPF;X86;WebAssembly"
    export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DCLANG_REPOSITORY_STRING=https://github.com/mapbox/mason"
    export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DCLANG_VENDOR_UTI=org.mapbox.llvm"
    export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLVM_ENABLE_TERMINFO=0 -DLLVM_INCLUDE_EXAMPLES=OFF"
    export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLVM_ENABLE_UNWIND_TABLES=OFF -DLLVM_ENABLE_EH=ON -DLLVM_ENABLE_RTTI=ON"
    export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DCMAKE_PREFIX_PATH=${MASON_NCURSES};${MASON_LIBEDIT}"

    if [[ -n "${MASON_CCACHE:-}" ]]; then
        export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DCMAKE_CXX_COMPILER_LAUNCHER=${MASON_CCACHE}/bin/ccache"
    fi

    echo "running cmake configure for llvm+friends build"
    echo "All cmake options: '${CMAKE_EXTRA_ARGS}'"

    # For monorepo, we configure from the llvm subdirectory
    if [[ $(uname -s) == 'Linux' ]]; then
        ${MASON_CMAKE}/bin/cmake ../llvm ${CMAKE_EXTRA_ARGS} \
        -DCMAKE_CXX_STANDARD_LIBRARIES="-L${MASON_LIBEDIT}/lib -L${MASON_NCURSES}/lib -L$(pwd)/lib -lc++ -lc++abi -lunwind -pthread -lc -ldl -lrt -rtlib=compiler-rt" \
        -DCMAKE_CXX_COMPILER="$CXX" -DCMAKE_C_COMPILER="$CC" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}"
    else
        ${MASON_CMAKE}/bin/cmake ../llvm ${CMAKE_EXTRA_ARGS} \
        -DCMAKE_CXX_COMPILER="$CXX" -DCMAKE_C_COMPILER="$CC" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}"
    fi

    if [[ ${BUILD_AND_LINK_LIBCXX} == true ]]; then
        ${MASON_NINJA}/bin/ninja unwind -j${MASON_CONCURRENCY}
        ${MASON_NINJA}/bin/ninja cxx -j${MASON_CONCURRENCY}
        ${MASON_NINJA}/bin/ninja lldb -j${MASON_CONCURRENCY}
    fi

    # Build and install
    ${MASON_NINJA}/bin/ninja -j${MASON_CONCURRENCY}
    ${MASON_NINJA}/bin/ninja install

    # Install asan_symbolizer
    local ASAN_SYMBOLIZER="../compiler-rt/lib/asan/scripts/asan_symbolize.py"
    if [ -f "${ASAN_SYMBOLIZER}" ]; then
        cp -a "${ASAN_SYMBOLIZER}" ${MASON_PREFIX}/bin/
    fi

    # Set up symlinks
    local CONFIG_MAJOR_MINOR=$(${MASON_PREFIX}/bin/llvm-config --version | cut -d '.' -f1-2)
    (cd ${MASON_PREFIX}/bin/ && \
        ln -sf "clang++" "clang++-${CONFIG_MAJOR_MINOR}" && \
        ln -sf "asan_symbolize.py" "asan_symbolize" 2>/dev/null || true)

    # Build sanitizer variants of libc++
    if [[ ${BUILD_AND_LINK_LIBCXX} == true ]]; then
        # Address+Undefined
        echo "Building libc++ with address+undefined sanitizers"
        ${MASON_CMAKE}/bin/cmake ../runtimes \
            ${CMAKE_EXTRA_ARGS} -DCMAKE_CXX_COMPILER="$CXX" -DCMAKE_C_COMPILER="$CC" \
            -DCMAKE_INSTALL_PREFIX="${MASON_PREFIX}/asan" \
            -DLLVM_USE_SANITIZER="Address;Undefined" \
            -DLIBCXX_INSTALL_LIBRARY=ON -DLIBCXX_INSTALL_HEADERS=ON
        ${MASON_NINJA}/bin/ninja cxx cxxabi -j${MASON_CONCURRENCY}
        ${MASON_NINJA}/bin/ninja install-cxx install-cxxabi -j${MASON_CONCURRENCY}

        # Thread
        echo "Building libc++ with thread sanitizer"
        ${MASON_CMAKE}/bin/cmake ../runtimes \
            ${CMAKE_EXTRA_ARGS} -DCMAKE_CXX_COMPILER="$CXX" -DCMAKE_C_COMPILER="$CC" \
            -DCMAKE_INSTALL_PREFIX="${MASON_PREFIX}/tsan" \
            -DLLVM_USE_SANITIZER="Thread" \
            -DLIBCXX_INSTALL_LIBRARY=ON -DLIBCXX_INSTALL_HEADERS=ON
        ${MASON_NINJA}/bin/ninja cxx cxxabi -j${MASON_CONCURRENCY}
        ${MASON_NINJA}/bin/ninja install-cxx install-cxxabi -j${MASON_CONCURRENCY}

        # Memory (Linux only)
        if [[ $(uname -s) != 'Darwin' ]]; then
            echo "Building libc++ with memory sanitizer"
            ${MASON_CMAKE}/bin/cmake ../runtimes \
                ${CMAKE_EXTRA_ARGS} -DCMAKE_CXX_COMPILER="$CXX" -DCMAKE_C_COMPILER="$CC" \
                -DCMAKE_INSTALL_PREFIX="${MASON_PREFIX}/msan" \
                -DLLVM_USE_SANITIZER="MemoryWithOrigins" \
                -DLIBCXX_INSTALL_LIBRARY=ON -DLIBCXX_INSTALL_HEADERS=ON
            ${MASON_NINJA}/bin/ninja cxx cxxabi -j${MASON_CONCURRENCY}
            ${MASON_NINJA}/bin/ninja install-cxx install-cxxabi -j${MASON_CONCURRENCY}
        fi
    fi
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
