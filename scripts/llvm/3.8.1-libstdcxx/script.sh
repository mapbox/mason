#!/usr/bin/env bash

export BUILD_AND_LINK_LIBCXX=false

# dynamically determine the path to this package
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
# dynamically take name of package from directory
MASON_NAME=$(basename $(dirname $HERE))
# dynamically take the version of the package from directory
MASON_VERSION=$(basename $HERE)
export MASON_BASE_VERSION=${MASON_VERSION/-libstdcxx/}

# inherit all functions from llvm base
source ${HERE}/../../${MASON_NAME}/base/common.sh

mason_run "$@"
