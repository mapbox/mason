#!/usr/bin/env bash

MASON_NAME=swiftshader
MASON_VERSION=2020-01-14-146e16f
GITSHA=146e16f68fdc4678600031ab3256cccf7b32d5e2
MASON_LIB_FILE=lib/libGLESv2.${MASON_DYNLIB_SUFFIX}

. ${MASON_DIR}/mason.sh

function mason_prepare_compile {
    CCACHE_VERSION=3.7.2
    CMAKE_VERSION=3.8.2
    NINJA_VERSION=1.9.0
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    ${MASON_DIR}/mason install cmake ${CMAKE_VERSION}
    MASON_CMAKE=$(${MASON_DIR}/mason prefix cmake ${CMAKE_VERSION})
    ${MASON_DIR}/mason install ninja ${NINJA_VERSION}
    MASON_NINJA=$(${MASON_DIR}/mason prefix ninja ${NINJA_VERSION})

}


function mason_load_source {
    mason_download \
        https://github.com/google/swiftshader/archive/${GITSHA}.tar.gz \
        f0365f9ae6fb1f13d1cca53d2a6c1f7a2682d839

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${GITSHA}
}

function mason_compile {

    patch <<PATCH
--- CMakeLists.txt
+++ CMakeLists.txt
@@ -196,2 +196,2 @@
-    set_cpp_flag("-Os" RELEASE)
-    set_cpp_flag("-Os" RELWITHDEBINFO)
+    set_cpp_flag("-O3" RELEASE)
+    set_cpp_flag("-O3" RELWITHDEBINFO)
@@ -929,3 +929,5 @@
         COMPILE_DEFINITIONS "EGL_EGLEXT_PROTOTYPES; EGLAPI=; NO_SANITIZE_FUNCTION=;"
         PREFIX ""
+        VERSION 1.0.0
+        SOVERSION 1
     )
@@ -961,3 +963,5 @@
         COMPILE_DEFINITIONS "GL_GLEXT_PROTOTYPES; GL_API=; GL_APICALL=; GLAPI=; NO_SANITIZE_FUNCTION=;"
         PREFIX ""
+        VERSION 2.0.0
+        SOVERSION 2
     )
PATCH

    ${MASON_CMAKE}/bin/cmake -H. -Bbuild \
        -DCMAKE_BUILD_TYPE=Release \
        -G Ninja \
        -DCMAKE_MAKE_PROGRAM=${MASON_NINJA}/bin/ninja \
        -DSWIFTSHADER_BUILD_EGL=YES \
        -DREACTOR_BACKEND=LLVM \
        -DSWIFTSHADER_BUILD_GLES_CM=NO \
        -DSWIFTSHADER_BUILD_TESTS=NO \
        -DSWIFTSHADER_BUILD_SAMPLES=NO \
        -DSWIFTSHADER_BUILD_VULKAN=NO \
        -DSWIFTSHADER_WARNINGS_AS_ERRORS=NO \
        -DSWIFTSHADER_BUILD_PVR=NO
    ${MASON_NINJA}/bin/ninja -C build -j${MASON_CONCURRENCY}
    ${MASON_NINJA}/bin/ninja install
    # rm -rf "${MASON_PREFIX}"
    # mkdir -p "${MASON_PREFIX}/lib"
    # cp -av build/lib{EGL,GLESv2}.*${MASON_DYNLIB_SUFFIX}* "${MASON_PREFIX}/lib/"
    # rsync -av "include" "${MASON_PREFIX}" --exclude Direct3D --exclude GL --exclude GLES
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
