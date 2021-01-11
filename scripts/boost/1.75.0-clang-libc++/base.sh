#!/usr/bin/env bash

# NOTE: use the ./utils/new_boost.sh script to create new versions

export MASON_VERSION="$( basename "$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )" )"
export BOOST_VERSION="$( echo "${MASON_VERSION}" | sed 's/-.*$//' )"
export BOOST_VERSION_UC=${BOOST_VERSION//./_}
export BOOST_TOOLSET=$(CC=${CC#ccache }; basename -- ${CC%% *})
export BOOST_TOOLSET_CXX=$(CXX=${CXX#ccache }; basename -- ${CXX%% *})
export BOOST_ARCH="x86"
export BOOST_SHASUM=1a5d6590555afdfada1428f1469ec2a8053e10b5
# special override to ensure each library shares the cached download
export MASON_DOWNLOAD_SLUG="boost-${BOOST_VERSION}"
