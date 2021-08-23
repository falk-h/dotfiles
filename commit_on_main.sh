#!/bin/bash
set -euo pipefail

# shellcheck source=bash/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/bash/lib.sh"

usage() {
    cat << EOF
Usage:
    $(script_name) [FILES...]

Commits unstaged changes in FILES on main, and merges them back into the local
brach. With no FILES, commits all unstaged changes.

Make some changes on the local branch, then run this script. Follow up with
./push_all_changes.sh to push everything.
EOF
}

main() {
    # Split into two [[ invocations so bash doesn't complain about $1 being
    # undefined when the script is called with zero arguments.
    if [[ $# -gt 0 ]] && [[ $1 == -h || $1 == --help ]]; then
        usage
        exit
    fi

    # Make sure we're in the repo.
    cd_to_repo_root

    declare local_branch
    local_branch=$(current_branch)

    if on_main; then
        error "You're already on main!"
        fail "Just use git directly"
    fi

    declare -a files
    if [[ $# -eq 0 ]]; then
        # Since we're in the repo root, `.` means the entire repo.
        files=(.)
        info 'Stashing all files'
    else
        files=("$@")
        info 'Stashing' "${files[@]}"
    fi
    git stash push -u -m "Stash for merging into main at $(timestamp)" -- "${files[@]}"

    info 'Switching to main'
    git switch main

    info 'Popping the stash'
    if ! git stash pop; then
        echo
        error 'Popping the stash failed!'
        echo
        info 'Fix the merge conflicts'
        info 'git commit'
        info "git switch $local_branch"
        info './merge_main.sh'
        exit 1
    fi

    info 'Adding the files'
    git add -- "${files[@]}"

    info 'Committing'
    git commit

    info "Switching back to $local_branch"
    git switch "$local_branch"

    info 'Merging main'
    if ! git merge -m "Automatic merge of '$(commit_subject main)' by $(script_name)" main; then
        echo
        error 'Merging failed!'
        echo
        info 'Fix the merge conflicts'
        info 'git merge --continue'
        exit 1
    fi

    echo
    info 'All done!'
}

main "$@"
