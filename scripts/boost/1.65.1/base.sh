#!/usr/bin/env bash

# NOTE: use the ./utils/new_boost.sh script to create new versions

export MASON_VERSION=1.65.1
export BOOST_VERSION=${MASON_VERSION//./_}
export BOOST_TOOLSET=$(basename ${CC})
export BOOST_TOOLSET_CXX=$(basename ${CXX})
export BOOST_ARCH="x86"
export BOOST_SHASUM=094a03dd6f07e740719b944cfe01a278f5326315
# special override to ensure each library shares the cached download
export MASON_DOWNLOAD_SLUG="boost-${MASON_VERSION}"
