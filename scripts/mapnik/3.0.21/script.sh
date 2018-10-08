#!/usr/bin/env bash

MASON_NAME=mapnik
MASON_VERSION=3.0.21
MASON_LIB_FILE=lib/libmapnik.${MASON_DYNLIB_SUFFIX}

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/mapnik/mapnik/releases/download/v${MASON_VERSION}/mapnik-v${MASON_VERSION}.tar.bz2 \
        712b7a96bd425d22a40c17537ad0c4e92d695a9f
    mason_extract_tar_bz2

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/mapnik-v${MASON_VERSION}
}

function install() {
    ${MASON_DIR}/mason install $1 $2
    MASON_PLATFORM_ID=$(${MASON_DIR}/mason env MASON_PLATFORM_ID)
    if [[ ! -d ${MASON_ROOT}/${MASON_PLATFORM_ID}/${1}/${2} ]]; then
        if [[ ${3:-false} != false ]]; then
            LA_FILE=$(${MASON_DIR}/mason prefix $1 $2)/lib/$3.la
            if [[ -f ${LA_FILE} ]]; then
                perl -i -p -e 's:\Q$ENV{HOME}/build/mapbox/mason\E:$ENV{PWD}:g' ${LA_FILE}
            else
                echo "$LA_FILE not found"
            fi
        fi
    fi
    ${MASON_DIR}/mason link $1 $2
}

ICU_VERSION="57.1"

function mason_prepare_compile {
    install jpeg_turbo 1.5.1 libjpeg
    install libpng 1.6.28 libpng
    install libtiff 4.0.7 libtiff
    install libpq 9.6.2
    install sqlite 3.17.0 libsqlite3
    install expat 2.2.0 libexpat
    install icu ${ICU_VERSION}
    install proj 4.9.3 libproj
    install pixman 0.34.0 libpixman-1
    install cairo 1.14.8 libcairo
    install webp 0.6.0 libwebp
    install libgdal 2.1.3 libgdal
    install boost 1.65.1
    install boost_libsystem 1.65.1
    install boost_libfilesystem 1.65.1
    install boost_libprogram_options 1.65.1
    install boost_libregex_icu57 1.65.1
    install freetype 2.7.1 libfreetype
    install harfbuzz 1.4.2-ft libharfbuzz
}

function mason_compile {
    export PATH="${MASON_ROOT}/.link/bin:${PATH}"
    MASON_LINKED_REL="${MASON_ROOT}/.link"
    MASON_LINKED_ABS="${MASON_ROOT}/.link"

    if [[ $(uname -s) == 'Linux' ]]; then
        echo "CUSTOM_LDFLAGS = '${LDFLAGS} -Wl,-z,origin -Wl,-rpath=\\\$\$ORIGIN/../lib/ -Wl,-rpath=\\\$\$ORIGIN/../../'" > config.py
        echo "CUSTOM_CXXFLAGS = '${CXXFLAGS} -D_GLIBCXX_USE_CXX11_ABI=0'" >> config.py
    else
        echo "CUSTOM_LDFLAGS = '${LDFLAGS}'" > config.py
        echo "CUSTOM_CXXFLAGS = '${CXXFLAGS}'" >> config.py
    fi

    # setup `mapnik-settings.env` (like bootstrap.sh does)
    # note: we don't use bootstrap.sh to be able to control
    # mason versions here and use the mason we are running
    echo "export PROJ_LIB=${MASON_LINKED_ABS}/share/proj" > mapnik-settings.env
    echo "export ICU_DATA=${MASON_LINKED_ABS}/share/icu/${ICU_VERSION}" >> mapnik-settings.env
    echo "export GDAL_DATA=${MASON_LINKED_ABS}/share/gdal" >> mapnik-settings.env

    RESULT=0

    ./configure \
        CXX="${CXX}" \
        CC="${CC}" \
        PREFIX="${MASON_PREFIX}" \
        RUNTIME_LINK="static" \
        INPUT_PLUGINS="all" \
        ENABLE_GLIBC_WORKAROUND=True \
        ENABLE_SONAME=False \
        PKG_CONFIG_PATH="${MASON_LINKED_REL}/lib/pkgconfig" \
        PATH_REMOVE="/usr:/usr/local" \
        BOOST_INCLUDES="${MASON_LINKED_REL}/include" \
        BOOST_LIBS="${MASON_LINKED_REL}/lib" \
        ICU_INCLUDES="${MASON_LINKED_REL}/include" \
        ICU_LIBS="${MASON_LINKED_REL}/lib" \
        HB_INCLUDES="${MASON_LINKED_REL}/include" \
        HB_LIBS="${MASON_LINKED_REL}/lib" \
        PNG_INCLUDES="${MASON_LINKED_REL}/include/libpng16" \
        PNG_LIBS="${MASON_LINKED_REL}/lib" \
        JPEG_INCLUDES="${MASON_LINKED_REL}/include" \
        JPEG_LIBS="${MASON_LINKED_REL}/lib" \
        TIFF_INCLUDES="${MASON_LINKED_REL}/include" \
        TIFF_LIBS="${MASON_LINKED_REL}/lib" \
        WEBP_INCLUDES="${MASON_LINKED_REL}/include" \
        WEBP_LIBS="${MASON_LINKED_REL}/lib" \
        PROJ_INCLUDES="${MASON_LINKED_REL}/include" \
        PROJ_LIBS="${MASON_LINKED_REL}/lib" \
        PG_INCLUDES="${MASON_LINKED_REL}/include" \
        PG_LIBS="${MASON_LINKED_REL}/lib" \
        FREETYPE_INCLUDES="${MASON_LINKED_REL}/include/freetype2" \
        FREETYPE_LIBS="${MASON_LINKED_REL}/lib" \
        SVG_RENDERER=True \
        CAIRO_INCLUDES="${MASON_LINKED_REL}/include" \
        CAIRO_LIBS="${MASON_LINKED_REL}/lib" \
        SQLITE_INCLUDES="${MASON_LINKED_REL}/include" \
        SQLITE_LIBS="${MASON_LINKED_REL}/lib" \
        GDAL_CONFIG="${MASON_LINKED_REL}/bin/gdal-config" \
        PG_CONFIG="${MASON_LINKED_REL}/bin/pg_config" \
        BENCHMARK=False \
        CPP_TESTS=False \
        PGSQL2SQLITE=True \
        SAMPLE_INPUT_PLUGINS=False \
        DEMO=False \
        XMLPARSER="ptree" \
        NO_ATEXIT=True \
        SVG2PNG=True || RESULT=$?

    # if configure failed, dump out config details before exiting
    if [[ ${RESULT} != 0 ]]; then
        cat ${MASON_BUILD_PATH}"/config.log"
        cat config.py
        false # then fail
    fi

    # limit concurrency on travis to avoid heavy jobs being killed
    if [[ ${TRAVIS_OS_NAME:-} ]]; then
        JOBS=4 make
    else
        JOBS=${MASON_CONCURRENCY} make
    fi

    make install
    if [[ $(uname -s) == 'Darwin' ]]; then
        install_name_tool -id @loader_path/lib/libmapnik.dylib ${MASON_PREFIX}"/lib/libmapnik.dylib";
        PLUGINDIRS=${MASON_PREFIX}"/lib/mapnik/input/*.input";
        for f in $PLUGINDIRS; do
            echo $f;
            echo `basename $f`;
            install_name_tool -id plugins/input/`basename $f` $f;
            install_name_tool -change ${MASON_PREFIX}"/lib/libmapnik.dylib" @loader_path/../../../lib/libmapnik.dylib $f;
        done;
        # command line tools
        install_name_tool -change ${MASON_PREFIX}"/lib/libmapnik.dylib" @loader_path/../lib/libmapnik.dylib ${MASON_PREFIX}"/bin/mapnik-index"
        install_name_tool -change ${MASON_PREFIX}"/lib/libmapnik.dylib" @loader_path/../lib/libmapnik.dylib ${MASON_PREFIX}"/bin/mapnik-render"
        install_name_tool -change ${MASON_PREFIX}"/lib/libmapnik.dylib" @loader_path/../lib/libmapnik.dylib ${MASON_PREFIX}"/bin/shapeindex"
    fi
    # fix mapnik-config entries for deps
    HERE=$(pwd)
    python -c "import re;data=open('$MASON_PREFIX/bin/mapnik-config','r').read();data=re.sub(r'-(isysroot)\s\/([0-9a-zA-Z_\/\-\.]+)', '', data);open('$MASON_PREFIX/bin/mapnik-config','w').write(data.replace('$HERE','.').replace('${MASON_ROOT}','./mason_packages'))"
    cat $MASON_PREFIX/bin/mapnik-config
}

function mason_cflags {
    ${MASON_PREFIX}/bin/mapnik-config --cflags
}

function mason_ldflags {
    ${MASON_PREFIX}/bin/mapnik-config --ldflags
}

function mason_static_libs {
    ${MASON_PREFIX}/bin/mapnik-config --dep-libs
}

function mason_clean {
    make clean
}

mason_run "$@"
