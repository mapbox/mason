#!/usr/bin/env bash

set -e -u
set -o pipefail

./mason install boost 1.57.0
./mason link boost 1.57.0

failure=0

# boost and packages other we symlink the directory 
if [[ ! -d mason_packages/.link/include/boost ]]; then
    echo "could not find expected include/boost"
    failure=1
fi

if [[ ! -L mason_packages/.link/include/boost ]]; then
    echo "include/boost is not a symlink like expected"
    failure=1
fi

./mason install sparsehash 2.0.2
./mason link sparsehash 2.0.2

failure=0

# google packages we symlink the files to avoid conflicts
if [[ ! -d mason_packages/.link/include/google ]]; then
    echo "could not find expected include/google"
    failure=1
fi

if [[ -L mason_packages/.link/include/google ]]; then
    echo "include/google is not expected to be a symlink"
    failure=1
fi

exit $failure


