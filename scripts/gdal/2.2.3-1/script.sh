#!/usr/bin/env bash

MASON_NAME=gdal
MASON_VERSION=2.2.3-1
MASON_VERSION2=2.2.3
MASON_LIB_FILE=lib/libgdal.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        http://download.osgeo.org/gdal/${MASON_VERSION2}/gdal-${MASON_VERSION2}.tar.gz \
        f4ac4fb76e20cc149d169163914d76d51173ce82

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION2}
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
    SQLITE_VERSION="3.21.0"
    CCACHE_VERSION="3.3.1"
    GEOS_VERSION="3.6.2"
    ${MASON_DIR}/mason install geos ${GEOS_VERSION}
    MASON_GEOS=$(${MASON_DIR}/mason prefix geos ${GEOS_VERSION})
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_GEOS}/lib/libgeos.la
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_GEOS}/lib/libgeos_c.la
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_GEOS}/bin/geos-config
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
    ${MASON_DIR}/mason install libpq ${POSTGRES_VERSION}
    MASON_LIBPQ=$(${MASON_DIR}/mason prefix libpq ${POSTGRES_VERSION})
    ${MASON_DIR}/mason install sqlite ${SQLITE_VERSION}
    MASON_SQLITE=$(${MASON_DIR}/mason prefix sqlite ${SQLITE_VERSION})
    perl -i -p -e "s/${FIND}/${REPLACE}/g;" ${MASON_SQLITE}/lib/libsqlite3.la
    # depends on sudo apt-get install zlib1g-dev
    ${MASON_DIR}/mason install zlib system
    MASON_ZLIB=$(${MASON_DIR}/mason prefix zlib system)
    # depends on sudo apt-get install libc6-dev
    #${MASON_DIR}/mason install iconv system
    #MASON_ICONV=$(${MASON_DIR}/mason prefix iconv system)
    export LIBRARY_PATH=${MASON_LIBPQ}/lib:${LIBRARY_PATH:-}
    ${MASON_DIR}/mason install ccache ${CCACHE_VERSION}
    MASON_CCACHE=$(${MASON_DIR}/mason prefix ccache ${CCACHE_VERSION})/bin/ccache
}

function mason_compile {
    if [[ ${MASON_PLATFORM} == 'linux' ]]; then
        mason_step "Loading patch"
        patch -N -p1 < ${MASON_DIR}/scripts/${MASON_NAME}/${MASON_VERSION}/patch.diff
    fi

    # very custom handling for the C++ lib of geos, which also needs
    # to be linked when linking statically (since geos_c C API depends on it)
    if [[ $(uname -s) == 'Linux' ]]; then
        perl -i -p -e "s/ \-lgeos_c/ \-lgeos_c \-lgeos \-lstdc++ \-lm/g;" configure
    elif [[ $(uname -s) == 'Darwin' ]]; then
        perl -i -p -e "s/ \-lgeos_c/ \-lgeos_c \-lgeos \-lc++ \-lm/g;" configure
    fi

    # note CFLAGS overrides defaults so we need to add optimization flags back
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    export CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG"

    CUSTOM_LIBS="-L${MASON_GEOS}/lib -lgeos_c -lgeos -L${MASON_SQLITE}/lib -lsqlite3 -L${MASON_TIFF}/lib -ltiff -L${MASON_JPEG}/lib -ljpeg -L${MASON_PROJ}/lib -lproj -L${MASON_PNG}/lib -lpng -L${MASON_EXPAT}/lib -lexpat"
    CUSTOM_CFLAGS="${CFLAGS} -I${MASON_GEOS}/include -I${MASON_LIBPQ}/include -I${MASON_TIFF}/include -I${MASON_JPEG}/include -I${MASON_PROJ}/include -I${MASON_PNG}/include -I${MASON_EXPAT}/include"

    # very custom handling for libpq/postgres support
    # forcing our portable static library to be used
    MASON_LIBPQ_PATH=${MASON_LIBPQ}/lib/libpq.a

    if [[ $(uname -s) == 'Linux' ]]; then
        # on Linux passing -Wl will lead to libtool re-positioning libpq.a in the wrong place (no longer after libgdal.a)
        # which leads to unresolved symbols
        CUSTOM_LDFLAGS="${LDFLAGS} ${MASON_LIBPQ_PATH}"
        # linking statically to libsqlite requires -ldl -pthreads
        CUSTOM_LDFLAGS="${CUSTOM_LDFLAGS} -ldl -pthread"
    else
        # on OSX not passing -Wl will break libtool archive creation leading to confusing arch errors
        CUSTOM_LDFLAGS="${LDFLAGS} -Wl,${MASON_LIBPQ_PATH}"
    fi
    # we have to remove -lpq otherwise it will trigger linking to system /usr/lib/libpq
    perl -i -p -e "s/\-lpq //g;" configure
    # on linux -Wl,/path/to/libpq.a still does not work for the configure test
    # so we have to force it into LIBS. But we don't do this on OS X since it breaks libtool archive logic
    if [[ $(uname -s) == 'Linux' ]]; then
        CUSTOM_LIBS="${MASON_LIBPQ}/lib/libpq.a -pthread ${CUSTOM_LIBS}"
    fi

    export CXX="${MASON_CCACHE} ${CXX}"

    # note: we put ${STDLIB_CXXFLAGS} into CXX instead of LDFLAGS due to libtool oddity:
    # http://stackoverflow.com/questions/16248360/autotools-libtool-link-library-with-libstdc-despite-stdlib-libc-option-pass
    if [[ $(uname -s) == 'Darwin' ]]; then
        export CXX="${CXX} -stdlib=libc++ -std=c++11"
    fi

    # note: it might be tempting to build with --without-libtool
    # but I find that will only lead to a shared libgdal.so and will
    # not produce a static library even if --enable-static is passed
    LIBS="${CUSTOM_LIBS}" LDFLAGS="${CUSTOM_LDFLAGS}" CFLAGS="${CUSTOM_CFLAGS}" ./configure \
        --enable-static --disable-shared \
        ${MASON_HOST_ARG} \
        --prefix=${MASON_PREFIX} \
        --with-libz=${MASON_ZLIB} \
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
        --with-sqlite3=${MASON_SQLITE} \
        --with-geos=${MASON_GEOS}/bin/geos-config \
        --with-spatialite=no \
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
        --with-python=no \
        --with-java=no \
        --with-podofo=no \
        --with-pam \
        --with-webp=no \
        --with-pcre=no \
        --with-liblzma=no \
        --with-netcdf=no \
        --with-poppler=no \
        --with-sfcgal=no
    make -j${MASON_CONCURRENCY}
    make install

    relativize_gdal_config ${MASON_PREFIX}/bin/gdal-config ${MASON_PREFIX} ${MASON_ROOT}/${MASON_PLATFORM_ID}

}

function relativize_gdal_config() {
    path_to_gdal_config=${1}
    prefix_path=${2}
    build_path=${3}
    RESOLVE_SYMLINK="readlink"
    if [[ $(uname -s) == 'Linux' ]];then
        RESOLVE_SYMLINK="readlink -f"
    fi
    mv ${path_to_gdal_config} /tmp/gdal-config-backup
    # append code at start
    echo 'if test -L $0; then BASE=$( dirname $( '${RESOLVE_SYMLINK}' "$0" ) ); else BASE=$( dirname "$0" ); fi' > ${path_to_gdal_config}
    cat /tmp/gdal-config-backup >> ${path_to_gdal_config}
    chmod +x ${path_to_gdal_config}

    # now modify in place
    python -c "data=open('${path_to_gdal_config}','r').read();open('${path_to_gdal_config}','w').write(data.replace('${prefix_path}','\$( cd \"\$( dirname \${BASE} )\" && pwd )'))"
    # fix the path to dep libs (CONFIG_DEP_LIBS)
    python -c "data=open('${path_to_gdal_config}','r').read();open('${path_to_gdal_config}','w').write(data.replace('${build_path}','\$( cd \"\$( dirname \$( dirname \$( dirname \${BASE}  ) ))\" && pwd )'))"
    # hack to re-add -lpq since otherwise it will not end up in --dep-libs
    python -c "data=open('${path_to_gdal_config}','r').read();open('${path_to_gdal_config}','w').write(data.replace('\$CONFIG_DEP_LIBS','\$CONFIG_DEP_LIBS -lpq'))"
}


function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
}

function mason_ldflags {
    echo $(${MASON_PREFIX}/bin/gdal-config --dep-libs --libs)
}

function mason_clean {
    make clean
}

mason_run "$@"
