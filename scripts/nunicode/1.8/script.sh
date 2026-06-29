#!/usr/bin/env bash

MASON_NAME=nunicode
MASON_VERSION=1.8
MASON_LIB_FILE=lib/libnu.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/nu.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download https://bitbucket.org/alekseyt/nunicode/get/1.8.tar.bz2 \
        d4788a570b8eafec01eaa7a3425a3529d9f70842

    mason_extract_tar_bz2

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/alekseyt-nunicode-246bb27014ab
}

function mason_compile {
    mkdir -p build-dir
    cd build-dir

    # patch CMakeLists file
    cat ../CMakeLists.txt | sed -e '/find_package.Sqlite3/ s/^/#/' > ../CMakeLists.txt.new && cp ../CMakeLists.txt.new ../CMakeLists.txt

    if [ ${MASON_PLATFORM} = 'android' ]; then
        ${MASON_DIR}/utils/android.sh > toolchain.cmake

        cmake \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
            -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
            ..
    else
        cmake \
            -DCMAKE_BUILD_TYPE=RELEASE \
            -DCMAKE_INSTALL_PREFIX=${MASON_PREFIX} \
            ..
    fi

    make install -j${MASON_CONCURRENCY}
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    : # We're only using the full path to the archive, which is output in static_libs
}

function mason_clean {
    make clean
}

mason_run "$@"
