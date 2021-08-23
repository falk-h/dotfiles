#!/bin/bash
set -euo pipefail

# shellcheck source=bash/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/bash/lib.sh"

usage() {
    cat << EOF
Usage:
    $(script_name) [REMOTE]

Pushes changes from the local branch and main to the REMOTE. With no REMOTE,
pushes to origin. If there is no local branch (i.e. the local branch is main),
only main is pushed.
EOF
}

# Gets the url of the given remote for the current branch and filters out
# everything except the 'user/repo' part.
remote_repo_name() {
    local remote=$1
    git remote get-url --push "$remote" \
        | head -n 1 \
        | sed -e 's/^.*://' -e 's/\.git$//'
}

main() {
    # Split into multiple [[ invocations so bash doesn't complain about $1 being
    # undefined when the script is called with zero arguments.
    if [[ $# -gt 0 ]] && [[ $1 == -h || $1 == --help || $# -gt 1 ]]; then
        usage
        exit
    fi

    # Make sure we're in the repo.
    cd_to_repo_root

    declare local_branch
    local_branch=$(current_branch)

    declare remote="${1:-origin}"
    info \
        "Pushing $local_branch to $remote ($(remote_repo_name "$remote"))"
    git push "$remote"

    if ! on_main; then
        info 'Switching to main'
        git switch main

        info "Pushing main to $remote ($(remote_repo_name "$remote"))"
        git push "$remote"

        info "Switching back to $local_branch"
        git switch "$local_branch"
    fi

    echo
    info "All done!"
}

main "$@"
