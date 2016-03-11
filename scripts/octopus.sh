#!/usr/bin/env bash

set -eu
set -o pipefail

MERGE_BRANCH=$(git rev-parse --abbrev-ref HEAD)

BRANCHES=$(git for-each-ref --sort=-committerdate refs/remotes --format='%(refname:short)')
BRANCHES=${BRANCHES[@]//origin\//}

for BRANCH in ${BRANCHES[@]}; do
    if [[ $BRANCH = $MERGE_BRANCH || ! $BRANCH =~ "-" ]]; then
        echo "Skipping branch '$BRANCH' (does not look like a package as it lacks a dash)"
        BRANCHES=(${BRANCHES[@]/$BRANCH})
        continue
    fi

    git branch -D $BRANCH || true
    git checkout -b $BRANCH origin/$BRANCH

    if [[ ! -f script.sh ]]; then
        echo "Skipping branch '$BRANCH' (does not have script.sh)"
        BRANCHES=(${BRANCHES[@]/$BRANCH})
        continue
    fi

    eval $(grep BOOST_VERSION1= script.sh)
    eval $(grep BOOST_LIBRARY= script.sh)
    eval $(grep MASON_NAME= script.sh)
    eval $(grep MASON_VERSION= script.sh)

    mkdir -p scripts/${MASON_NAME}/${MASON_VERSION}
    git mv -v -k .travis.yml *.* scripts/${MASON_NAME}/${MASON_VERSION}
    git commit -a -m "Preparing for octopus merge"
done

git checkout $MERGE_BRANCH
git merge --no-commit --strategy ours ${BRANCHES[@]}

for BRANCH in ${BRANCHES[@]}; do
    git checkout $BRANCH -- scripts
done

git commit -m "Octopus merge"
