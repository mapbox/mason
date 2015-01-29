#!/usr/bin/env bash

MASON_NAME=gdal
MASON_VERSION=1.11.1-big-pants
MASON_LIB_FILE=lib/libgdal.a

. ${MASON_DIR:-~/.mason}/mason.sh

function mason_load_source {
    mason_download \
        http://download.osgeo.org/gdal/CURRENT/gdal-1.11.1.tar.gz \
        6a06e527e6a5abd565a67f84caadf9f891e5f49b

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-1.11.1
}

function mason_prepare_compile {
    cd $(dirname ${MASON_ROOT})
    # set up to fix libtool .la files
    # https://github.com/mapbox/mason/issues/61
    FIND="\/Users\/travis\/build\/mapbox\/mason"
    REPLACE="$(pwd)"
    REPLACE=${REPLACE////\\/}
    ${MASON_DIR:-~/.mason}/mason install libtiff 4.0.4beta
    MASON_TIFF=$(${MASON_DIR:-~/.mason}/mason prefix libtiff 4.0.4beta)
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_TIFF}/lib/libtiff.la
    ${MASON_DIR:-~/.mason}/mason install proj 4.8.0
    MASON_PROJ=$(${MASON_DIR:-~/.mason}/mason prefix proj 4.8.0)
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_PROJ}/lib/libproj.la
    ${MASON_DIR:-~/.mason}/mason install jpeg_turbo 1.4.0
    MASON_JPEG=$(${MASON_DIR:-~/.mason}/mason prefix jpeg_turbo 1.4.0)
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_JPEG}/lib/libjpeg.la
    ${MASON_DIR:-~/.mason}/mason install libpng 1.6.13
    MASON_PNG=$(${MASON_DIR:-~/.mason}/mason prefix libpng 1.6.13)
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_PNG}/lib/libpng.la
    ${MASON_DIR:-~/.mason}/mason install expat 2.1.0
    MASON_EXPAT=$(${MASON_DIR:-~/.mason}/mason prefix expat 2.1.0)
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_EXPAT}/lib/libexpat.la
    ${MASON_DIR:-~/.mason}/mason install libpq 9.4.0
    MASON_LIBPQ=$(${MASON_DIR:-~/.mason}/mason prefix libpq 9.4.0)
    ${MASON_DIR:-~/.mason}/mason install zlib system
    MASON_ZLIB=$(${MASON_DIR:-~/.mason}/mason prefix zlib system)
    ${MASON_DIR:-~/.mason}/mason install iconv system
    MASON_ICONV=$(${MASON_DIR:-~/.mason}/mason prefix iconv system)
    export LIBRARY_PATH=${MASON_LIBPQ}/lib:$LIBRARY_PATH
}

function mason_compile {
    MASON_LIBPQ_PATH=${MASON_LIBPQ}/lib/libpq.a
    CUSTOM_LIBS="-L${MASON_LIBPQ}/lib -L${MASON_TIFF}/lib -ltiff -L${MASON_JPEG}/lib -ljpeg -L${MASON_PROJ}/lib -lproj -L${MASON_PNG}/lib -lpng -L${MASON_EXPAT}/lib -lexpat"
    CUSTOM_CFLAGS="${CFLAGS} -I${MASON_LIBPQ}/include -I${MASON_TIFF}/include -I${MASON_JPEG}/include -I${MASON_PROJ}/include -I${MASON_PNG}/include -I${MASON_EXPAT}/include"
    # note: it might be tempting to build with --without-libtool
    # but I find that will only lead to a static libgdal.a and will
    # not produce a shared library no matter if --enable-shared is passed

    MASON_LIBPQ_PATH2=${MASON_LIBPQ_PATH////\\/}
    perl -i -p -e "s/\-lpq/${MASON_LIBPQ_PATH2}/g;" configure

    LDFLAGS="${MASON_LIBPQ_PATH} ${LDFLAGS}" LIBS="${CUSTOM_LIBS}" CUSTOM_CFLAGS="${CFLAGS}" ./configure \
        --enable-static --disable-shared \
        ${MASON_HOST_ARG} \
        --prefix=${MASON_PREFIX} \
        --with-libz=${MASON_ZLIB} \
        --with-libiconv-prefix=${MASON_ICONV} \
        --disable-rpath \
        --with-libjson-c=internal \
        --with-geotiff=internal \
        --with-expat=${MASON_EXPAT} \
        --with-threads=yes \
        --with-fgdb=no \
        --with-rename-internal-libtiff-symbols=no \
        --with-rename-internal-libgeotiff-symbols=no \
        --with-hide-internal-symbols=yes \
        --with-libtiff=${MASON_TIFF} \
        --with-jpeg=${MASON_JPEG} \
        --with-png=${MASON_PNG} \
        --with-pg=${MASON_LIBPQ}/bin/pg_config \
        --with-static-proj4=${MASON_PROJ} \
        --with-spatialite=no \
        --with-geos=no \
        --with-sqlite3=no \
        --with-curl=no \
        --with-xml2=no \
        --with-pcraster=no \
        --with-cfitsio=no \
        --with-odbc=no \
        --with-libkml=no \
        --with-pcidsk=no \
        --with-jasper=no \
        --with-gif=no \
        --with-grib=no \
        --with-freexl=no \
        --with-avx=no \
        --with-sse=no \
        --with-perl=no \
        --with-ruby=no \
        --with-python=no \
        --with-java=no \
        --with-podofo=no \
        --without-pam \
        --with-webp=no \
        --with-pcre=no \
        --with-liblzma=no \
        --with-netcdf=no \
        --with-poppler=no

    make -j${MASON_CONCURRENCY}
    make install

    # attempt to make paths relative in gdal-config
    python -c "data=open('$MASON_PREFIX/bin/gdal-config','r').read();open('$MASON_PREFIX/bin/gdal-config','w').write(data.replace('include','include/gdal').replace('$MASON_PREFIX','\$( cd \"\$( dirname \$( dirname \"\$0\" ))\" && pwd )'))"
    cat $MASON_PREFIX/bin/gdal-config
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include/gdal"
}

function mason_ldflags {
    echo $(${MASON_PREFIX}/bin/gdal-config --static --libs)
}

function mason_clean {
    make clean
}

mason_run "$@"
