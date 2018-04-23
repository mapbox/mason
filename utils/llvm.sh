#!/usr/bin/env bash

set -eu
set -o pipefail

: '

For more details on how to use this script see https://github.com/mapbox/mason/blob/master/scripts/llvm/base/README.md

'

function usage() {
    echo "Usage workflow:"
    echo
    echo "  Create a new llvm package and sub-packages:"
    echo "    ./utils/llvm.sh create <new version> <previous version>"
    echo
    echo "  Test building new llvm package:"
    echo "    ./mason build llvm <new version>"
    echo
    echo "  Build the new llvm sub-packages:"
    echo "    ./utils/llvm.sh build <new version>"
    echo
    echo "  Publish the llvm package:"
    echo "    ./mason publish llvm <new version>"
    echo
    echo "  Publish all the sub-packages:"
    echo "    ./utils/llvm.sh publish <new version>"
    echo ""
    echo "See scripts/llvm/base/README.md for more details"
}

subpackages=(clang++ clang-tidy clang-format lldb llvm-cov include-what-you-use)

function build() {
    local VERSION=$1
    for package in "${!subpackages[@]}"; do
        ./mason build ${subpackages[$package]} ${VERSION}
    done
}

function publish() {
    local VERSION=$1
    for package in "${!subpackages[@]}"; do
        ./mason publish ${subpackages[$package]} ${VERSION}
    done
}

function create() {
    if [[ ! ${1:-} ]]; then
        usage
        echo
        echo
        echo "ERROR: please provide first arg of new version"
        exit 1
    fi
    if [[ -d ./scripts/llvm/${1} ]] && [[ ${FORCE_LLVM_OVERWRITE:-false} != 1 ]]; then
        usage
        echo
        echo
        echo "ERROR: first arg must point to a version of llvm that does not exist (or pass 'FORCE_LLVM_OVERWRITE=1 ./utils/llvm.sh create'"
        exit 1
    fi
    if [[ ! -d ./scripts/llvm/${2} ]]; then
        usage
        echo
        echo
        echo "ERROR: second arg must point to a version of llvm that already exists (since we need to copy from it)"
        exit 1
    fi
    if [[ ! ${2:-} ]]; then
        usage
        echo
        echo
        echo "ERROR: please provide second arg of version to copy from"
        exit 1
    fi

    local NEW_VERSION="$1"
    local LAST_VERSION="$2"
    mkdir -p scripts/llvm/${NEW_VERSION}
    cp -r scripts/llvm/${LAST_VERSION}/. scripts/llvm/${NEW_VERSION}/
    for package in "${!subpackages[@]}"; do
        mkdir -p scripts/${subpackages[$package]}/${NEW_VERSION}
        cp -r scripts/${subpackages[$package]}/${LAST_VERSION}/. scripts/${subpackages[$package]}/${NEW_VERSION}/
    done
}

if [[ ${1:-0} == "create" ]]; then
    shift
    create $@
elif [[ ${1:-0} == "build" ]]; then
    shift
    build $@
elif [[ ${1:-0} == "publish" ]]; then
    shift
    publish $@
else
    usage
    exit 1
fi
