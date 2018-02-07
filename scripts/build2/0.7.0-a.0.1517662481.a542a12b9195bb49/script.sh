#!/usr/bin/env bash

MASON_NAME=build2
MASON_VERSION=0.7.0-a.0.1517662481.a542a12b9195bb49
MASON_LIB_FILE=bin/bpkg

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://stage.build2.org/0/0.7.0-a.0/build2-toolchain-${MASON_VERSION}.tar.gz \
        0ce9c68168cac682942b6d0ee12647713dbb3c5c

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/build2-toolchain-${MASON_VERSION}
}

function mason_compile {
    # NOTE: build2 requires a c++17 capable compiler and it uses CXX11_ABI features in libstdc++ (so it must be build with _GLIBCXX_USE_CXX11_ABI=1)
    # Since we want the binaries to be portable to pre cxx11 abi machines, we statically link against libc++ instead of linking against libstdc++
    # note with clang 4.x will hit "header 'shared_mutex' not found and cannot be generated" because c++17 support is lacking
    LDFLAGS=""
    if [[ $(uname -s) == 'Linux' ]]; then
        LDFLAGS="-Wl,--start-group -lc++ -lc++abi -pthread -lrt"
    fi
    perl -i -p -e "s/pthread/pthread -stdlib=libc++ ${LDFLAGS} /g;" ./build2/bootstrap.sh
    perl -i -p -e "s/=static/=static config.bin.exe.lib=static config.cxx.coptions=-stdlib=libc++ config.cxx.loptions='${LDFLAGS}' /g;" ./build.sh
    perl -i -p -e "s/suffix=-stage /suffix=-stage config.bin.lib=static config.bin.exe.lib=static config.cxx.coptions=-stdlib=libc++ config.cxx.loptions='${LDFLAGS}' /g;" ./build.sh
    perl -i -p -e "s/coptions=-O3 /coptions=-O3 config.bin.lib=static config.bin.exe.lib=static config.cxx.coptions=-stdlib=libc++ config.cxx.loptions='${LDFLAGS}' /g;" ./build.sh
    ./build.sh --install-dir ${MASON_PREFIX} --sudo "" --trust yes ${CXX:-clang++}
}

function mason_cflags {
    :
}

function mason_static_libs {
    :
}

function mason_ldflags {
    :
}

mason_run "$@"
