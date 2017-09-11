set -eu
set -o pipefail

: ' 

manual intervention:

  - change/upgrade icu version used by boost_regex_icu* variants
  - new libraries available to build?

'

function usage() {
    echo "Usage workflow:"
    echo
    echo "  Create a new boost package (header-only) and boost libraries:"
    echo "    ./utils/new_boost.sh create <new version> <previous version>"
    echo
    echo
    echo "  Trigger builds for them (after pushing your branch):"
    echo "    ./utils/new_boost.sh trigger <new version>"
    echo
}

CLEAN="${CLEAN:-false}"


function create() {
    if [[ ! ${1:-} ]]; then
        usage
        echo
        echo
        echo "ERROR: please provide first arg of new version"
        exit 1
    fi
    if [[ -d ./scripts/boost/${1} ]]; then
        usage
        echo
        echo
        echo "ERROR: first arg must point to a version of boost that does not exist"
        exit 1
    fi
    if [[ ! -d ./scripts/boost/${2} ]]; then
        usage
        echo
        echo
        echo "ERROR: second arg must point to a version of boost that already exists (since we need to copy from it)"
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

    if [[ ${CLEAN} ]]; then
        rm -rf scripts/boost/${NEW_VERSION}
    fi

    mkdir -p scripts/boost/${NEW_VERSION}
    cp -r scripts/boost/${LAST_VERSION}/. scripts/boost/${NEW_VERSION}/
    perl -i -p -e "s/MASON_VERSION=${LAST_VERSION}/MASON_VERSION=${NEW_VERSION}/g;" scripts/boost/${NEW_VERSION}/base.sh 
    export BOOST_VERSION=${NEW_VERSION//./_}
    export CACHE_PATH="mason_packages/.cache"
    mkdir -p "${CACHE_PATH}"
    if [[ ! -f ${CACHE_PATH}/boost-${NEW_VERSION} ]]; then
        curl --retry 3 -f -S -L http://downloads.sourceforge.net/project/boost/boost/${NEW_VERSION}/boost_${BOOST_VERSION}.tar.bz2 -o ${CACHE_PATH}/boost-${NEW_VERSION}
    fi

    NEW_SHASUM=$(git hash-object ${CACHE_PATH}/boost-${NEW_VERSION})

    perl -i -p -e "s/BOOST_SHASUM=(.*)/BOOST_SHASUM=${NEW_SHASUM}/g;" scripts/boost/${NEW_VERSION}/base.sh 

    for lib in $(find scripts/ -maxdepth 1 -type dir -name 'boost_lib*' -print); do
        if [[ -d $lib/${LAST_VERSION} ]]; then
            if [[ ${CLEAN} ]]; then
                rm -rf $lib/${NEW_VERSION}
            fi
            mkdir $lib/${NEW_VERSION}
            cp -r $lib/${LAST_VERSION}/. $lib/${NEW_VERSION}/
        else
            echo "skipping creating package for $lib"
        fi
    done
}

# run this after pushing branch
# Note: in the past this would get rate limited at 10
# but @kkaefer convinced travis to increase our limit to 50
function trigger() {
    if [[ ! ${1:-} ]]; then
        usage
        echo
        echo
        echo "ERROR: please provide first arg of new version"
        exit 1
    fi
    if [[ ! -d ./scripts/boost/${1} ]]; then
        usage
        echo
        echo
        echo "ERROR: second arg must point to a version of boost that already exists (since we need to copy from it)"
        exit 1
    fi
    NEW_VERSION=${1}
    ./mason trigger boost ${NEW_VERSION}
    for lib in $(find scripts/ -maxdepth 1 -type dir -name 'boost_lib*' -print); do
        ./mason trigger $(basename $lib) ${NEW_VERSION}
    done
}


if [[ ${1:-0} == "create" ]]; then
    shift
    create $@
elif [[ ${1:-0} == "trigger" ]]; then
    shift
    trigger $@
else
    usage
    exit 1
fi


