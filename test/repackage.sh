#!/usr/bin/env bash

set -euo pipefail

while read PACKAGE; do
    rm -rf "${PACKAGE}.tar.gz"
    >&2 echo "Repackaging ${PACKAGE}.tar.gz"
    tar czf "${PACKAGE}.tar.gz" -C "${PACKAGE}" .
done < <(find test/packages -mindepth 3 -maxdepth 3 -type d)
