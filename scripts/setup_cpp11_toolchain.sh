
function usage() {
    echo "Usage:"
    echo ""
    echo "source ./scripts/setup_cpp11_toolchain.sh [distro]"
    echo ""
    exit 1
}


function main() {

    if [[ ${1:-unset} == "unset" ]] || [[ $1 == '-h' ]] || [[ $1 == '--help' ]]; then
        usage
    fi

    if [[  ${1} != "precise" ]]; then
        echo "only precise is supported at this time"
        exit 1
    fi

    local distro=$1;

    if [[ ${distro} == "precise" ]]; then
        release="12.04"
    else
        echo "only precise is supported at this time"
        exit 1
    fi

    export CPP11_TOOLCHAIN="$(pwd)/toolchain"

    function dpack() {
        if [[ ! -f $2 ]]; then
            wget -q $1/$(echo $2 | sed 's/+/%2B/g')
            dpkg -x $2 ${CPP11_TOOLCHAIN}
        fi
    }

    if [[ $(uname -s) == 'Linux' ]]; then
        local PPA="https://launchpad.net/~ubuntu-toolchain-r/+archive/ubuntu/test/+files"
        # http://llvm.org/apt/precise/dists/llvm-toolchain-${distro}-3.5/main/binary-amd64/Packages
        # TODO: cache these for faster downloads
        local LLVM_DIST="http://llvm.org/apt/${distro}/pool/main/l/llvm-toolchain-3.5"
        dpack ${LLVM_DIST} clang-3.5_3.5~svn217304-1~exp1_amd64.deb
        dpack ${LLVM_DIST} libllvm3.5_3.5~svn217304-1~exp1_amd64.deb
        dpack ${LLVM_DIST} libclang-common-3.5-dev_3.5~svn215019-1~exp1_amd64.deb
        dpack ${PPA} libstdc++6_4.8.1-2ubuntu1~${release}_amd64.deb
        dpack ${PPA} libstdc++-4.8-dev_4.8.1-2ubuntu1~${release}_amd64.deb
        dpack ${PPA} libgcc-4.8-dev_4.8.1-2ubuntu1~${release}_amd64.deb
        export CPLUS_INCLUDE_PATH="${CPP11_TOOLCHAIN}/usr/include/c++/4.8:${CPP11_TOOLCHAIN}/usr/include/x86_64-linux-gnu/c++/4.8:${CPLUS_INCLUDE_PATH}"
        export LD_LIBRARY_PATH="${CPP11_TOOLCHAIN}/usr/lib/x86_64-linux-gnu:${CPP11_TOOLCHAIN}/usr/lib/gcc/x86_64-linux-gnu/4.8/:${LD_LIBRARY_PATH}"
        export LIBRARY_PATH="${LD_LIBRARY_PATH}:${LIBRARY_PATH}"
        export PATH="${CPP11_TOOLCHAIN}/usr/bin":${PATH}
        export CXX="${CPP11_TOOLCHAIN}/usr/bin/clang++-3.5"
        export CC="${CPP11_TOOLCHAIN}/usr/bin/clang-3.5"
    else
        echo "Nothing to be done: this script only bootstraps cpp11 toolchain for linux"
    fi
}

main $@