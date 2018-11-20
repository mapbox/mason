#!/usr/bin/env bash

# Build ICU common package (libicuuc.a) with data file separate and with support for legacy conversion and break iteration turned off in order to minimize size

MASON_NAME=icu
MASON_VERSION=63.1-min-static-data-1
MASON_LIB_FILE=lib/libicuuc.a
#MASON_PKGCONFIG_FILE=lib/pkgconfig/icu-uc.pc

. ${MASON_DIR}/mason.sh

MASON_BUILD_DEBUG=0 # Enable to build library with debug symbols
MASON_CROSS_BUILD=0

function mason_load_source {
    # you can't get the data and the code together in one place except when you clone the repo
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
    if [[ ! -d ${MASON_BUILD_PATH} ]]; then
        git clone https://github.com/unicode-org/icu --depth=1 --branch release-63-1 ${MASON_BUILD_PATH}
    fi
}

function mason_prepare_compile {
    if [[ ${MASON_PLATFORM} == 'ios' || ${MASON_PLATFORM} == 'android' || ${MASON_PLATFORM_VERSION} != `uname -m` ]]; then
        mason_substep "Cross-compiling ICU. Starting with host build of ICU to generate tools."

        pushd ${MASON_ROOT}/..
        env -i HOME="$HOME" PATH="$PATH" USER="$USER" ${MASON_DIR}/mason build ${MASON_NAME} ${MASON_VERSION}
        popd

        # TODO: Copies a bunch of files to a kind of orphaned place, do we need to do something to clean up after the build?
        #  Copying the whole build directory is the easiest way to do a cross build, but we could limit this to a small subset of files (icucross.mk, the tools directory, probably a few others...)
        #  Also instead of using the regular build steps, we could use a dedicated built target that just builds the tools
        mason_substep "Moving host ICU build directory to ${MASON_ROOT}/.build/icu-host"
        rm -rf ${MASON_ROOT}/.build/icu-host
        cp -R ${MASON_BUILD_PATH}/icu4c/source ${MASON_ROOT}/.build/icu-host
    fi
}

function trim_data {
    mason_substep "Trimming ICU data to small number of locals and datasets"

    # for some reason there is also a dat file in there!
    rm -f data/in/icudt63l.dat

    # move all non algorithmic code point mappings so they arent used
    for f in $(find data/mappings -name '*.mk'); do
        mv $f ${f}_
    done

    # make local versions of each data set
    for f in $(find data -path mappings -prune -o -name '*files.mk'); do
        # make a local version and remove the line continuations
        l=$(echo $f | sed -e "s/\(.*\)files.mk/\1local.mk/g")
        sed -e :a -e '/\\$/N; s/\\\n//; ta' $f > $l

        # if its locale, unit or currency we use our supported lang list
        if [ "$(echo $l | grep -cE 'locales|unit|curr')" -eq 1 ]; then
            sed -i'' -e '/^#/!s/SOURCE.*=.*txt/SOURCE = da.txt de.txt en.txt eo.txt es.txt fi.txt fr.txt he.txt id.txt it.txt ko.txt my.txt nl.txt pl.txt pt.txt pt_PT.txt ro.txt ru.txt sv.txt tr.txt uk.txt vi.txt zh.txt zh_Hans.txt/g' $l
        # if its misc we need a couple of things
        elif [ $(echo $l | grep -cF "misc") -eq 1 ]; then
            sed -i'' -e '/^#/!s/SOURCE.*=.*txt/SOURCE = plurals.txt numberingSystems.txt icuver.txt icustd.txt pluralRanges.txt/g' $l
        # otherwise the scuttle the whole thing
        else
            sed -i'' -e '/^#/!s/SOURCE.*=.*txt/SOURCE = /g' $l
        fi
    done
}

function mason_compile {
    if [[ ${MASON_PLATFORM} == 'ios' || ${MASON_PLATFORM} == 'android' || ${MASON_PLATFORM_VERSION} != `uname -m` ]]; then
        MASON_CROSS_BUILD=1
    fi
    mason_compile_base
}

function mason_compile_base {
    pushd  ${MASON_BUILD_PATH}/icu4c/source
    
    # trim out a bunch of the data so that the data static library is as small as possible
    trim_data

    # Using uint_least16_t instead of char16_t because Android Clang doesn't recognize char16_t
    # I'm being shady and telling users of the library to use char16_t, so there's an implicit raw cast
    ICU_CORE_CPP_FLAGS="-DU_CHARSET_IS_UTF8=1"
    ICU_MODULE_CPP_FLAGS="${ICU_CORE_CPP_FLAGS} -DUCONFIG_NO_LEGACY_CONVERSION=1 -DUCONFIG_NO_BREAK_ITERATION=1"
    
    CFLAGS="${CFLAGS:-} ${ICU_CORE_CPP_FLAGS} ${ICU_MODULE_CPP_FLAGS} -fvisibility=hidden $(icu_debug_cpp) -Os"
    CXXFLAGS="${CXXFLAGS:-} ${ICU_CORE_CPP_FLAGS} ${ICU_MODULE_CPP_FLAGS} -fvisibility=hidden $(icu_debug_cpp) -Os"

    echo "Configuring with ${MASON_HOST_ARG}"

    ./configure ${MASON_HOST_ARG} --prefix=${MASON_PREFIX} \
    $(icu_debug_configure) \
    $(cross_build_configure) \
    --with-data-packaging=static \
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
    make -j${MASON_CONCURRENCY}
    make install
    popd
}

function icu_debug_cpp {
    if [ ${MASON_BUILD_DEBUG} == 1 ]; then
        echo "-g"
    fi
}

function icu_debug_configure {
    if [ ${MASON_BUILD_DEBUG} == 1 ]; then
        echo "--enable-debug --disable-release"
    else
        echo "--enable-release --disable-debug"
    fi
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
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    echo ""
}

mason_run "$@"
