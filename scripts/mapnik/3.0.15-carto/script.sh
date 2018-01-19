#!/usr/bin/env bash

MASON_NAME=mapnik
MASON_VERSION=${MASON_CARTO_VERSION:-noversion}
MASON_LIB_FILE=lib/libmapnik.${MASON_DYNLIB_SUFFIX}

. ${MASON_DIR}/mason.sh

if [ "$MASON_VERSION" == "noversion" ]; then
   mason_error "MASON_CARTO_VERSION env var not defined."
   exit 1
fi

function mason_load_source {
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/mapnik-v${MASON_VERSION}

    if [[ ! -d ${MASON_BUILD_PATH} ]]; then
        mason_step "Cloning source..."
        git clone -b v${MASON_VERSION} --depth 1 --single-branch http://github.com/CartoDB/mapnik ${MASON_BUILD_PATH}
        mason_step "Cloning submodules..."
        (cd ${MASON_BUILD_PATH}; git submodule update --init --depth 1)
    fi
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
    install boost 1.63.0
    install boost_libsystem 1.63.0
    install boost_libfilesystem 1.63.0
    install boost_libprogram_options 1.63.0
    install boost_libregex_icu57 1.63.0
    install freetype 2.7.1 libfreetype
    install harfbuzz 1.3.0 libharfbuzz
}

function mason_compile {
    #patch -N -p1 < ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff
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

    ./configure \
        CXX="${CXX}" \
        CC="${CC}" \
        PREFIX="${MASON_PREFIX}" \
        RUNTIME_LINK="static" \
        INPUT_PLUGINS="all" \
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
        SVG2PNG=True || cat ${MASON_BUILD_PATH}"/config.log"

    cat config.py

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
    python -c "data=open('$MASON_PREFIX/bin/mapnik-config','r').read();open('$MASON_PREFIX/bin/mapnik-config','w').write(data.replace('$HERE','.').replace('${MASON_ROOT}','./mason_packages'))"
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
