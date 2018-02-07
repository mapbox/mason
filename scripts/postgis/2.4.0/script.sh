#!/usr/bin/env bash

MASON_NAME=postgis
MASON_VERSION=2.4.0
MASON_LIB_FILE=bin/shp2pgsql

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        http://download.osgeo.org/postgis/source/postgis-${MASON_VERSION}.tar.gz \
        70363fffe2eedfcd6fd24908090f66abc2acb9a5

    mason_extract_tar_gz
    export MASON_BUILD_PATH=${MASON_ROOT}/.build/postgis-${MASON_VERSION}
}

function mason_prepare_compile {
    # This line is critical: it ensures that we install deps in
    # the parent folder rather than within the ./build directory
    # such that our modifications to the .la files work
    cd $(dirname ${MASON_ROOT})
    # set up to fix libtool .la files
    # https://github.com/mapbox/mason/issues/61
    if [[ $(uname -s) == 'Darwin' ]]; then
        FIND="\/Users\/travis\/build\/mapbox\/mason"
    else
        FIND="\/home\/travis\/build\/mapbox\/mason"
    fi
    REPLACE="$(pwd)"
    REPLACE=${REPLACE////\\/}
    LIBTIFF_VERSION="4.0.8"
    PROJ_VERSION="4.9.3"
    JPEG_VERSION="1.5.2"
    PNG_VERSION="1.6.32"
    EXPAT_VERSION="2.2.4"
    POSTGRES_VERSION="9.6.5"
    XML2_VERSION="2.9.4"
    GEOS_VERSION="3.6.2"
    GDAL_VERSION="2.2.2"
    JSON_C_VERSION="0.12.1"
    PROTOBUF_VERSION="3.4.1" # must match the version compiled into protobuf C
    PROTOBUF_C_VERSION="1.3.0"
    ${MASON_DIR}/mason install postgres ${POSTGRES_VERSION}
    MASON_POSTGRES=$(${MASON_DIR}/mason prefix postgres ${POSTGRES_VERSION})
    ${MASON_DIR}/mason install libxml2 ${XML2_VERSION}
    MASON_XML2=$(${MASON_DIR}/mason prefix libxml2 ${XML2_VERSION})
    ${MASON_DIR}/mason install geos ${GEOS_VERSION}
    MASON_GEOS=$(${MASON_DIR}/mason prefix geos ${GEOS_VERSION})
    ${MASON_DIR}/mason install libtiff ${LIBTIFF_VERSION}
    MASON_TIFF=$(${MASON_DIR}/mason prefix libtiff ${LIBTIFF_VERSION})
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_TIFF}/lib/libtiff.la
    ${MASON_DIR}/mason install proj ${PROJ_VERSION}
    MASON_PROJ=$(${MASON_DIR}/mason prefix proj ${PROJ_VERSION})
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_PROJ}/lib/libproj.la
    ${MASON_DIR}/mason install jpeg_turbo ${JPEG_VERSION}
    MASON_JPEG=$(${MASON_DIR}/mason prefix jpeg_turbo ${JPEG_VERSION})
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_JPEG}/lib/libjpeg.la
    ${MASON_DIR}/mason install libpng ${PNG_VERSION}
    MASON_PNG=$(${MASON_DIR}/mason prefix libpng ${PNG_VERSION})
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_PNG}/lib/libpng.la
    ${MASON_DIR}/mason install expat ${EXPAT_VERSION}
    MASON_EXPAT=$(${MASON_DIR}/mason prefix expat ${EXPAT_VERSION})
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_EXPAT}/lib/libexpat.la
    ${MASON_DIR}/mason install json-c ${JSON_C_VERSION}
    MASON_JSON_C=$(${MASON_DIR}/mason prefix json-c ${JSON_C_VERSION})
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_JSON_C}/lib/libjson-c.la
    ${MASON_DIR}/mason install protobuf_c ${PROTOBUF_C_VERSION}
    MASON_PROTOBUF_C=$(${MASON_DIR}/mason prefix protobuf_c ${PROTOBUF_C_VERSION})
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_PROTOBUF_C}/lib/libprotobuf-c.la
    ${MASON_DIR}/mason install protobuf ${PROTOBUF_VERSION}
    MASON_PROTOBUF=$(${MASON_DIR}/mason prefix protobuf ${PROTOBUF_VERSION})
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_PROTOBUF}/lib/libprotobuf-lite.la
    ${MASON_DIR}/mason install libpq ${POSTGRES_VERSION}
    MASON_LIBPQ=$(${MASON_DIR}/mason prefix libpq ${POSTGRES_VERSION})
    ${MASON_DIR}/mason install zlib system
    MASON_ZLIB=$(${MASON_DIR}/mason prefix zlib system)
    #${MASON_DIR}/mason install iconv system
    #MASON_ICONV=$(${MASON_DIR}/mason prefix iconv system)
    ${MASON_DIR}/mason install gdal ${GDAL_VERSION}
    MASON_GDAL=$(${MASON_DIR}/mason prefix gdal ${GDAL_VERSION})
    ln -sf ${MASON_GDAL}/include ${MASON_GDAL}/include/gdal
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_GDAL}/lib/libgdal.la
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_PROJ}/lib/libproj.la
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_XML2}/lib/libxml2.la
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_XML2}/bin/xml2-config
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_GEOS}/lib/libgeos.la
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_GEOS}/lib/libgeos_c.la
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_GEOS}/bin/geos-config

}

function mason_compile {
    # put protoc-c on path (comes from protobuf_c)
    export PATH=${MASON_PROTOBUF_C}/bin:${PATH}
    which protoc-c
    export LDFLAGS="${LDFLAGS} \
      -L${MASON_GDAL}/lib -lgdal \
      -L${MASON_GEOS}/lib -lgeos_c -lgeos\
      -L${MASON_ZLIB}/lib -lz \
      -L${MASON_TIFF}/lib -ltiff \
      -L${MASON_JPEG}/lib -ljpeg \
      -L${MASON_PROJ}/lib -lproj \
      -L${MASON_PNG}/lib -lpng \
      -L${MASON_JSON_C}/lib -ljson-c \
      -L${MASON_PROTOBUF_C}/lib -lprotobuf-c \
      -L${MASON_PROTOBUF}/lib -lprotobuf-lite \
      -L${MASON_EXPAT}/lib -lexpat \
      -L${MASON_PROJ}/lib -lproj \
      -L${MASON_XML2}/lib -lxml2"
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG -I$(pwd)/liblwgeom/ \
      -I$(pwd)/raster/ -I$(pwd)/raster/rt_core/ \
      -I${MASON_TIFF}/include \
      -I${MASON_JPEG}/include \
      -I${MASON_PROJ}/include \
      -I${MASON_PNG}/include \
      -I${MASON_EXPAT}/include \
      -I${MASON_GDAL}/include \
      -I${MASON_JSON_C}/include \
      -I${MASON_PROTOBUF_C}/include \
      -I${MASON_PROTOBUF}/include \
      -I${MASON_POSTGRES}/include/server \
      -I${MASON_GEOS}/include \
      -I${MASON_PROJ}/include \
      -I${MASON_XML2}/include/libxml2"

    if [[ $(uname -s) == 'Darwin' ]]; then
        export LDFLAGS="${LDFLAGS} -Wl,-lc++ -Wl,${MASON_GDAL}/lib/libgdal.a -Wl,${MASON_POSTGRES}/lib/libpq.a -liconv"
    else
        export LDFLAGS="${LDFLAGS} ${MASON_GDAL}/lib/libgdal.a -lgeos_c -lgeos -lxml2 -lproj -lexpat -lpng -ljson-c -lprotobuf-c -lprotobuf-lite -ltiff -ljpeg ${MASON_POSTGRES}/lib/libpq.a -pthread -ldl -lz -lstdc++ -lm"
    fi


    MASON_LIBPQ_PATH=${MASON_POSTGRES}/lib/libpq.a
    MASON_LIBPQ_PATH2=${MASON_LIBPQ_PATH////\\/}
    perl -i -p -e "s/\-lpq/${MASON_LIBPQ_PATH2} -pthread/g;" configure
    perl -i -p -e "s/librtcore\.a/librtcore\.a \.\.\/\.\.\/liblwgeom\/\.libs\/liblwgeom\.a/g;" raster/loader/Makefile.in

    if [[ $(uname -s) == 'Linux' ]]; then
      # help initGEOS configure check
      perl -i -p -e "s/\-lgeos_c  /\-lgeos_c \-lgeos \-lstdc++ \-lm /g;" configure
      # help GDALAllRegister configure check
      CMD="data=open('./configure','r').read();open('./configure','w')"
      CMD="${CMD}.write(data.replace('\`\$GDAL_CONFIG --libs\`','\"-lgdal -lgeos_c -lgeos -lxml2 -lproj -lexpat -lpng -ljson-c -lprotobuf-c -lprotobuf-lite -ltiff -ljpeg ${MASON_POSTGRES}/lib/libpq.a -pthread -ldl -lz -lstdc++ -lm\"'))"
      python -c "${CMD}"
    fi

    ./configure \
        --enable-static --disable-shared \
        --prefix=$(mktemp -d) \
        ${MASON_HOST_ARG} \
        --with-projdir=${MASON_PROJ} \
        --with-geosconfig=${MASON_GEOS}/bin/geos-config \
        --with-pgconfig=${MASON_POSTGRES}/bin/pg_config \
        --with-xml2config=${MASON_XML2}/bin/xml2-config \
        --with-gdalconfig=${MASON_GDAL}/bin/gdal-config \
        --with-jsondir=${MASON_JSON_C} \
        --with-protobufdir=${MASON_PROTOBUF_C} \
        --without-gui \
        --with-topology \
        --with-raster \
        --with-sfcgal=no \
        --without-sfcgal \
        --disable-nls || (cat config.log && exit 1)
    # -j${MASON_CONCURRENCY} disabled due to https://trac.osgeo.org/postgis/ticket/3345
    make LDFLAGS="$LDFLAGS" CFLAGS="$CFLAGS"
    make install LDFLAGS="$LDFLAGS" CFLAGS="$CFLAGS"
    # the meat of postgis installs into postgres directory
    # so we actually want to package postgres with the postgis stuff
    # inside, so here we symlink it
    mkdir -p $(dirname $MASON_PREFIX)
    ln -sf ${MASON_POSTGRES} ${MASON_PREFIX}
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

function mason_clean {
    make clean
}

mason_run "$@"
