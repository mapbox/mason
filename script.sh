#!/usr/bin/env bash

MASON_NAME=Qt
MASON_VERSION=system
MASON_SYSTEM_PACKAGE=true

. ${MASON_DIR:-~/.mason}/mason.sh

QT_LIBS=${2:-QtCore}

for LIB in ${QT_LIBS} ; do
    if ! `pkg-config ${LIB} --exists` ; then
        mason_error "Can't find ${LIB}"
        exit 1
    fi
done

function mason_system_version {
    mkdir -p "${MASON_PREFIX}"
    cd "${MASON_PREFIX}"
    if [ ! -f version ]; then
        echo "#include <QtGlobal>
#include <cstdio>

int main() {
    printf(\"%s\", QT_VERSION_STR);
    return 0;
}
" > version.cpp && ${CXX:-c++} -x c++ ${CXXFLAGS} $(mason_cflags) $(mason_ldflags) version.cpp -o version
    fi
    ./version
}

function mason_build {
    :
}

function mason_cflags {
    echo ${MASON_CFLAGS} `pkg-config ${QT_LIBS} --cflags`
}

function mason_ldflags {
    echo ${MASON_LDFLAGS} `pkg-config ${QT_LIBS} --libs`
}

mason_run "$@"
