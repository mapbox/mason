#!/usr/bin/env bash

CODE=0

source $(dirname $0)/assert.sh

function finish {
  rm -rf ./scripts/unbound_var
}

trap finish EXIT

mkdir -p ./scripts/unbound_var/0.0.0
cp -r $(dirname $0)/fixtures/broken-packages/unbound_var.sh ./scripts/unbound_var/0.0.0/script.sh

./mason build unbound_var 0.0.0

assertEqual "$?" "1" "errors on unbound variable"

