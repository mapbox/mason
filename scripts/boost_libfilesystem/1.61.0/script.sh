#!/usr/bin/env bash

function init_boost_common {
    HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
    BASE_PATH=$(realpath ${HERE}/../../boost/$(basename $HERE))

    # inherit from boost base (used for all boost library packages)
    source ${BASE_PATH}/base.sh

    # setup mason env
    . ${MASON_DIR}/mason.sh

    # source common build functions
    source ${BASE_PATH}/common.sh
}

init_boost_common
# key properties unique to this library
THIS_DIR=$(basename $(dirname $HERE))
BOOST_LIBRARY=${THIS_DIR#boost_lib}
mason_run "$@"
