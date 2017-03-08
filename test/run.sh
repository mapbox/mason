#!/usr/bin/env bash

set -euo pipefail

export TEST_PLATFORM="linux"
if [[ "`uname -s`" = 'Darwin' ]]; then
    TEST_PLATFORM="osx"
fi
export TEST_PLATFORM_VERSION="`uname -m`"
export TEST_SLUG="${TEST_PLATFORM}-${TEST_PLATFORM_VERSION}"
export MASON_REPOSITORY="http://localhost:8000/test/packages"

# Start web server
test/util/mongoose-${TEST_SLUG} &
MONGOOSE=$!

# Shut down web server when test exits
function finish {
  rm -rf mason_packages
  kill -HUP ${MONGOOSE}
}
trap finish EXIT

function mason_error {
    local _LINE _FN _FILE
    read _LINE _FN _FILE <<< "`caller 0`"
    >&2 echo -e "\033[1m\033[31mFailure in ${_FILE} on line ${_LINE}\033[0m"
}

function mason_succeeds {
    >&2 echo -n "- Testing '$1'"
    shift
    local OUTPUT
    if ! OUTPUT=$("$@" 2>&1); then
        local LINE FN FILE
        read LINE FN FILE <<< "`caller 0`"
        >&2 echo -e " \033[1m\033[31mFAILED\033[0m in ${FILE} on line ${LINE}"
        if [ ! -z "$@" ]; then
            >&2 echo -ne "  \033[1mEvaluated\033[0m: "
            >&2 sed '2,$s/^/             /' <<< "$@"
        fi
        if [ ! -z "${OUTPUT}" ]; then
            >&2 echo -ne "     \033[1mOutput\033[0m: "
            >&2 sed '2,$s/^/             /' <<< "${OUTPUT}"
        fi
        return 1
    else
        >&2 echo -e " \033[1m\033[32mok\033[0m"
    fi
}

function mason_fails {
    >&2 echo -n "- Testing '$1'"
    shift
    local OUTPUT
    if OUTPUT=$("$@" 2>&1); then
        local LINE FN FILE
        read LINE FN FILE <<< "`caller 0`"
        >&2 echo -e " \033[1m\033[31mSUCCEEDED erroneously\033[0m in ${FILE} on line ${LINE}"
        if [ ! -z "$@" ]; then
            >&2 echo -ne "  \033[1mEvaluated\033[0m: "
            >&2 sed '2,$s/^/             /' <<< "$@"
        fi
        if [ ! -z "${OUTPUT}" ]; then
            >&2 echo -ne "     \033[1mOutput\033[0m: "
            >&2 sed '2,$s/^/             /' <<< "${OUTPUT}"
        fi
        return 1
    else
        >&2 echo -e " \033[1m\033[32mfails expectedly\033[0m"
    fi
}

export mason_error
export mason_succeeds
export mason_fails

FAILED=false

function run_test {
    rm -rf mason_packages
    local OUTPUT
    >&2 echo -en "* Running \033[1m$1\033[0m"
    if ! OUTPUT=$(set -euo pipefail; trap mason_error ERR; source "$1" 2>&1); then
        >&2 echo -e " \033[1m\033[31mFAILED\033[0m:"
        FAILED=true
    else
        >&2 echo -e " \033[1m\033[32mok\033[0m"
    fi
    >&2 sed 's/^/  /' <<< "${OUTPUT}"
    >&2 echo ""
}

if [ $# -ge 1 ]; then
    if [ -f "test/test_$1.sh" ]; then
        echo "test/test_$1.sh"
        run_test "test/test_$1.sh"
    else
        >&2 echo -e "\033[1m\033[31mTest '$1' does not exist\033[0m"
    fi
else
    for FILE in test/test_*.sh ; do
        run_test "${FILE}"
    done
fi



# if [[ ${FAILED} = true ]]; then
#     exit 1
# fi
