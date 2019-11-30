#!/usr/bin/env bash

MASON_NAME=perf
MASON_VERSION=4.19.86
MASON_LIB_FILE=bin/perf

. ${MASON_DIR}/mason.sh

function mason_load_source {
    # https://www.kernel.org/
    # https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/log/tools/perf
    mason_download \
        https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${MASON_VERSION}.tar.xz \
        ada7aa036782dc6c63cd1ef7de7586e626b2a452

    mason_extract_tar_xz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/linux-${MASON_VERSION}
}

function mason_prepare_compile {
    CCACHE_VERSION=3.7.2
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})
    export CXX="${MASON_CCACHE}/bin/ccache ${CXX:-g++}"
    export CC="${MASON_CCACHE}/bin/ccache ${CC:-gcc}"
    ${MASON_DIR}/mason install zlib 1.2.11
    MASON_ZLIB=$(${MASON_DIR}/mason prefix zlib 1.2.11)
    ${MASON_DIR}/mason install xz 5.2.4
    MASON_XZ=$(${MASON_DIR}/mason prefix xz 5.2.4)
    ${MASON_DIR}/mason install binutils 2.33.1
    MASON_BINUTILS=$(${MASON_DIR}/mason prefix binutils 2.33.1)
    ${MASON_DIR}/mason install slang 2.3.2
    MASON_SLANG=$(${MASON_DIR}/mason prefix slang 2.3.2)
    ${MASON_DIR}/mason install bzip2 1.0.8
    MASON_BZIP2=$(${MASON_DIR}/mason prefix bzip2 1.0.8)
    ${MASON_DIR}/mason install elfutils 0.178
    MASON_ELFUTILS=$(${MASON_DIR}/mason prefix elfutils 0.178)
    EXTRA_CFLAGS="-m64 -I${MASON_SLANG}/include -I${MASON_ZLIB}/include -I${MASON_XZ}/include -I${MASON_BINUTILS}/include -I${MASON_BZIP2}/include -I${MASON_ELFUTILS}/include"
    EXTRA_LDFLAGS="-L${MASON_BZIP2}/lib -L${MASON_ZLIB}/lib -L${MASON_XZ}/lib -L${MASON_SLANG}/lib -L${MASON_ELFUTILS}/lib -L${MASON_BINUTILS}/lib"
}

# https://perf.wiki.kernel.org/index.php/Jolsa_Howto_Install_Sources
# https://askubuntu.com/questions/50145/how-to-install-perf-monitoring-tool/306683
# https://www.spinics.net/lists/linux-perf-users/msg03040.html
# https://software.intel.com/en-us/articles/linux-perf-for-intel-vtune-Amplifier-XE
# see the readme.md in this directory for a log of what perf features are enabled
function mason_compile {
    cd tools/perf
    # we set NO_LIBUNWIND since libdw is used from elfutils which is faster: https://lwn.net/Articles/579508/
    # note: LIBELF is needed for symbols + node --perf_basic_prof_only_functions
    mkdir -p output-dir
    rm -rf output-dir/*
    make \
      O=output-dir \
      FEATURES_DUMP=${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/FEATURE-DUMP \
      LIBDW_LDFLAGS="-L${MASON_ZLIB}/lib -L${MASON_ELFUTILS}/lib -Wl,--start-group -ldw -lelf -lebl -llzma -lz -lbz2 -ldl -L${MASON_BZIP2}/lib -L${MASON_XZ}/lib" \
      LIBDW_CFLAGS="-I${MASON_ELFUTILS}/include/" \
      V=1 VF=1 \
      prefix=${MASON_PREFIX} \
      NO_LIBNUMA=1 \
      NO_LIBAUDIT=1 \
      NO_LIBUNWIND=1 \
      NO_LIBBIONIC=1 \
      NO_BACKTRACE=1 \
      NO_LIBCRYPTO=1 \
      NO_LIBPERL=1 \
      NO_GTK2=1 \
      LDFLAGS="${EXTRA_LDFLAGS} -Wl,--start-group -L${MASON_BINUTILS}/lib -lbfd -lopcodes -lelf -liberty -lz" \
      NO_LIBPYTHON=1 \
      WERROR=0 \
      EXTRA_CFLAGS="${EXTRA_CFLAGS}" \
      install
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

mason_run "$@"
