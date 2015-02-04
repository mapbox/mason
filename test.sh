#!/usr/bin/env bash

set -u

CODE=0

function check_cflags() {
    MASON_CFLAGS=$(./script.sh cflags)
    MASON_CFLAGS=${MASON_CFLAGS/-I/}
    if [[ ! -d ${MASON_CFLAGS} ]]; then
        echo "not ok: Path for cflags not found: ${MASON_CFLAGS}"
        CODE=1
    else
        echo "ok: path to cflags found: ${MASON_CFLAGS}"
    fi
}

function check_ldflags() {
    MASON_LDFLAGS=$(./script.sh ldflags)
    for var in $MASON_LDFLAGS; do
        if [[ "${var}" =~ "-L" ]]; then
            vpath=${var/-L/}
            if [[ ! -d ${vpath} ]]; then
                echo "not ok: Path for ldflags not found: ${vpath}"
                CODE=1
            else
                echo "ok: path to ldflags found: ${vpath}"
            fi
        fi
    done
}

function read_link() {
    # number of processors on the current system
    case "$(uname -s)" in
        'Linux')    readlink -f $1;;
        'Darwin')   readlink $1;;
        *)          echo 1;;
    esac
}

function check_file_links() {
    if [[ ! -L ./mason_packages/.link/$1 ]]; then
        echo "not ok: ./mason_packages/.link/$1 is not a symlink"
        CODE=1
    else
        echo "ok: ./mason_packages/.link/$1 is a symlink"
        if [[ ! -f ./mason_packages/.link/$1 ]]; then
            echo "not ok: ./mason_packages/.link/$1 is not a file"
            CODE=1
        else
            echo "ok: ./mason_packages/.link/$1 is a file"
        fi
    fi

}

function check_shared_lib_info() {
    resolved=$(read_link ./mason_packages/.link/$1)
    if [[ -f $resolved ]]; then
        echo "ok: resolved to $resolved"
        if [[ ${MASON_PLATFORM} == 'osx' ]]; then
            file $resolved
            otool -L $resolved
            lipo -info $resolved
        elif [[ ${MASON_PLATFORM} == 'ios' ]]; then
            file $resolved
            otool -L $resolved
            lipo -info $resolved
        elif [[ ${MASON_PLATFORM} == 'linux' ]]; then
            file $resolved
            ldd $resolved
            readelf -d $resolved
        elif [[ ${MASON_PLATFORM} == 'android' ]]; then
            file $resolved
            BIN_PATH=$(~/.mason/mason env MASON_SDK_ROOT)/bin
            MASON_ANDROID_TOOLCHAIN=$(${MASON_DIR:-~/.mason}/mason env MASON_ANDROID_TOOLCHAIN)
            ${BIN_PATH}/${MASON_ANDROID_TOOLCHAIN}-readelf -d $resolved
        fi

    else
        echo "not okay: could not resolve to file: $resolved"
        CODE=1
    fi
}

check_cflags
check_ldflags
check_file_links "include/zlib.h"
check_file_links "include/zconf.h"
check_file_links "lib/libz.$(${MASON_DIR:-~/.mason}/mason env MASON_DYNLIB_SUFFIX)"
check_shared_lib_info "lib/libz.$(${MASON_DIR:-~/.mason}/mason env MASON_DYNLIB_SUFFIX)"

exit ${CODE}

