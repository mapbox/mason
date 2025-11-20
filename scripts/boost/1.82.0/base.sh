#!/usr/bin/env bash

# NOTE: use the ./utils/new_boost.sh script to create new versions

export MASON_VERSION=1.82.0
export BOOST_VERSION=${MASON_VERSION//./_}
export BOOST_TOOLSET=$(CC=${CC#ccache }; basename -- ${CC%% *})
export BOOST_TOOLSET_CXX=$(CXX=${CXX#ccache }; basename -- ${CXX%% *})
export BOOST_ARCH="x86"
export BOOST_SHASUM=bff3139a6d09c20e4a0d4bb660eaa3ffe7cacf53
# special override to ensure each library shares the cached download
export MASON_DOWNLOAD_SLUG="boost-${MASON_VERSION}"
