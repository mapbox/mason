#!/usr/bin/env bash

MASON_NAME=re2
MASON_VERSION=2017-08-01
MASON_LIB_FILE=lib/libre2.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/google/${MASON_NAME}/archive/${MASON_VERSION}.tar.gz \
        adf5ed0ddae54ec984790b714b3efdbcdb41fe6c

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    export CFLAGS="${CFLAGS:-} -O3 -DNDEBUG"
    export CXXFLAGS="${CXXFLAGS:-} -O3 -DNDEBUG"
    if [[ $(uname -s) == 'Darwin' ]]; then
        export LDFLAGS="${LDFLAGS:-} -stdlib=libc++"
    fi

    make obj/libre2.a -j${MASON_CONCURRENCY}
    # re2's install script is janky (hardcoded - as far as I can tell - to /usr/local) and hardcoded
    # to also install the shared library (we only what the static one) and simple enough to re-invent
    # so install of calling `make install` we instead just manually install the library and headers
    mkdir -p ${MASON_PREFIX}/lib/
    cp obj/libre2.a ${MASON_PREFIX}/lib/
    mkdir -p ${MASON_PREFIX}/include/re2/
    cp -r re2/*h ${MASON_PREFIX}/include/re2/
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}

function mason_static_libs {
    echo ${MASON_PREFIX}/${MASON_LIB_FILE}
}

function mason_clean {
    make clean
}

mason_run "$@"
