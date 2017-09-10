#!/usr/bin/env bash

# Build ICU common package (libicuuc.a) with data file separate and with support for legacy conversion and break iteration turned off in order to minimize size

MASON_NAME=icu
MASON_VERSION=57.1
MASON_LIB_FILE=lib/libicuuc.a
#MASON_PKGCONFIG_FILE=lib/pkgconfig/icu-uc.pc

. ${MASON_DIR}/mason.sh

MASON_BUILD_DEBUG=0 # Enable to build library with debug symbols
MASON_CROSS_BUILD=0

function mason_load_source {
    mason_download \
        http://download.icu-project.org/files/icu4c/57.1/icu4c-57_1-src.tgz \
        c40f6ec922e10a50812157eae28969c528982196

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

    ICU_CORE_CPP_FLAGS="-DU_CHARSET_IS_UTF8=1 -DU_STATIC_IMPLEMENTATION"
    ICU_MODULE_CPP_FLAGS="${ICU_CORE_CPP_FLAGS} -DU_USING_ICU_NAMESPACE=0 -DUNISTR_FROM_CHAR_EXPLICIT=explicit -DUCONFIG_NO_LEGACY_CONVERSION=1 -DUCONFIG_NO_FORMATTING -DUCONFIG_NO_TRANSLITERATION -DUCONFIG_NO_REGULAR_EXPRESSIONS"
    
    export CPPFLAGS="${CPPFLAGS:-} ${ICU_CORE_CPP_FLAGS} ${ICU_MODULE_CPP_FLAGS} -fvisibility=hidden"

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

    if [[ -f ./data/in/icudt${MASON_VERSION/.*}l.dat ]]; then
        # This was created via the data customizer https://ssl.icu-project.org/datacustom/
        # The customizer has been deprecated so hopefully in future icu version we can do this
        # automatically as part of the build
        # Method was:
        # 1. Download customized .dat from the datacustom with just Break Iterators, Collators, and Base data
        # aws s3 cp --acl public-read icudt57l.dat s3://mason-binaries/prebuilt/icudt57l.dat
        # should evaluate to https://mason-binaries.s3.amazonaws.com/prebuilt/icudt57l.dat
        curl -sSfL https://${MASON_BUCKET}.s3.amazonaws.com/prebuilt/icudt${MASON_VERSION/.*}l.dat -o ./data/in/icudt${MASON_VERSION/.*}l.dat
    else
        echo "could not find ./data/in/icudt${MASON_VERSION/.*}l.dat"
        exit 1
    fi
    ./configure ${MASON_HOST_ARG} --prefix=${MASON_PREFIX} \
    ${ICU_BUILDTYPE_FLAGS} \
    $(cross_build_configure) \
    --with-data-packaging=archive \
    --enable-renaming \
    --enable-strict \
    --enable-static \
    --enable-draft \
    --disable-rpath \
    --disable-shared \
    --disable-tests \
    --disable-extras \
    --disable-tracing \
    --disable-layout \
    --disable-icuio \
    --disable-samples \
    --disable-dyload || cat config.log


    # Must do make clean after configure to clear out object files left over from previous build on different architecture
    make clean
    make VERBOSE=1 -j${MASON_CONCURRENCY}
    make install
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
    echo "-I${MASON_PREFIX}/include ${CPPFLAGS:-}"
}

function mason_ldflags {
    echo ""
}

mason_run "$@"
