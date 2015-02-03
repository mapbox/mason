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

function check_file_links() {
    if [[ ! -L ./mason_packages/.link/$1 ]]; then
        echo "not ok: ./mason_packages/.link/$1 is not a symlink"
        CODE=1
    else
        echo "ok: ./mason_packages/.link/$1 is a symlink"
    fi

    if [[ ! -f ./mason_packages/.link/$1 ]]; then
        echo "not ok: ./mason_packages/.link/$1 is not a file"
        CODE=1
    else
        echo "ok: ./mason_packages/.link/$1 is a file"
    fi

}

check_cflags
check_ldflags
check_file_links "include/zlib.h"
check_file_links "include/zconf.h"
check_file_links "lib/libz.$(${MASON_DIR:-~/.mason}/mason env MASON_DYNLIB_SUFFIX)"

exit ${CODE}

