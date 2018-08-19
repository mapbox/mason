#!/usr/bin/env bash

MASON_NAME=llvm
MASON_LIB_FILE=bin/clang

. ${MASON_DIR}/mason.sh

export MASON_BASE_VERSION=${MASON_BASE_VERSION:-${MASON_VERSION}}
export MAJOR_MINOR=$(echo ${MASON_BASE_VERSION} | cut -d '.' -f1-2)

if [[ $(uname -s) == 'Darwin' ]]; then
    export BUILD_AND_LINK_LIBCXX=true

    # not installing libcxx avoids this kind of problem with include-what-you-use
    export INSTALL_LIBCXX=true
    # because iwyu hardcodes at https://github.com/include-what-you-use/include-what-you-use/blob/da5c9b17fec571e6b2bbca29145463d7eaa3582e/iwyu_driver.cc#L219
    : '
    /Library/Developer/CommandLineTools/usr/include/c++/v1/cstdlib:167:44: error: declaration conflicts with target of using declaration already in scope
    inline _LIBCPP_INLINE_VISIBILITY long      abs(     long __x) _NOEXCEPT {return  labs(__x);}
                                               ^
    /Users/dane/.mason/mason_packages/osx-x86_64/llvm/3.9.0/bin/../include/c++/v1/stdlib.h:115:44: note: target of using declaration
    inline _LIBCPP_INLINE_VISIBILITY long      abs(     long __x) _NOEXCEPT {return  labs(__x);}
    '
else
    export BUILD_AND_LINK_LIBCXX=${BUILD_AND_LINK_LIBCXX:-true}
    export INSTALL_LIBCXX=${INSTALL_LIBCXX:-true}
fi

# we use this custom function rather than "mason_download" since we need to easily grab multiple packages
# get_llvm_project [url or git url] [path to download to] <optional hash of download> <optional gitsha to pin to>
function get_llvm_project() {
    local URL=${1}
    local TO_DIR=${2}
    if [[ ${TO_DIR:-false} == false ]]; then
        mason_error "TO_DIR unset"
        exit 1
    fi
    local EXPECTED_HASH=${3:-false}
    local CUSTOM_GITSHA=${4:-false}
    local DEPTH=1
    if [[ ${CUSTOM_GITSHA:-false} == false ]]; then
        DEPTH=500
    fi
    local file_basename=$(basename ${URL})
    local local_file_or_checkout=$(pwd)/${file_basename}
    if [[ ${URL} =~ '.git' ]]; then
        if [ ! -d ${local_file_or_checkout} ] ; then
            mason_step "cloning ${URL} to ${local_file_or_checkout}"
            git clone --depth ${DEPTH} ${URL} ${local_file_or_checkout}
        else
            mason_substep "already cloned ${URL}, pulling to update"
            (cd ${local_file_or_checkout} && echo "pulling ${local_file_or_checkout}" && git pull)
        fi
        if [[ ${CUSTOM_GITSHA:-false} != false ]]; then
            (cd ${local_file_or_checkout} && git fetch && git checkout ${CUSTOM_GITSHA})
        fi
        mason_step "moving ${local_file_or_checkout} into place at ${TO_DIR}"
        cp -r ${local_file_or_checkout} ${TO_DIR}
    else
        if [ ! -f ${local_file_or_checkout} ] ; then
            mason_step "Downloading ${URL} to ${local_file_or_checkout}"
            curl --retry 3 -f -L -O "${URL}"
        else
            mason_substep "already downloaded $1 to ${local_file_or_checkout}"
        fi
        export OBJECT_HASH=$(git hash-object ${local_file_or_checkout})
        if [[ ${EXPECTED_HASH:-false} == false ]]; then
            mason_error "NOTICE: detected object has of ${OBJECT_HASH}, optionally add this hash to the 'setup_release' function in your script.sh in order to assert this never changes"
        else
            if [[ $3 != ${OBJECT_HASH} ]]; then
                mason_error "Error: hash mismatch ${EXPECTED_HASH} (expected) != ${OBJECT_HASH} (actual)"
                exit 1
            else
                mason_success "Success: hash matched: ${EXPECTED_HASH} (expected) == ${OBJECT_HASH} (actual)"
            fi
        fi
        mason_step "uncompressing ${local_file_or_checkout}"
        mkdir -p ./checkout
        rm -rf ./checkout/*
        tar xf ${local_file_or_checkout} --strip-components=1 --directory=./checkout
        mkdir -p ${TO_DIR}
        mv checkout/* ${TO_DIR}/
    fi
}

function setup_base_tools() {
    get_llvm_project "http://llvm.org/releases/${MASON_BASE_VERSION}/llvm-${MASON_BASE_VERSION}.src.tar.xz"              ${MASON_BUILD_PATH}/
    get_llvm_project "http://llvm.org/releases/${MASON_BASE_VERSION}/cfe-${MASON_BASE_VERSION}.src.tar.xz"               ${MASON_BUILD_PATH}/tools/clang
    get_llvm_project "http://llvm.org/releases/${MASON_BASE_VERSION}/compiler-rt-${MASON_BASE_VERSION}.src.tar.xz"       ${MASON_BUILD_PATH}/projects/compiler-rt
    if [[ ${BUILD_AND_LINK_LIBCXX} == true ]]; then
        get_llvm_project "http://llvm.org/releases/${MASON_BASE_VERSION}/libcxx-${MASON_BASE_VERSION}.src.tar.xz"        ${MASON_BUILD_PATH}/projects/libcxx
        get_llvm_project "http://llvm.org/releases/${MASON_BASE_VERSION}/libcxxabi-${MASON_BASE_VERSION}.src.tar.xz"     ${MASON_BUILD_PATH}/projects/libcxxabi
        get_llvm_project "http://llvm.org/releases/${MASON_BASE_VERSION}/libunwind-${MASON_BASE_VERSION}.src.tar.xz"     ${MASON_BUILD_PATH}/projects/libunwind
    fi
    get_llvm_project "http://llvm.org/releases/${MASON_BASE_VERSION}/openmp-${MASON_BASE_VERSION}.src.tar.xz"            ${MASON_BUILD_PATH}/projects/openmp
    get_llvm_project "http://llvm.org/releases/${MASON_BASE_VERSION}/lld-${MASON_BASE_VERSION}.src.tar.xz"               ${MASON_BUILD_PATH}/tools/lld
    get_llvm_project "http://llvm.org/releases/${MASON_BASE_VERSION}/clang-tools-extra-${MASON_BASE_VERSION}.src.tar.xz" ${MASON_BUILD_PATH}/tools/clang/tools/extra
    get_llvm_project "http://llvm.org/releases/${MASON_BASE_VERSION}/lldb-${MASON_BASE_VERSION}.src.tar.xz"              ${MASON_BUILD_PATH}/tools/lldb
    get_llvm_project "http://llvm.org/releases/${MASON_BASE_VERSION}/polly-${MASON_BASE_VERSION}.src.tar.xz"             ${MASON_BUILD_PATH}/tools/polly
    # The include-what-you-use project often lags behind llvm releases, causing compile problems when you try to build it within llvm (and I don't know how feasible it is to build separately)
    # Hence this is disabled by default and must be either enabled here or added to a `setup_release` function per package version
    # pulls from a tagged version:
    #get_llvm_project "https://github.com/include-what-you-use/include-what-you-use/archive/clang_${MAJOR_MINOR}.tar.gz" ${MASON_BUILD_PATH}/tools/clang/tools/include-what-you-use
    # pulls from a gitsha (useful to pin to a working commit if the include-what-you-use team has not yet created a tag for the given clang major version)
    # This happened previously with https://github.com/include-what-you-use/include-what-you-use/issues/397#issuecomment-313479507
    #get_llvm_project "https://github.com/include-what-you-use/include-what-you-use.git"  ${MASON_BUILD_PATH}/tools/clang/tools/include-what-you-use "" 45e1264507f5e2725289ca3a0f4de98108e964c7

}

# Note: add `setup_release` function to downstream script to override this stub and be able to install custom tools per version
function setup_release() {
    :
}

function mason_load_source {
    mkdir -p "${MASON_ROOT}/.cache"
    cd "${MASON_ROOT}/.cache"
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/llvm-${MASON_BASE_VERSION}
    mkdir -p "${MASON_ROOT}/.build"
    if [[ -d ${MASON_BUILD_PATH}/ ]]; then
        rm -rf ${MASON_BUILD_PATH}/
    fi
    setup_base_tools
    # NOTE: this setup_release can be overridden per package to assert on different hash
    setup_release
}

function mason_prepare_compile {
    CCACHE_VERSION=3.3.4
    CMAKE_VERSION=3.8.2
    NINJA_VERSION=1.7.2
    CLANG_VERSION=5.0.0
    LIBEDIT_VERSION=3.1
    BINUTILS_VERSION=2.31
    NCURSES_VERSION=6.1

    ${MASON_DIR}/mason install clang++ ${CLANG_VERSION}
    MASON_CLANG=$(${MASON_DIR}/mason prefix clang++ ${CLANG_VERSION})
    ${MASON_DIR}/mason install llvm ${CLANG_VERSION}
    MASON_LLVM=$(${MASON_DIR}/mason prefix llvm ${CLANG_VERSION})
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
    export CXX="${CUSTOM_CXX:-${MASON_CLANG}/bin/clang++}"
    export CC="${CUSTOM_CC:-${MASON_CLANG}/bin/clang}"
    echo "using CXX=${CXX}"
    echo "using CC=${CC}"

    # knock out lldb doc building, to remove doxygen dependency
    perl -i -p -e "s/add_subdirectory\(docs\)//g;" tools/lldb/CMakeLists.txt

    # remove /usr/local/include from default paths (targeting linux)
    # because we want users to have to explictly link things in /usr/local to avoid conflicts
    # between mason and homebrew or source installs
    perl -i -p -e "s/AddPath\(\"\/usr\/local\/include\"\, System\, false\)\;//g;" tools/clang/lib/Frontend/InitHeaderSearch.cpp

    CMAKE_EXTRA_ARGS=""

    if [[ $(uname -s) == 'Darwin' ]]; then
        # don't require codesigning for macOS
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLDB_CODESIGN_IDENTITY=''"
    fi

    if [[ ${MAJOR_MINOR} == "3.8" ]]; then
        # workaround https://llvm.org/bugs/show_bug.cgi?id=25565
        perl -i -p -e "s/set\(codegen_deps intrinsics_gen\)/set\(codegen_deps intrinsics_gen attributes_inc\)/g;" lib/CodeGen/CMakeLists.txt

        # note: LIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON is only needed with llvm < 3.9.0 to avoid libcxx(abi) build breaking when only a static libc++ exists
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON"
    fi

    if [[ -d tools/clang/tools/include-what-you-use ]]; then
        echo  'add_subdirectory(include-what-you-use)' >> tools/clang/tools/CMakeLists.txt
    fi

    if [[ $(uname -s) == 'Darwin' ]]; then
        : '
        Note: C_INCLUDE_DIRS and DEFAULT_SYSROOT are critical options to understand to ensure C and C++ headers are predictably found.

        The way things work in clang++ on OS X (inside http://clang.llvm.org/doxygen/InitHeaderSearch_8cpp.html) is:

           - The `:` separated `C_INCLUDE_DIRS` are added to the include paths
           - If `C_INCLUDE_DIRS` is present `InitHeaderSearch::AddDefaultCIncludePaths` returns early
             - Without that early return `/usr/include` would be added by default on OS X
           - If `-isysroot` is passed then absolute `C_INCLUDE_DIRS` are appended to the sysroot
             - So if sysroot=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/ and
               C_INCLUDE_DIRS=/usr/include the actual path searched would be:
               /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include
           - Relative `C_INCLUDE_DIRS` seem pointless because they are not appended to the sysroot and so will not be portable
           - clang++ finds C++ headers relative to itself at https://github.com/llvm-mirror/clang/blob/master/lib/Frontend/InitHeaderSearch.cpp#L469-L470
           - So, given on OS X we want to use the XCode/Apple provided libc++ and c++ headers we symlink the relative location to /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++
             - The alternative would be to symlink to the command line tools location (/Library/Developer/CommandLineTools/usr/include/c++/v1/)

        Another viable sysroot would be the command line tools at /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk

        Generally each SDK/Platform version has its own C headers inside SDK_PATH/usr/include while all platforms share the C++ headers which
        are at /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1/

        NOTE: show search paths with: `clang -x c -v -E /dev/null` || `cpp -v` && `clang -Xlinker -v`
        '
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DC_INCLUDE_DIRS=/usr/include"
        # setting the default sysroot to an explicit SDK avoids clang++ adding `/usr/local/include` to the paths by default at https://github.com/llvm-mirror/clang/blob/91d69c3c9c62946245a0fe6526d5ec226dfe7408/lib/Frontend/InitHeaderSearch.cpp#L226
        # because that value will be appended to the sysroot, not exist, and then get thrown out. If the sysroot were / then it would be added
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DDEFAULT_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DCLANG_DEFAULT_CXX_STDLIB=libc++"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12"
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLVM_CREATE_XCODE_TOOLCHAIN=OFF -DLLVM_EXTERNALIZE_DEBUGINFO=ON"
    fi
    if [[ $(uname -s) == 'Linux' ]]; then
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLVM_BINUTILS_INCDIR=${LLVM_BINUTILS_INCDIR}"
        if [[ ${MAJOR_MINOR} == "3.8" ]] && [[ ${BUILD_AND_LINK_LIBCXX} == true ]]; then
            # note: LIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON is only needed with llvm < 3.9.0 to avoid libcxx(abi) build breaking when only a static libc++ exists
            CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON"
        fi
    fi

    # Strip this since we set CMAKE_OSX_DEPLOYMENT_TARGET above. We assume that we'd only upgrade to use this compiler on recent OS X systems and we want the potential performance benefit of targeting a more recent version
    if [[ $(uname -s) == 'Darwin' ]]; then
        export CXXFLAGS="${CXXFLAGS//-mmacosx-version-min=10.8}"
        export LDFLAGS="${LDFLAGS//-mmacosx-version-min=10.8}"
    fi

    # llvm may request c++14 instead so let's not force c++11
    export CXXFLAGS="${CXXFLAGS//-std=c++11}"

    # on linux the default is to link programs compiled by clang++ to libstdc++ and below we make that explicit.
    if [[ $(uname -s) == 'Linux' ]]; then
        export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DCLANG_DEFAULT_CXX_STDLIB=libstdc++"
    fi

    if [[ ${INSTALL_LIBCXX} == false ]]; then
        export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLIBCXX_INSTALL_LIBRARY=OFF -DLIBCXX_INSTALL_HEADERS=OFF"
    fi

    # TODO: test this
    #-DLLVM_ENABLE_LTO=ON \

    # TODO: try rtlib=compiler-rt on linux
    # https://blogs.gentoo.org/gsoc2016-native-clang/2016/05/31/build-gnu-free-executables-with-clang/

    if [[ ${BUILD_AND_LINK_LIBCXX} == true ]]; then
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLIBCXX_ENABLE_ASSERTIONS=OFF -DLIBUNWIND_ENABLE_ASSERTIONS=OFF -DLIBCXXABI_USE_COMPILER_RT=ON -DLIBCXX_USE_COMPILER_RT=ON -DLIBCXXABI_ENABLE_ASSERTIONS=OFF -DLIBCXX_ENABLE_SHARED=OFF -DLIBCXX_ENABLE_STATIC=ON -DLIBCXXABI_ENABLE_SHARED=OFF -DLIBCXXABI_USE_LLVM_UNWINDER=ON -DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON -DSANITIZER_USE_COMPILER_RT=ON -DLIBUNWIND_USE_COMPILER_RT=ON -DLIBUNWIND_ENABLE_STATIC=ON -DLIBUNWIND_ENABLE_SHARED=OFF"
    fi


    if [[ $(uname -s) == 'Linux' ]]; then
        echo "fixing editline"
        # hack to ensure that lldb finds editline to avoid:
        # ../tools/lldb/include/lldb/Host/Editline.h:60:10: fatal error: 'histedit.h' file not found
        # include <histedit.h>
        export CXXFLAGS="${CXXFLAGS} -I${MASON_LIBEDIT}/include/ -I${MASON_NCURSES}/include/ -I${MASON_NCURSES}/include/ncursesw/"
    fi

    if [[ ${BUILD_AND_LINK_LIBCXX} == true ]]; then
        # we link to libc++ even on linux to avoid runtime dependency on libstdc++:
        # https://github.com/mapbox/mason/issues/252
        CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLVM_ENABLE_LIBCXX=ON"
        if [[ $(uname -s) == 'Linux' ]]; then
            # does not work on OS X, which hits:
            # ld.lld: error: unknown argument: -no_deduplicate
            # https://bugs.llvm.org/show_bug.cgi?id=34792
            # https://lists.llvm.org/pipermail/llvm-dev/2018-January/120234.html
            CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLVM_ENABLE_LLD=ON"
            # enabling LLD will add `-fuse-ld=lld` which only works if lld is on path
            # so add it here
            export PATH=${MASON_LLVM}/bin:${PATH}
        fi
    fi


    echo "creating build directory"
    mkdir -p ./build
    cd ./build

    export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -G Ninja -DCMAKE_MAKE_PROGRAM=${MASON_NINJA}/bin/ninja -DLLVM_ENABLE_ASSERTIONS=OFF -DCLANG_VENDOR=mapbox/mason -DCMAKE_CXX_COMPILER_LAUNCHER=${MASON_CCACHE}/bin/ccache"
    export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} -DCMAKE_BUILD_TYPE=Release -DLLVM_INCLUDE_DOCS=OFF"
    export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLVM_TARGETS_TO_BUILD=BPF;X86 -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly -DCLANG_REPOSITORY_STRING=https://github.com/mapbox/mason -DCLANG_VENDOR_UTI=org.mapbox.llvm"
    export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DLLDB_RELOCATABLE_PYTHON=1 -DLLDB_DISABLE_PYTHON=1 -DLLVM_ENABLE_TERMINFO=0"
    # look for curses and libedit on linux
    # note: python would need swig
    export CMAKE_EXTRA_ARGS="${CMAKE_EXTRA_ARGS} -DCMAKE_PREFIX_PATH=${MASON_NCURSES};${MASON_LIBEDIT}"

    echo "running cmake configure for llvm+friends build"
    if [[ $(uname -s) == 'Linux' ]]; then
        ${MASON_CMAKE}/bin/cmake ../ ${CMAKE_EXTRA_ARGS} \
        -DCMAKE_CXX_STANDARD_LIBRARIES="-L${MASON_LIBEDIT}/lib -L${MASON_NCURSES}/lib -L$(pwd)/lib -lc++ -lc++abi -lunwind -pthread -lc -ldl -lrt -rtlib=compiler-rt" \
        -DCMAKE_CXX_COMPILER="$CXX" -DCMAKE_C_COMPILER="$CC" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}"
    else
        ${MASON_CMAKE}/bin/cmake ../ ${CMAKE_EXTRA_ARGS} \
        -DCMAKE_CXX_COMPILER="$CXX" -DCMAKE_C_COMPILER="$CC" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}"
    fi

    if [[ ${BUILD_AND_LINK_LIBCXX} == true ]]; then
        ${MASON_NINJA}/bin/ninja unwind -j${MASON_CONCURRENCY}

        # make libc++ and libc++abi first (to fail quick if they don't build)
        ${MASON_NINJA}/bin/ninja cxx -j${MASON_CONCURRENCY}

        ${MASON_NINJA}/bin/ninja lldb -j${MASON_CONCURRENCY}
    fi

    # then make everything else
    ${MASON_NINJA}/bin/ninja -j${MASON_CONCURRENCY}

    # install it all
    ${MASON_NINJA}/bin/ninja install

    # This could, theoretically, produce a toolchain to be used within Xcode, but I've not tried to get it working yet.
    # So, commented for now since this otherwise takes up disk space.
    #if [[ $(uname -s) == 'Darwin' ]]; then
        # https://reviews.llvm.org/D13605
    #    ${MASON_NINJA}/bin/ninja install-xcode-toolchain -j${MASON_CONCURRENCY}
    #fi

    # install the asan_symbolizer.py tool
    cp -a ../projects/compiler-rt/lib/asan/scripts/asan_symbolize.py ${MASON_PREFIX}/bin/

    # query llvm-config for actual major.minor
    # which might be different if we are building from head
    local CONFIG_MAJOR_MINOR=$(${MASON_PREFIX}/bin/llvm-config --version | cut -d '.' -f1-2)

    # set up symlinks to match what llvm.org binaries provide
    (cd ${MASON_PREFIX}/bin/ && \
        ln -s "clang++" "clang++-${CONFIG_MAJOR_MINOR}" && \
        ln -s "asan_symbolize.py" "asan_symbolize")

    # symlink so that we use the system libc++ headers on osx
    if [[ ${INSTALL_LIBCXX} == false ]] && [[ $(uname -s) == 'Darwin' ]]; then
        mkdir -p ${MASON_PREFIX}/include
        # note: passing -nostdinc++ will result in this local path being ignored
        (cd ${MASON_PREFIX}/include && ln -s /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++ c++)
    fi

    # Address+Undefined
    echo "now building libc++ with address+undefined sanitizers"
    # https://libcxx.llvm.org/docs/BuildingLibcxx.html
    ${MASON_CMAKE}/bin/cmake ../ \
        ${CMAKE_EXTRA_ARGS} -DCMAKE_CXX_COMPILER="$CXX" -DCMAKE_C_COMPILER="$CC" -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
        -DCMAKE_INSTALL_PREFIX="${MASON_PREFIX}/asan" -DLLVM_USE_SANITIZER="Address;Undefined" \
        -DLIBCXX_INSTALL_LIBRARY=ON -DLIBCXX_INSTALL_HEADERS=ON
        ${MASON_NINJA}/bin/ninja cxx cxxabi -j${MASON_CONCURRENCY}
        ${MASON_NINJA}/bin/ninja install-cxx install-libcxxabi -j${MASON_CONCURRENCY}

    # MemoryWithOrigins
    if [[ $(uname -s) == 'Darwin' ]]; then
        echo "skipping libc++ with memory sanitizer, which is not supported on OS X"
    else
        echo "now building libc++ with memory sanitizer"
        ${MASON_CMAKE}/bin/cmake ../ \
            ${CMAKE_EXTRA_ARGS} -DCMAKE_CXX_COMPILER="$CXX" -DCMAKE_C_COMPILER="$CC" -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
            -DCMAKE_INSTALL_PREFIX="${MASON_PREFIX}/msan" -DLLVM_USE_SANITIZER="MemoryWithOrigins" \
            -DLIBCXX_INSTALL_LIBRARY=ON -DLIBCXX_INSTALL_HEADERS=ON
            ${MASON_NINJA}/bin/ninja cxx cxxabi -j${MASON_CONCURRENCY}
            ${MASON_NINJA}/bin/ninja install-cxx install-libcxxabi -j${MASON_CONCURRENCY}
    fi

    # Thread
    echo "now building libc++ with thread sanitizer"
    ${MASON_CMAKE}/bin/cmake ../ \
        ${CMAKE_EXTRA_ARGS} -DCMAKE_CXX_COMPILER="$CXX" -DCMAKE_C_COMPILER="$CC" -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
        -DCMAKE_INSTALL_PREFIX="${MASON_PREFIX}/tsan" -DLLVM_USE_SANITIZER="Thread" \
        -DLIBCXX_INSTALL_LIBRARY=ON -DLIBCXX_INSTALL_HEADERS=ON
        ${MASON_NINJA}/bin/ninja cxx cxxabi -j${MASON_CONCURRENCY}
        ${MASON_NINJA}/bin/ninja install-cxx install-libcxxabi -j${MASON_CONCURRENCY}

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
