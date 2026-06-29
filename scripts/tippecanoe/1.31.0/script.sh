#!/usr/bin/env bash

MASON_NAME=tippecanoe
MASON_VERSION=1.31.0
MASON_LIB_FILE=bin/tippecanoe

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapbox/tippecanoe/archive/${MASON_VERSION}.tar.gz \
        3216cbbba0e7023eb3048fd8caf35fc3f0739025

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

SQLITE_VERSION=3.16.2

function mason_prepare_compile {
    LLVM_VERSION="7.0.0"
    ${MASON_DIR}/mason install llvm ${LLVM_VERSION}
    MASON_LLVM=$(${MASON_DIR}/mason prefix llvm ${LLVM_VERSION})
    ${MASON_DIR}/mason install sqlite ${SQLITE_VERSION}
    MASON_SQLITE=$(${MASON_DIR}/mason prefix sqlite ${SQLITE_VERSION})
}

function mason_compile {
    # Use llvm 7.x to statically link libc++
    # https://github.com/mapbox/mason/pull/545#issuecomment-367082479
    export CXX="${MASON_LLVM}/bin/clang++"
    export CC="${MASON_LLVM}/bin/clang"
    LDFLAGS="${LDFLAGS} -stdlib=libc++"
    if [[ $(uname -s) == 'Linux' ]]; then
        CXXFLAGS="-nostdinc++ -I${MASON_LLVM}/include/c++/v1"
        LDFLAGS="${LDFLAGS} -nostdlib++ ${MASON_LLVM}/lib/libc++.a"
        LDFLAGS="${LDFLAGS} ${MASON_LLVM}/lib/libc++abi.a"
        LDFLAGS="${LDFLAGS} ${MASON_LLVM}/lib/libunwind.a -rtlib=compiler-rt"
    fi

    # knock out /usr/local to ensure libsqlite without a doubt that
    # sqlite from from mason is used
    perl -i -p -e "s/-L\/usr\/local\/lib//g;" Makefile
    perl -i -p -e "s/-I\/usr\/local\/include//g;" Makefile


    PREFIX=${MASON_PREFIX} \
    PATH=${MASON_SQLITE}/bin:${PATH} \
    CXXFLAGS="${CXXFLAGS} -I${MASON_SQLITE}/include" \
    LDFLAGS="${LDFLAGS} -L${MASON_SQLITE}/lib -ldl -lpthread" make

    PREFIX=${MASON_PREFIX} \
    PATH=${MASON_SQLITE}/bin:${PATH} \
    CXXFLAGS="${CXXFLAGS} -I${MASON_SQLITE}/include" \
    LDFLAGS="${LDFLAGS} -L${MASON_SQLITE}/lib -ldl -lpthread" make install
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

function mason_clean {
    make clean
}

mason_run "$@"
