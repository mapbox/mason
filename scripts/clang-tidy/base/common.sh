#!/usr/bin/env bash

function mason_build {
    ${MASON_DIR}/mason install llvm ${MASON_VERSION}
    CLANG_PREFIX=$(${MASON_DIR}/mason prefix llvm ${MASON_VERSION})

    # copy bin
    mkdir -p "${MASON_PREFIX}/bin"
    cp "${CLANG_PREFIX}/bin/${MASON_NAME}" "${MASON_PREFIX}/bin/"
    cp "${CLANG_PREFIX}/bin/clang-apply-replacements" "${MASON_PREFIX}/bin/"

    # copy include/c++
    mkdir -p "${MASON_PREFIX}/include"

    # copy c++ headers (on osx these are a symlink to the system headers)
    if [[ -d "${CLANG_PREFIX}/include/c++" ]]; then
        cp -r "${CLANG_PREFIX}/include/c++" "${MASON_PREFIX}/include/"
    fi

    # copy libs
    mkdir -p "${MASON_PREFIX}/lib"
    mkdir -p "${MASON_PREFIX}/lib/clang"
    cp -r ${CLANG_PREFIX}/lib/clang/${MASON_VERSION} "${MASON_PREFIX}/lib/clang/"

    # copy tidy-related share files
    mkdir -p "${MASON_PREFIX}/share"
    cp -r "${CLANG_PREFIX}/share/clang/run-clang-tidy.py" "${MASON_PREFIX}/share/"
    cp -r "${CLANG_PREFIX}/share/clang/clang-tidy-diff.py" "${MASON_PREFIX}/share/"
    cp -r "${CLANG_PREFIX}/share/clang/run-find-all-symbols.py" "${MASON_PREFIX}/share/"

}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_static_libs {
    :
}