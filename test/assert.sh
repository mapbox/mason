#!/usr/bin/env bash

function assertEqual() {
    if [ "$1" == "$2" ]; then
        echo "ok - $1 ($3)"
    else
        echo "not ok - $1 != $2 ($3)"
        CODE=1
    fi
}

function assertContains() {
    if [[ "$1" =~ "$2" ]]; then
        echo -e "\033[1m\033[32mok\033[0m - Found string $2 in output ($3)"
    else
        echo -e "\033[1m\033[31mnot ok\033[0m - Did not find string '$2' in '$1' ($3)"
        CODE=1
    fi
}
