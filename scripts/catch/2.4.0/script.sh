MASON_NAME=catch
MASON_VERSION=2.4.0
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/catchorg/Catch2/archive/v${MASON_VERSION}.tar.gz \
        de446b4b31efdcd6784cc97464050f2b1d91d43a

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/Catch2-${MASON_VERSION}
}

# nothing to build, just copying single include header file
function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r single_include/catch2/catch.hpp ${MASON_PREFIX}/include
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}

mason_run "$@"
