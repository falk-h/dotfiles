#!/bin/bash
set -euo pipefail

# Returns true if running in CI
in_ci() {
    [[ -v CI ]] && [[ $CI == true ]]
}

print_colored() {
    declare color=$1
    shift

    declare -rA COLORS=(
        [black]=0
        [red]=1
        [green]=2
        [yellow]=3
        [blue]=4
        [purple]=5
        [cyan]=6
        [light_gray]=7
        [gray]=8
        [bright_red]=9
        [bright_green]=10
        [bright_yellow]=11
        [bright_blue]=12
        [bright_purple]=13
        [bright_cyan]=14
        [white]=15
    )

    declare -a tput_args=(setaf "${COLORS[$color]}")

    tput "${tput_args[@]}"
    echo "$@"
    tput sgr0
}

# Fancy colored printing
print_fancy() {
    declare gh_actions_command=$1
    declare arrow_color=$2
    declare text_color=$3
    shift 3
    if in_ci; then
        echo "::$gh_actions_command::" "$@"
    else
        print_colored "$arrow_color" -n '>> '
        print_colored "$text_color" "$@"
    fi
}

# Prints a debug message
debug() {
    print_fancy debug light_gray dark_gray 'Debug:' "$@"
}

# Print an informational message
info() {
    print_fancy notice blue light_gray "$@"
}

# Print a warning
warn() {
    print_fancy warning red bright_yellow 'Warning:' "$@"
}

# Print an error message
error() {
    print_fancy error red bright_red 'Error:' "$@"
}

# Fail with an error message
fail() {
    error "$@"
    exit 1
}

# Changes directory to the repo root
cd_to_repo_root() {
    cd "$(dirname "${BASH_SOURCE[-1]}")" # First change to the directory the script is in
    cd "$(git rev-parse --show-toplevel)" # Then ask git for the repo root
}

# Gets the currently checked out branch
current_branch() {
    git branch --show-current
}

# Returns 0 if main is currently checked out
on_main() {
    local branch
    branch=$(current_branch)
    if [[ $branch == main ]]; then
        return 0
    else
        return 1
    fi
}

# The script's name
script_name() {
    basename "${BASH_SOURCE[-1]}"
}

# Timestamp for stash messages
timestamp() {
    date +'%F %X'
}

# Gets the subject of the latest commit on a branch
commit_subject() {
    local branch=$1
    git log --format=format:%s --max-count 1 "$branch"
}

# Prints "true" if there are no changed or untracked files in the repo,
# otherwise prints "false"
repo_clean() {
    if [[ -z $(git status --porcelain=v1) ]]; then
        echo true
    else
        echo false
    fi
}
