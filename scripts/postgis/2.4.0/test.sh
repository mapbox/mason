#!/usr/bin/env bash

set -ue

: '
Assumes gdal and postgis have been linked

'

if [[ ${PGDATA:-unset} != "unset" ]] || [[ ${PGHOST:-unset} != "unset" ]] || [[ ${PGTEMP_DIR:-unset} != "unset" ]]; then
    echo "ERROR: this script deletes \${PGDATA}, \${PGHOST}, and \${PGTEMP_DIR}."
    echo "So it will not run if you have these set in your environment"
    exit 1
fi

# make sure we can init, start, create db, and stop
export PGDATA=./local-postgres
# PGHOST must start with / so therefore must be absolute path
export PGHOST=$(pwd)/local-unix-socket
export PGTEMP_DIR=$(pwd)/local-tmp
export PGPORT=1111

# cleanup
function cleanup() {
    if [[ -d ${PGDATA} ]]; then rm -r ${PGDATA}; fi
    if [[ -d ${PGTEMP_DIR} ]]; then rm -r ${PGTEMP_DIR}; fi
    if [[ -d ${PGHOST} ]]; then rm -r ${PGHOST}; fi
    rm -f postgres.log
    rm -f seattle_washington_water_coast*
    rm -f seattle_washington.water.coast*
}

function setup() {
    mkdir ${PGTEMP_DIR}
    mkdir ${PGHOST}
}

function finish {
  ./mason_packages/.link/bin/pg_ctl -w stop
  cleanup
}

trap finish EXIT

cleanup
setup

./mason_packages/.link/bin/initdb
export PATH=./mason_packages/.link/bin/:${PATH}
# must be absolute
export GDAL_DATA=$(pwd)/mason_packages/.link/share/gdal
postgres -k $PGHOST > postgres.log &
sleep 2
cat postgres.log
createdb template_postgis
psql -l
psql template_postgis -c "CREATE TABLESPACE temp_disk LOCATION '${PGTEMP_DIR}';"
psql template_postgis -c "SET temp_tablespaces TO 'temp_disk';"
psql template_postgis -c "CREATE EXTENSION postgis;"
psql template_postgis -c "SELECT PostGIS_Full_Version();"
psql template_postgis -c "SELECT ST_AsGeoJSON(ST_GeomFromGeoJSON('{ \"type\": \"Point\", \"coordinates\": [0,0] }'));"
curl -OL "https://s3.amazonaws.com/metro-extracts.mapzen.com/seattle_washington.water.coastline.zip"
unzip -o seattle_washington.water.coastline.zip
createdb test-osm -T template_postgis
shp2pgsql -s 4326 seattle_washington_water_coast.shp coast | psql test-osm
psql test-osm -c "SELECT count(*) from coast;"