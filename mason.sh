#!/usr/bin/env bash

# Mason Client Version 1.0.0

# See below for `set -euo pipefail`

# Print file + line number when not in CLI mode
if [[ "$0" != "$BASH_SOURCE" ]]; then
function mason_error {
    local _LINE _FN _FILE
    read _LINE _FN _FILE <<< "`caller 1`"
    if [ -t 1 ]; then
        >&2 echo -e "\033[1m\033[31m$@ in ${_FILE} on line ${_LINE}\033[0m"
    else
        >&2 echo "$@ in ${_FILE} on line ${_LINE}"
    fi
}
else
function mason_error {
    if [ -t 1 ]; then
        >&2 echo -e "\033[1m\033[31m$@\033[0m"
    else
        >&2 echo "$@"
    fi
}
fi

function mason_info {
    if [ -t 1 ]; then
        >&2 echo -e "\033[1m\033[36m$@\033[0m"
    else
        >&2 echo "$@"
    fi
}

function mason_detect_platform {
    # Determine platform
    if [[ -z "${MASON_PLATFORM:-}" ]]; then
        if [[ "`uname -s`" = 'Darwin' ]]; then
            MASON_PLATFORM="osx"
        else
            MASON_PLATFORM="linux"
        fi
    fi

    # Determine platform version string
    if [[ -z "${MASON_PLATFORM_VERSION:-}" ]]; then
        MASON_PLATFORM_VERSION="`uname -m`"
    fi
}

function mason_trim {
    local _TMP="${1#"${1%%[![:space:]]*}"}"
    echo -n "${_TMP%"${_TMP##*[![:space:]]}"}"
}

function mason_uppercase {
    echo -n "$1" | tr "[a-z]" "[A-Z]"
}

function mason_use {
    local _HEADER_ONLY=false _PACKAGE _SAFE_PACKAGE _VERSION _PLATFORM_ID _SLUG _INSTALL_PATH _INSTALL_PATH_RELATIVE

    while [[ $# -gt 0 ]]; do
        if [[ $1 == "--header-only" ]]; then
            _HEADER_ONLY=true
        elif [[ -z "${_PACKAGE:-}" ]]; then
            _PACKAGE="$1"
        elif [[ -z "${_VERSION:-}" ]]; then
            _VERSION="$1"
        else
            mason_error "[Mason] mason_use() called with unrecognized arguments: '$@'"
            exit 1
        fi
        shift
    done

    if [[ -z "${_PACKAGE:-}" ]]; then
        mason_error "[Mason] No package name given"
        exit 1
    fi

    # Create a package name that we can use as shell variable names.
    _SAFE_PACKAGE="${_PACKAGE//[![:alnum:]]/_}"

    if [[ -z "${_VERSION:-}" ]]; then
        mason_error "[Mason] Specifying a version is required"
        exit 1
    fi

    _PLATFORM_ID="${MASON_PLATFORM}-${MASON_PLATFORM_VERSION}"
    if [[ "${_HEADER_ONLY}" = true ]] ; then
        _PLATFORM_ID="headers"
    fi

    _SLUG="${_PLATFORM_ID}/${_PACKAGE}/${_VERSION}"
    _INSTALL_PATH="${MASON_PACKAGE_DIR}/${_SLUG}"
    _INSTALL_PATH_RELATIVE="${_INSTALL_PATH#`pwd`/}"

    if [[ ! -d "${_INSTALL_PATH}" ]]; then
        local _CACHE_PATH _URL _CACHE_DIR _ERROR
        _CACHE_PATH="${MASON_PACKAGE_DIR}/.binaries/${_SLUG}.tar.gz"
        if [ ! -f "${_CACHE_PATH}" ]; then
            # Download the package
            _URL="${MASON_REPOSITORY}/${_SLUG}.tar.gz"
            mason_info "[Mason] Downloading package ${_URL}..."
            _CACHE_DIR="`dirname "${_CACHE_PATH}"`"
            mkdir -p "${_CACHE_DIR}"
            if ! _ERROR=$(curl --retry 3 --silent --fail --show-error --location "${_URL}" --output "${_CACHE_PATH}.tmp" 2>&1); then
                mason_error "[Mason] ${_ERROR}"
                exit 1
            else
                # We downloaded to a temporary file to prevent half-finished downloads
                mv "${_CACHE_PATH}.tmp" "${_CACHE_PATH}"
            fi
        fi

        # Unpack the package
        mason_info "[Mason] Unpacking package to ${_INSTALL_PATH_RELATIVE}..."
        mkdir -p "${_INSTALL_PATH}"
        tar xzf "${_CACHE_PATH}" -C "${_INSTALL_PATH}"
    fi

    # Error out if there is no config file.
    if [[ ! -f "${_INSTALL_PATH}/mason.ini" ]]; then
        mason_error "[Mason] Could not find mason.ini for package ${_PACKAGE} ${_VERSION}"
        exit 1
    fi

    # We use this instead of declare, since it declare makes local variables when run in a function.
    read "MASON_PACKAGE_${_SAFE_PACKAGE}_PREFIX" <<< "${_INSTALL_PATH}"

    # Load the configuration from the ini file
    local _LINE _KEY _VALUE
    while read _LINE; do
        _KEY="`mason_trim "${_LINE%%=*}"`"
        if [[ "${_KEY}" =~ ^[a-z_]+$ ]]; then
            _KEY="`mason_uppercase "${_KEY}"`" # Convert to uppercase
            _LINE="${_LINE%%;*}" # Trim trailing comments
            _VALUE="`mason_trim "${_LINE#*=}"`"
            _VALUE="${_VALUE//\{prefix\}/${_INSTALL_PATH}}" # Replace {prefix}
            read "MASON_PACKAGE_${_SAFE_PACKAGE}_${_KEY}" <<< "${_VALUE}"
        fi
    done < "${_INSTALL_PATH}/mason.ini"

    # We're using the fact that this variable is declared to pass back the package name we parsed
    # from the argument string to avoid polluting the global namespace.
    if [ ! -z ${_MASON_SAFE_PACKAGE_NAME+x} ]; then
        _MASON_SAFE_PACKAGE_NAME="${_SAFE_PACKAGE}"
    fi
}

function mason_cli {
    local _MASON_SAFE_PACKAGE_NAME= _PROP _VAR
    if [[ $# -lt 1 ]]; then
        mason_error "[Mason] Usage: $0 <property> [--header-only] <name> <version>"
        mason_error "[Mason] <property> is one of 'include_dirs', 'definitions', 'options', 'ldflags', 'static_libs', or any custom variables in the package's mason.ini."
        exit 1
    fi

    # Store first argument and pass the remaining arguments to mason_use
    _PROP="`mason_uppercase "$1"`"
    shift
    mason_use "$@"

    # Optionally print variables
    _VAR="MASON_PACKAGE_${_MASON_SAFE_PACKAGE_NAME}_${_PROP}"
    if [[ ! -z "${!_VAR:-}" ]]; then
        echo "${!_VAR}"
    fi
}

# Directory where Mason packages are located; typically ends with mason_packages
if [[ -z "${MASON_PACKAGE_DIR:-}" ]]; then
    MASON_PACKAGE_DIR="`pwd`/mason_packages"
fi

# URL prefix of where packages are located.
if [[ -z "${MASON_REPOSITORY:-}" ]]; then
    MASON_REPOSITORY="https://mason-binaries.s3.amazonaws.com"
fi

mason_detect_platform

# Print variables if this shell script is invoked directly.
if [[ "$0" = "$BASH_SOURCE" ]]; then
    set -euo pipefail
    mason_cli "$@"
fi
