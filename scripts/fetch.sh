#!/usr/bin/env bash

set -eu
set -o pipefail

. ${MASON_DIR:-~/.mason}/mason.sh

for b in $(git for-each-ref --sort=-committerdate refs/remotes --format='%(refname:short)'); do
    NAME=$(basename $b)
    if [[ ! $NAME =~ "-" ]]; then
        mason_substep "Skipping branch '$NAME' (does not look like a package as it lacks a dash)"
        continue
    fi
    if [[ ! -d $NAME ]]; then
        mason_step  "Cloning $NAME"
        git clone git@github.com:mapbox/mason.git -b $NAME $NAME
    else
        mason_step "Pulling and rebasing $NAME"
        (cd $NAME && git pull -q --rebase && mason_success "rebased $NAME")
    fi
done
