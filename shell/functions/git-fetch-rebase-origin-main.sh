#!/bin/bash
# -*- mode: shell-script -*-

.git_fetch_rebase_origin_main() {
    local doc="Fetch the latest changes on 'main' and then rebase the current branch
onto them.

usage: .git_fetch_rebase_origin_main() [branch]"
    local branch

    if [[ "$1" == "-h" ]]; then
        echo "$doc"
        return 0
    elif [[ "$1" == "-s" ]]; then
        declare -f "${FUNCNAME[0]}"
        return 0
    fi

    if [[ -n "$1" ]]; then
        branch="$1"
    else
        branch="main"
    fi

    git fetch origin "$branch":"$branch" &&
    git rebase origin/"$branch"
}
