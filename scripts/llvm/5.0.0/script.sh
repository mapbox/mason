#!/usr/bin/env bash

# For context on this file see https://github.com/mapbox/mason/blob/master/scripts/llvm/base/README.md

# dynamically determine the path to this package
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
# dynamically take name of package from directory
MASON_NAME=$(basename $(dirname $HERE))
# dynamically take the version of the package from directory
MASON_VERSION=$(basename $HERE)
# inherit all functions from llvm base
source ${HERE}/../../${MASON_NAME}/base/common.sh

# broken with:
# ../tools/clang/tools/include-what-you-use/iwyu_ast_util.cc:455:3: error: use of undeclared identifier 'printTemplateArgumentList'
# function setup_release() {
#     get_llvm_project "https://github.com/include-what-you-use/include-what-you-use.git"  ${MASON_BUILD_PATH}/tools/clang/tools/include-what-you-use "" 5788b34c2e22fa97630c4a5b1153d828698f9ac1
# }

mason_run "$@"
