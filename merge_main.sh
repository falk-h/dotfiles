#!/bin/bash
set -euo pipefail

# shellcheck source=bash/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/bash/lib.sh"

usage() {
    cat << EOF
Usage:
    $(script_name)

Merges new changes on main into the local branch. This will stash any uncommited
changes on the local branch and unstash after merging.
EOF
}

main() {
    # Don't check for --help/-h since this script doesn't take any arguments
    # anyway.
    if [[ $# -gt 0 ]]; then
        usage
        exit
    fi

    # Make sure we're in the repo.
    cd_to_repo_root

    declare local_branch
    local_branch=$(current_branch)

    if on_main; then
        error "You're already on main!"
        error "Just use git directly"
        echo
        usage
        exit 1
    fi

    declare skip_stash
    skip_stash=$(repo_clean)
    if [[ $skip_stash == 'false' ]]; then
        info 'Stashing all files'
        git stash push -u -m "Stash for merging main into $local_branch at $(timestamp)"
    fi

    info 'Switching to main'
    git switch main

    info 'Pulling'
    git pull --rebase

    info "Switching back to $local_branch"
    git switch "$local_branch"

    info 'Merging main'
    if ! git merge -m "Automatic merge of '$(commit_subject main)' by $(script_name)" main; then
        echo
        error 'Merging failed!'
        echo
        info 'Fix the merge conflicts'
        info 'git merge --continue'
        info 'git stash pop'
        exit 1
    fi

    if [[ $skip_stash == 'false' ]]; then
        info 'Popping the stash'
        if ! git stash pop; then
            echo
            error 'Popping the stash failed!'
            echo
            info 'Fix the merge conflicts'
            info 'git reset'
            info 'git stash drop'
            exit 1
        fi
    fi

    echo
    info 'All done!'
}

main "$@"
