#!/usr/bin/env bash

# Build ICU common package (libicuuc.a) with data file separate and with support for legacy conversion and break iteration turned off in order to minimize size

MASON_NAME=icu
MASON_VERSION=58.1
MASON_LIB_FILE=lib/libicuuc.a
#MASON_PKGCONFIG_FILE=lib/pkgconfig/icu-uc.pc

. ${MASON_DIR}/mason.sh

MASON_BUILD_DEBUG=0 # Enable to build library with debug symbols
MASON_CROSS_BUILD=0

function mason_load_source {
    mason_download \
        http://download.icu-project.org/files/icu4c/58.1/icu4c-58_1-src.tgz \
        ad6995ba349ed79dde0f25d125a9b0bb56979420

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}
}

function mason_prepare_compile {
    if [[ ${MASON_PLATFORM} == 'ios' || ${MASON_PLATFORM} == 'android' || ${MASON_PLATFORM_VERSION} != `uname -m` ]]; then
        mason_substep "Cross-compiling ICU. Starting with host build of ICU to generate tools."

        pushd ${MASON_ROOT}/..
        env -i HOME="$HOME" PATH="$PATH" USER="$USER" ${MASON_DIR}/mason build icu ${MASON_VERSION}
        popd

        # TODO: Copies a bunch of files to a kind of orphaned place, do we need to do something to clean up after the build?
        #  Copying the whole build directory is the easiest way to do a cross build, but we could limit this to a small subset of files (icucross.mk, the tools directory, probably a few others...)
        #  Also instead of using the regular build steps, we could use a dedicated built target that just builds the tools
        mason_substep "Moving host ICU build directory to ${MASON_ROOT}/.build/icu-host"
        rm -rf ${MASON_ROOT}/.build/icu-host
        cp -R ${MASON_BUILD_PATH}/source ${MASON_ROOT}/.build/icu-host
    fi
}

function mason_compile {
    if [[ ${MASON_PLATFORM} == 'ios' || ${MASON_PLATFORM} == 'android' || ${MASON_PLATFORM_VERSION} != `uname -m` ]]; then
        MASON_CROSS_BUILD=1
    fi
    mason_compile_base
}

function mason_compile_base {
    pushd  ${MASON_BUILD_PATH}/source

    # Using uint_least16_t instead of char16_t because Android Clang doesn't recognize char16_t
    # I'm being shady and telling users of the library to use char16_t, so there's an implicit raw cast
    ICU_CORE_CPP_FLAGS="-DU_CHARSET_IS_UTF8=1 -DUCHAR_TYPE=uint_least16_t -DU_STATIC_IMPLEMENTATION"
    ICU_MODULE_CPP_FLAGS="${ICU_CORE_CPP_FLAGS} -DU_USING_ICU_NAMESPACE=0 -DUNISTR_FROM_CHAR_EXPLICIT=explicit -DUCONFIG_NO_LEGACY_CONVERSION=1 -DUCONFIG_NO_TRANSLITERATION -DUCONFIG_NO_REGULAR_EXPRESSIONS"
    
    # #if !UCONFIG_NO_FORMATTING && !UCONFIG_NO_CONVERSION break io parts needed for iculslocs.cc
    export CPPFLAGS="${CPPFLAGS} ${ICU_CORE_CPP_FLAGS} ${ICU_MODULE_CPP_FLAGS} -fvisibility=hidden"

    echo "Configuring with ${MASON_HOST_ARG}"

    if [[ ${MASON_BUILD_DEBUG} == 1 ]]; then
        export CFLAGS="${CFLAGS} -O0 -DDEBUG -g"
        export CXXFLAGS="${CXXFLAGS} -O0 -DDEBUG -g"
        ICU_BUILDTYPE_FLAGS="--enable-debug --disable-release"
    else
        # note CFLAGS overrides defaults (-O2) so we need to add optimization flags back
        export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
        export CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG"
        ICU_BUILDTYPE_FLAGS="--enable-release --disable-debug"
    fi

    export CXX="ccache ${CXX}"
    export CC="ccache ${CC}"
    ./configure ${MASON_HOST_ARG} --prefix=${MASON_PREFIX} \
    ${ICU_BUILDTYPE_FLAGS} \
    $(cross_build_configure) \
    --with-data-packaging=archive \
    --enable-renaming \
    --enable-strict \
    --enable-static \
    --enable-draft \
    --enable-icuio \
    --disable-rpath \
    --disable-shared \
    --disable-tests \
    --disable-extras \
    --disable-tracing \
    --disable-layout \
    --disable-samples \
    --disable-dyload || cat config.log


    # Must do make clean after configure to clear out object files left over from previous build on different architecture
    make clean
    make VERBOSE=1 -j${MASON_CONCURRENCY}
    make install

    # hack to rewrite the .dat to reduce its size
    # via the amazing tools at https://github.com/nodejs/node/tree/master/tools/icu
    TMP_BIN=/tmp/icu-bin
    mkdir -p ${TMP_BIN}
    rm -rf ${TMP_BIN}/*
    echo ${CXX:-clang++} ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/iculslocs.cc -O3 -o ${TMP_BIN}/iculslocs -I./common -I./io -I./i18n ${MASON_PREFIX}/lib/libicuuc.a ${MASON_PREFIX}/lib/libicudata.a ${MASON_PREFIX}/lib/libicuio.a ${MASON_PREFIX}/lib/libicui18n.a
    ${CXX:-clang++} ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/iculslocs.cc -O3 -o ${TMP_BIN}/iculslocs -I./common -I./io -I./i18n ${MASON_PREFIX}/lib/libicuuc.a ${MASON_PREFIX}/lib/libicudata.a ${MASON_PREFIX}/lib/libicuio.a ${MASON_PREFIX}/lib/libicui18n.a
    cp ${MASON_PREFIX}/sbin/* ${TMP_BIN}/
    cp ${MASON_PREFIX}/bin/* ${TMP_BIN}/
    rm -rf tmp2;
    cp ${MASON_PREFIX}/share/icu/${MASON_VERSION}/icudt${MASON_VERSION/.*}l.dat ${MASON_PREFIX}/share/icu/${MASON_VERSION}/icudt${MASON_VERSION/.*}l.dat_
    python ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/icutrim.py -D ${MASON_PREFIX}/share/icu/${MASON_VERSION}/icudt${MASON_VERSION/.*}l.dat -F ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/icu_small.json -P ${TMP_BIN} -T tmp2 -O icudt${MASON_VERSION/.*}l.dat
    mv tmp2/icudt${MASON_VERSION/.*}l.dat ${MASON_PREFIX}/share/icu/${MASON_VERSION}/icudt${MASON_VERSION/.*}l.dat

    popd
}

function cross_build_configure {
    # Building tools is disabled in cross-build mode. Using the host-built version of the tools is the whole point of the --with-cross-build flag
    if [ ${MASON_CROSS_BUILD} == 1 ]; then
        echo "--with-cross-build=${MASON_ROOT}/.build/icu-host --disable-tools"
    else
        echo "--enable-tools"
    fi
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include ${CPPFLAGS}"
}

function mason_ldflags {
    echo ""
}

mason_run "$@"
