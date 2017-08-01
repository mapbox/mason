MASON_NAME=catch
MASON_VERSION=1.9.6
MASON_HEADER_ONLY=true

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/philsquared/Catch/archive/v${MASON_VERSION}.tar.gz \
        c8bf11d32c73c864ebf6b57e2a324a86ea39df82

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/Catch-${MASON_VERSION}
}

# nothing to build, just copying single include header file
function mason_compile {
    mkdir -p ${MASON_PREFIX}/include/
    cp -r single_include/catch.hpp ${MASON_PREFIX}/include
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    :
}

mason_run "$@"
