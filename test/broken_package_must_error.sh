#!/usr/bin/env bash

CODE=0

source $(dirname $0)/assert.sh

function finish {
  rm -rf ./scripts/broken
}

trap finish EXIT

function place_broken() {
    rm -rf ./scripts/broken/0.0.0
    mkdir -p ./scripts/broken/0.0.0
    cp -r $(dirname $0)/fixtures/broken-packages/${1} ./scripts/broken/0.0.0/script.sh
}

RESULT=0
RETURN=0
function test_one() {
    place_broken ${1}
    RESULT=$(mason build broken 0.0.0 2>&1)
    RETURN=$?
    rm -rf ./scripts/broken
}

test_one unbound_var.sh
assertEqual "${RETURN}" "1" "got expected error code"
assertContains "${RESULT}" "unbound variable" "got expected output"

test_one undefined_MASON_PKGCONFIG_FILE.sh
assertEqual "${RETURN}" "1" "got expected error code"
expected_error="The MASON_PKGCONFIG_FILE variable not found in script.sh. Please either provide this variable or override the mason_cflags function hook"
assertContains "${RESULT}" "${expected_error}" "got expected output"
