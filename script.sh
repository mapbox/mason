#!/usr/bin/env bash

MASON_NAME=gdal
MASON_VERSION=1.11.1
MASON_LIB_FILE=lib/libgdal.a

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        http://download.osgeo.org/gdal/CURRENT/gdal-${MASON_VERSION}.tar.gz \
        6a06e527e6a5abd565a67f84caadf9f891e5f49b

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_prepare_compile {
    cd $(dirname ${MASON_ROOT})
    ${MASON_DIR:-~/.mason}/mason install libtiff dev
    MASON_TIFF=$(${MASON_DIR:-~/.mason}/mason prefix libtiff dev)
    ${MASON_DIR:-~/.mason}/mason install proj 4.8.0
    MASON_PROJ=$(${MASON_DIR:-~/.mason}/mason prefix proj 4.8.0)
    ${MASON_DIR:-~/.mason}/mason install jpeg v8d
    MASON_JPEG=$(${MASON_DIR:-~/.mason}/mason prefix jpeg v8d)
    ${MASON_DIR:-~/.mason}/mason install libpng 1.6.13
    MASON_PNG=$(${MASON_DIR:-~/.mason}/mason prefix libpng 1.6.13)
}

function mason_compile {
    mason_step "Loading install script 'https://github.com/mapbox/mason/blob/${MASON_SLUG}/patch.diff'..."
    curl --retry 3 -s -f -# -L \
      https://raw.githubusercontent.com/mapbox/mason/${MASON_SLUG}/patch.diff \
      -O || (mason_error "Could not find patch for ${MASON_SLUG}" && exit 1)
    patch -N -p1 < ./patch.diff
    CUSTOM_LIBS="-L${MASON_TIFF}/lib -ltiff -L${MASON_JPEG}/lib -ljpeg -L${MASON_PROJ}/lib -lproj"
    # note: it might be tempting to build with --without-libtool
    # but I find that will only lead to a static libgdal.a and will
    # not produce a shared library no matter if --enable-shared is passed

    LIBS=$CUSTOM_LIBS ./configure \
        --enable-static --disable-shared \
        ${MASON_HOST_ARG} \
        --prefix=${MASON_PREFIX} \
        --with-threads=yes \
        --with-fgdb=no \
        --with-hide-internal-symbols=yes \
        --with-libtiff=${MASON_TIFF} \
        --with-jpeg=${MASON_JPEG} \
        --with-png=${MASON_PNG} \
        --with-static-proj4=${MASON_PROJ} \
        --with-spatialite=no \
        --with-geos=no \
        --with-sqlite3=no \
        --with-curl=no \
        --with-pcraster=no \
        --with-cfitsio=no \
        --with-odbc=no \
        --with-libkml=no \
        --with-pcidsk=no \
        --with-jasper=no \
        --with-gif=no \
        --with-pg=no \
        --with-grib=no \
        --with-freexl=no \
        --with-avx=no \
        --with-sse=no
    make -j${MASON_CONCURRENCY}
    make install

    # attempt to make paths relative in gdal-config
    python -c "data=open('$MASON_PREFIX/bin/gdal-config','r').read();open('$MASON_PREFIX/bin/gdal-config','w').write(data.replace('include','include/gdal').replace('$MASON_PREFIX','\$( cd \"\$( dirname \$( dirname \"\$0\" ))\" && pwd )'))"
    cat $MASON_PREFIX/bin/gdal-config
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include/libxml2"
}

function mason_ldflags {
    echo $(${MASON_PREFIX}/bin/gdal-config --static --libs)
}

function mason_clean {
    make clean
}

mason_run "$@"
