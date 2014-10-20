set -e
set -o pipefail
# set -x

MASON_ROOT=${MASON_ROOT:-`pwd`/mason_packages}
MASON_BUCKET=${MASON_BUCKET:-mason-binaries}

MASON_UNAME=`uname -s`
if [ ${MASON_UNAME} = 'Darwin' ]; then
    MASON_PLATFORM=${MASON_PLATFORM:-osx}
    MASON_XCODE_ROOT=`"xcode-select" -p`
elif [ ${MASON_UNAME} = 'Linux' ]; then
    MASON_PLATFORM=${MASON_PLATFORM:-linux}
fi


case ${MASON_PLATFORM} in
    'osx'|'ios')    MASON_CONCURRENCY=`sysctl -n hw.ncpu` ;;
    'linux')        MASON_CONCURRENCY=`nproc` ;;
    *)              MASON_CONCURRENCY=1 ;;
esac


function mason_step { >&2 echo -e "\033[1m\033[31m* $1\033[0m"; }
function mason_substep { >&2 echo -e "\033[1m\033[36m* $1\033[0m"; }
function mason_success { >&2 echo -e "\033[1m\033[32m* $1\033[0m"; }
function mason_error { >&2 echo -e "\033[1m\033[31m$1\033[0m"; }


case ${MASON_ROOT} in
    *\ * ) mason_error "Directory '${MASON_ROOT} contains spaces."; exit ;;
esac

if [ ${MASON_PLATFORM} = 'osx' ]; then
    export MASON_HOST_ARG="--host=x86_64-apple-darwin"
    export MASON_PLATFORM_VERSION=`xcrun --sdk macosx --show-sdk-version`

    MASON_SDK_ROOT=${MASON_XCODE_ROOT}/Platforms/MacOSX.platform/Developer
    MASON_SDK_PATH="${MASON_SDK_ROOT}/SDKs/MacOSX${MASON_PLATFORM_VERSION}.sdk"
    export MASON_CFLAGS="-mmacosx-version-min=${MASON_PLATFORM_VERSION} -isysroot ${MASON_SDK_PATH} -arch i386 -arch x86_64"


elif [ ${MASON_PLATFORM} = 'ios' ]; then
    export MASON_HOST_ARG="--host=arm-apple-darwin"
    export MASON_PLATFORM_VERSION=`xcrun --sdk iphoneos --show-sdk-version`

    MASON_SDK_ROOT=${MASON_XCODE_ROOT}/Platforms/iPhoneOS.platform/Developer
    MASON_SDK_PATH="${MASON_SDK_ROOT}/SDKs/iPhoneOS${MASON_PLATFORM_VERSION}.sdk"
    export MASON_IOS_CFLAGS="-miphoneos-version-min=${MASON_PLATFORM_VERSION} -isysroot ${MASON_SDK_PATH} -arch armv7 -arch armv7s -arch arm64"

    if [ `xcrun --sdk iphonesimulator --show-sdk-version` != ${MASON_PLATFORM_VERSION} ]; then
        mason_error "iPhone Simulator SDK version doesn't match iPhone SDK version"
        exit
    fi

    MASON_SDK_ROOT=${MASON_XCODE_ROOT}/Platforms/iPhoneSimulator.platform/Developer
    MASON_SDK_PATH="${MASON_SDK_ROOT}/SDKs/iPhoneSimulator${MASON_PLATFORM_VERSION}.sdk"
    export MASON_ISIM_CFLAGS="-miphoneos-version-min=${MASON_PLATFORM_VERSION} -isysroot ${MASON_SDK_PATH} -arch i386 -arch x86_64"

elif [ ${MASON_PLATFORM} = 'linux' ]; then
    for i in /etc/*-release ; do . $i ; done
    MASON_PLATFORM_DISTRIBUTION=`echo ${ID:-${DISTRIB_ID}} | tr '[:upper:]' '[:lower:]'`
    if [ -z "${MASON_PLATFORM_DISTRIBUTION}" ]; then
        mason_error "Cannot determine distribution name"
        exit
    fi

    MASON_PLATFORM_DISTRIBUTION_VERSION=${DISTRIB_RELEASE:-${VERSION_ID}}
    if [ -z "${MASON_PLATFORM_DISTRIBUTION_VERSION}" ]; then
        mason_error "Cannot determine distribution version"
        exit
    fi

    export MASON_PLATFORM_VERSION=${MASON_PLATFORM_DISTRIBUTION}-${MASON_PLATFORM_DISTRIBUTION_VERSION}-`uname -m`
fi


# Variable defaults
MASON_HOST_ARG=${MASON_HOST_ARG:-}
MASON_PLATFORM_VERSION=${MASON_PLATFORM_VERSION:-0}
MASON_SLUG=${MASON_NAME}-${MASON_VERSION}
MASON_PREFIX=${MASON_ROOT}/${MASON_PLATFORM}-${MASON_PLATFORM_VERSION}/${MASON_NAME}/${MASON_VERSION}
MASON_BINARIES=${MASON_PLATFORM}-${MASON_PLATFORM_VERSION}/${MASON_NAME}/${MASON_VERSION}.tar.gz
MASON_BINARIES_PATH=${MASON_ROOT}/.binaries/${MASON_BINARIES}




function mason_check_existing {
    # skip installing if it already exists
    if [ -f "${MASON_PREFIX}/${MASON_LIB_FILE}" ] ; then
        mason_success "Already installed at ${MASON_PREFIX}"
        exit
    fi
}


function mason_clear_existing {
    if [ -d "${MASON_PREFIX}" ]; then
        mason_step "Removing existing package..."
        rm -rfv "${MASON_PREFIX}"
    fi
}


function mason_download {
    mkdir -p "${MASON_ROOT}/.cache"
    cd "${MASON_ROOT}/.cache"
    if [ ! -f ${MASON_SLUG} ] ; then
        mason_step "Downloading $1..."
        curl -f -# -L "$1" -o ${MASON_SLUG}
    fi

    MASON_HASH=`git hash-object ${MASON_SLUG}`
    if [ "$2" != "${MASON_HASH}" ] ; then
        mason_error "Hash ${MASON_HASH} of file ${MASON_ROOT}/.cache/${MASON_SLUG} doesn't match $2"
        exit 1
    fi
}

function mason_extract_tar_gz {
    rm -rf "${MASON_ROOT}/.build"
    mkdir -p "${MASON_ROOT}/.build"
    cd "${MASON_ROOT}/.build"

    tar xzf ../.cache/${MASON_SLUG}
}



function mason_prepare_compile {
    :
}

function mason_compile {
    mason_error "COMPILE FUNCTION MISSING"
    exit
}

function mason_clean {
    :
}


function mason_build {
    mason_load_source

    mason_step "Building for Platform '${MASON_PLATFORM}/${MASON_PLATFORM_VERSION}'..."
    cd "${MASON_BUILD_PATH}"
    mason_prepare_compile

    if [ ${MASON_PLATFORM} = 'ios' ]; then
        mason_substep "Building for Simulator..."
        export CFLAGS="${MASON_ISIM_CFLAGS}"
        cd "${MASON_BUILD_PATH}"
        mason_compile
        cd "${MASON_PREFIX}"
        mv lib lib-isim
        for i in lib-isim/*.a ; do lipo -info $i ; done

        mason_substep "Building for iOS..."
        export CFLAGS="${MASON_IOS_CFLAGS}"
        cd "${MASON_BUILD_PATH}"
        mason_clean
        cd "${MASON_BUILD_PATH}"
        mason_compile
        cd "${MASON_PREFIX}"
        cp -r lib lib-ios
        for i in lib-ios/*.a ; do lipo -info $i ; done

        # Create universal binary
        mason_substep "Creating Universal Binary..."
        cd "${MASON_PREFIX}/lib-ios"
        for i in *.a ; do
            lipo -create ../lib-ios/$i ../lib-isim/$i -output ../lib/$i
            lipo -info ../lib/$i
        done
        cd "${MASON_PREFIX}"
        rm -rf lib-isim lib-ios
    else
        cd "${MASON_BUILD_PATH}"
        mason_compile
    fi

    mason_success "Installed at ${MASON_PREFIX}"

    rm -rf ${MASON_ROOT}/.build
}


function mason_try_binary {
    MASON_BINARIES_DIR=`dirname "${MASON_BINARIES}"`
    mkdir -p "${MASON_ROOT}/.binaries/${MASON_BINARIES_DIR}"

    # try downloading from S3
    if [ ! -f "${MASON_BINARIES_PATH}" ] ; then
        mason_step "Downloading binary package ${MASON_BINARIES}..."
        curl -f -# -L \
            https://${MASON_BUCKET}.s3.amazonaws.com/${MASON_BINARIES} \
            -o "${MASON_BINARIES_PATH}" || true
    else
        mason_step "Updating binary package ${MASON_BINARIES}..."
        curl -f -# -L -z "${MASON_BINARIES_PATH}" \
            https://${MASON_BUCKET}.s3.amazonaws.com/${MASON_BINARIES} \
            -o "${MASON_BINARIES_PATH}" || true
    fi

    # unzip the file if it exists
    if [ -f "${MASON_BINARIES_PATH}" ] ; then
        mkdir -p "${MASON_PREFIX}"
        cd "${MASON_PREFIX}"
        tar xzf "${MASON_BINARIES_PATH}"
        mason_success "Installed binary package at ${MASON_PREFIX}"
        exit 0
    fi
}


function mason_pkgconfig {
    echo pkg-config \
        ${MASON_PREFIX}/${MASON_PKGCONFIG_FILE} \
        --define-variable=prefix=${MASON_PREFIX} \
        --define-variable=exec_prefix=${MASON_PREFIX}
}

function mason_cflags {
    `mason_pkgconfig` --static --cflags
}

function mason_ldflags {
    `mason_pkgconfig` --static --libs
}


function mason_publish {
    if [ ! -f "${MASON_PREFIX}/${MASON_LIB_FILE}" ] ; then
        mason_error "Required library file ${MASON_PREFIX}/${MASON_LIB_FILE} doesn't exist."
        exit 1
    fi

    if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
        mason_error "AWS_ACCESS_KEY_ID is not set."
        exit 1
    fi

    if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
        mason_error "AWS_SECRET_ACCESS_KEY is not set."
        exit 1
    fi

    mkdir -p `dirname ${MASON_BINARIES_PATH}`
    cd "${MASON_PREFIX}"
    rm -rf "${MASON_BINARIES_PATH}"
    tar czf "${MASON_BINARIES_PATH}" .
    (cd "${MASON_ROOT}/.binaries" && ls -lh "${MASON_BINARIES}")
    mason_step "Uploading binary package..."

    local CONTENT_TYPE="application/octet-stream"
    local DATE="$(LC_ALL=C date -u +"%a, %d %b %Y %X %z")"
    local MD5="$(openssl md5 -binary < "${MASON_BINARIES_PATH}" | base64)"
    local SIGNATURE="$(printf "PUT\n$MD5\n$CONTENT_TYPE\n$DATE\nx-amz-acl:public-read\n/${MASON_BUCKET}/${MASON_BINARIES}" | openssl sha1 -binary -hmac "$AWS_SECRET_ACCESS_KEY" | base64)"

    curl -S -T "${MASON_BINARIES_PATH}" https://${MASON_BUCKET}.s3.amazonaws.com/${MASON_BINARIES} \
        -H "Date: $DATE" \
        -H "Authorization: AWS $AWS_ACCESS_KEY_ID:$SIGNATURE" \
        -H "Content-Type: $CONTENT_TYPE" \
        -H "Content-MD5: $MD5" \
        -H "x-amz-acl: public-read"

    echo https://${MASON_BUCKET}.s3.amazonaws.com/${MASON_BINARIES}
    curl -f -I https://${MASON_BUCKET}.s3.amazonaws.com/${MASON_BINARIES}
}

function mason_run {
    if [ "$1" == "install" ]; then
        if [ ${MASON_SYSTEM_PACKAGE:-false} = true ]; then
            mason_success "Using system-provided ${MASON_NAME} $(mason_system_version)"
        else
            mason_check_existing
            mason_clear_existing
            mason_try_binary
            mason_build
        fi
    elif [ "$1" == "remove" ]; then
        mason_clear_existing
    elif [ "$1" == "publish" ]; then
        mason_publish
    elif [ "$1" == "build" ]; then
        mason_build
    elif [ "$1" == "cflags" ]; then
        mason_cflags
    elif [ "$1" == "ldflags" ]; then
        mason_ldflags
    elif [ "$1" == "prefix" ]; then
        if [ -f "${MASON_PREFIX}/${MASON_LIB_FILE}" ]; then
            echo ${MASON_PREFIX}
        else
            mason_error "Cannot find required library file '${MASON_PREFIX}/${MASON_LIB_FILE}'"
        fi
    else
        mason_error "Unknown command '$1'"
    fi
}

