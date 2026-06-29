#!/usr/bin/env bash

MASON_NAME=swiftshader
MASON_VERSION=2018-10-08-3b5e426
GITSHA=3b5e426b815f75e71d1bcf74b66b9fb0f6830f44
MASON_LIB_FILE=lib/libGLESv2.${MASON_DYNLIB_SUFFIX}

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/google/swiftshader/archive/${GITSHA}.tar.gz \
        671aa0f4938f32032c043d2d870a23dcaf5fc63a

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
