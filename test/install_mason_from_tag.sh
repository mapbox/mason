#!/usr/bin/env bash

set -eu
set -o pipefail

# Test installing based on the recommended method
# get the latest tag
TAG_NAME=$(cat mason | grep MASON_RELEASED_VERSION= | cut -d '"' -f2)
echo "found ${TAG_NAME}"

# if the current tag is available, test installing it
if [[ $(git tag -l) =~ ${TAG_NAME} ]]; then
    # Test installing via curl to /tmp
    curl -sSfL https://github.com/mapbox/mason/archive/v${TAG_NAME}.tar.gz | tar --gunzip --extract --strip-components=1 --exclude="*md" --exclude="test*" --directory=/tmp
    # ensure the command works
    /tmp/mason install zlib 1.2.8
fi