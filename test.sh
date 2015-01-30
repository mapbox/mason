#!/usr/bin/env bash

set -u

if [[ ${PGDATA:-unset} != "unset" ]] || [[ ${PGHOST:-unset} != "unset" ]] || [[ ${PGTEMP_DIR:-unset} != "unset" ]]; then
    echo "ERROR: this script deletes \${PGDATA}, \${PGHOST}, and \${PGTEMP_DIR}."
    echo "So it will not run if you have these set in your environment"
    exit 1
fi

# make sure we can init, start, create db, and stop
export PGDATA=./local-postgres
if [[ -d ${PGDATA} ]]; then rm -r ${PGDATA}; fi
# PGHOST must start with / so therefore must be absolute path
export PGHOST=$(pwd)/local-unix-socket
if [[ -d ${PGHOST} ]]; then rm -r ${PGHOST}; fi
mkdir ${PGHOST}

export PGTEMP_DIR=$(pwd)/local-tmp
if [[ -d ${PGTEMP_DIR} ]]; then rm -r ${PGTEMP_DIR}; fi
mkdir ${PGTEMP_DIR}

export PGPORT=1111

function finish {
  ./mason_packages/.link/bin/pg_ctl -w stop
  rm -rf ${PGDATA}
  rm -rf ${PGHOST}
  rm -rf ${PGTEMP_DIR}
}

trap finish EXIT

if [[ ! -d ./mason_packages/.link ]]; then
    ~/.mason/mason link postgres 9.4.0
fi

./mason_packages/.link/bin/initdb
./mason_packages/.link/bin/postgres -k $PGHOST > postgres.log &
sleep 2
cat postgres.log
./mason_packages/.link/bin/createdb template_postgis
./mason_packages/.link/bin/psql -l
./mason_packages/.link/bin/psql template_postgis -c "CREATE TABLESPACE temp_disk LOCATION '${PGTEMP_DIR}';"
./mason_packages/.link/bin/psql template_postgis -c "SET temp_tablespaces TO 'temp_disk';"
#./mason_packages/.link/bin/psql template_postgis -c "CREATE EXTENSION postgis;"
