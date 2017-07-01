#!/usr/bin/env bash

set -eu
set -o pipefail


# by default put the local mason on PATH for
# use in the tests
if [[ ! ${MASON_CUSTOM_PATH:-} ]]; then
    export PATH=$(pwd):${PATH}
fi

$(dirname $0)/unit.sh
$(dirname $0)/llvm.sh
$(dirname $0)/c_install.sh
$(dirname $0)/c_build.sh
$(dirname $0)/c_build_android.sh
$(dirname $0)/c_build_xcompile.sh
$(dirname $0)/c_install_symlink_includes.sh
$(dirname $0)/cpp11_header_install.sh
$(dirname $0)/cpp11_install.sh
$(dirname $0)/cpp11_build.sh
$(dirname $0)/install_mason_from_tag.sh
$(dirname $0)/broken_package_must_error.sh
