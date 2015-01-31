#!/usr/bin/env bash

set -eu
set -o pipefail

function usage() {
    echo "Usage:"
    echo ""
    echo "./scripts/rebuild.sh [package names]"
    echo ""
    echo "Please pass a space separated list of package names like:"
    echo ""
    echo "    ./scripts/rebuild.sh libuv-0.10.28 libuv-0.11.29"
    echo ""
    echo "You can also use shell globbing to update all libuv versions like:"
    echo ""
    echo "    ./scripts/rebuild.sh libuv-*"
    echo ""
    echo "Or pass the keyword 'all' to rebuild all known packages"
    echo ""
    echo "    ./scripts/rebuild.sh all"
    echo ""
    exit 1

}
if [[ ${@:-unset} == "unset" ]] || [[ $@ == '-h' ]] || [[ $@ == '--help' ]]; then
    usage
fi

. ${MASON_DIR:-~/.mason}/mason.sh

for b in $(git for-each-ref --sort=-committerdate refs/remotes --format='%(refname:short)'); do
    NAME=$(basename $b)
    if [[ ! $NAME =~ "-" ]]; then
        mason_substep "Skipping branch '$NAME' (does not look like a package as it lacks a dash)"
        continue
    fi
    if [[ "$@" == "all" ]]; then
        mason_step "Rebuilding $NAME"
        (cd $NAME && git commit --allow-empty -m "rebuild" && git push && mason_success "requested rebuild of $NAME")
    elif [[ "$@" =~ "$NAME" ]]; then
        echo "yes, found $NAME"
        if [[ ! -d $NAME ]]; then
            mason_step  "Skipping package '$NAME' since it has not been cloned locally (run ./scripts/fetch.sh)"
        else
            mason_step "Rebuilding $NAME"
            (cd $NAME && git commit --allow-empty -m "rebuild" && git push && mason_success "requested rebuild of $NAME")
        fi
    fi
done
