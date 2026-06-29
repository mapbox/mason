#!/usr/bin/env bash

MASON_NAME=swiftshader
MASON_VERSION=2018-08-29-60f8662
GITSHA=60f8662dc0ef2cfa28677913335c3399b311a265
MASON_LIB_FILE=lib/libGLESv2.${MASON_DYNLIB_SUFFIX}

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/google/swiftshader/archive/${GITSHA}.tar.gz \
        8b32ba725a1ba72f1145dc64f431061c877eec35

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${GITSHA}

    cd ${MASON_BUILD_PATH}

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
}

function mason_compile {
    cmake -H. -Bbuild \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_GLES_CM=NO \
        -DBUILD_TESTS=NO \
        -DBUILD_SAMPLES=NO \
        -DREACTOR_BACKEND=LLVM
    make -C build -j${MASON_CONCURRENCY} libEGL libGLESv2

    rm -rf "${MASON_PREFIX}"
    mkdir -p "${MASON_PREFIX}/lib"
    cp -av build/lib{EGL,GLESv2}.*${MASON_DYNLIB_SUFFIX}* "${MASON_PREFIX}/lib/"
    rsync -av "include" "${MASON_PREFIX}" --exclude Direct3D --exclude GL --exclude GLES
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
