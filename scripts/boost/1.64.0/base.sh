#!/usr/bin/env bash

# NOTE: use the ./utils/new_boost.sh script to create new versions

export MASON_VERSION=1.64.0
export BOOST_VERSION=${MASON_VERSION//./_}
export BOOST_TOOLSET=$(basename ${CC})
export BOOST_TOOLSET_CXX=$(basename ${CXX})
export BOOST_ARCH="x86"
export BOOST_SHASUM=6e4dad39f14937af73ace20d2279e2468aad14d8
# special override to ensure each library shares the cached download
export MASON_DOWNLOAD_SLUG="boost-${MASON_VERSION}"
