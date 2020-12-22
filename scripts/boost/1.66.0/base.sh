#!/usr/bin/env bash

# NOTE: use the ./utils/new_boost.sh script to create new versions

function guess_compiler_name() {
    case $1 in
        ccache| */ccache) shift;;
    esac
    printf '%s' "${1##*/}"
}

export MASON_VERSION=1.66.0
export BOOST_VERSION=${MASON_VERSION//./_}
export BOOST_TOOLSET=$(guess_compiler_name $CC)
export BOOST_TOOLSET_CXX=$(guess_compiler_name $CXX)
export BOOST_ARCH="x86"
export BOOST_SHASUM=5552748d2f0aede9ad1dfbb7f16832bbb054ca4d
# special override to ensure each library shares the cached download
export MASON_DOWNLOAD_SLUG="boost-${MASON_VERSION}"
