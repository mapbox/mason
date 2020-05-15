#!/usr/bin/env bash

MASON_NAME=swiftshader
MASON_VERSION=2020-05-15-c9625f1
GITSHA=1cba0a9c3a8a1961514ac63cd3091c1a376fe84a
MASON_LIB_FILE=lib/libGLESv2.${MASON_DYNLIB_SUFFIX}

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/google/swiftshader/archive/${GITSHA}.tar.gz \
        c61d06e55437a78c5c9464a499c980ac1faf74d3

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${GITSHA}

    cd ${MASON_BUILD_PATH}

    patch <<PATCH
    diff --git CMakeLists.txt CMakeLists.txt
    index 05d9c5d..b0d6c65 100644
    --- CMakeLists.txt
    +++ CMakeLists.txt
    @@ -487,8 +487,8 @@ else()
         endif()
     
         # For distribution it is more important to be slim than super optimized
    -    set_cpp_flag("-Os" RELEASE)
    -    set_cpp_flag("-Os" RELWITHDEBINFO)
    +    set_cpp_flag("-O3" RELEASE)
    +    set_cpp_flag("-O3" RELWITHDEBINFO)
     
         set_cpp_flag("-DNDEBUG" RELEASE)
         set_cpp_flag("-DNDEBUG" RELWITHDEBINFO)
PATCH
}

function mason_prepare_compile {
    CCACHE_VERSION=3.7.2
    CMAKE_VERSION=3.15.2
    NINJA_VERSION=1.9.0
    LLVM_VERSION=10.0.0
    ${MASON_DIR}/mason install clang++ ${LLVM_VERSION}
    MASON_LLVM=$(${MASON_DIR}/mason prefix clang++ ${LLVM_VERSION})
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install cmake ${CMAKE_VERSION}
    MASON_CMAKE=$(${MASON_DIR}/mason prefix cmake ${CMAKE_VERSION})
    ${MASON_DIR}/mason install ninja ${NINJA_VERSION}
    MASON_NINJA=$(${MASON_DIR}/mason prefix ninja ${NINJA_VERSION})
}


function mason_compile {
  mkdir -p build
  cd build
  # sw uses -std=gnu++14
  export CXXFLAGS="${CXXFLAGS//-std=c++11}"
  # this may break build with `error: use of undeclared identifier '__sincosf_stret'`
  # so we remove it
  export CXXFLAGS="${CXXFLAGS//-mmacosx-version-min=10.8}"
  ${MASON_CMAKE}/bin/cmake ../ \
        -DCMAKE_BUILD_TYPE=Release \
        -DSWIFTSHADER_BUILD_EGL=YES \
        -DSWIFTSHADER_BUILD_GLESv2=YES \
        -DREACTOR_DEFAULT_OPT_LEVEL=Aggressive \
        -DSWIFTSHADER_BUILD_GLES_CM=NO \
        -DSWIFTSHADER_BUILD_PVR=NO \
        -DSWIFTSHADER_USE_GROUP_SOURCES=NO \
        -DSWIFTSHADER_BUILD_BENCHMARKS=NO \
        -DSWIFTSHADER_ENABLE_ASTC=NO \
        -DSWIFTSHADER_BUILD_TESTS=NO \
        -DSWIFTSHADER_BUILD_VULKAN=NO \
        -DWARNINGS_AS_ERRORS=NO \
        -DREACTOR_BACKEND=LLVM \
        -DREACTOR_EMIT_DEBUG_INFO=OFF \
        -DCMAKE_CXX_FLAGS="${CXXFLAGS} -D__STDC_FORMAT_MACROS --include cinttypes" \
        -DCMAKE_CXX_COMPILER_LAUNCHER=${MASON_CCACHE}/bin/ccache \
        -DCMAKE_CXX_COMPILER="${MASON_LLVM}/bin/clang++" \
        -DCMAKE_C_COMPILER="${MASON_LLVM}/bin/clang"

    VERBOSE=1 make -j${MASON_CONCURRENCY} libEGL libGLESv2
    rm -rf "${MASON_PREFIX}"
    mkdir -p "${MASON_PREFIX}/lib"
    cp -av lib{EGL,GLESv2}.*${MASON_DYNLIB_SUFFIX}* "${MASON_PREFIX}/lib/"
    rsync -av "../include" "${MASON_PREFIX}" --exclude Direct3D --exclude GL --exclude GLES
}

function mason_cflags {
    echo "-isystem ${MASON_PREFIX}/include"
}

function mason_ldflags {
    echo "-L${MASON_PREFIX}/lib -lEGL -lGLESv2"
}

function mason_static_libs {
    :
}

function mason_clean {
    make clean
}

mason_run "$@"
