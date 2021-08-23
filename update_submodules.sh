#!/bin/bash
set -euo pipefail

# shellcheck source=bash/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/bash/lib.sh"

usage() {
    cat << EOF
Usage:
    $(script_name) [--check] [SUBMODULES...]

Fetches and updates SUBMODULES, or all submodules if none are given.

With --check, checks if updates are available. This is intended to be used with
GitHub Actions and outputs Actions-specific warnings.
EOF
}

declare -r TAG_FETCHER='git fetch --tags'
declare -r MASTER_FETCHER='git fetch origin master'
declare -rA FETCHERS=(
    [fzf]=$TAG_FETCHER
    [zsh-autosuggestions]=$TAG_FETCHER
    [zsh-notify]=$MASTER_FETCHER
    [zsh-syntax-highlighting]=$MASTER_FETCHER
)

# Don't warn about $ in single-quoted strings.
# shellcheck disable=SC2016
declare -r TAG_UPDATER='git switch -d "$(git tag | grep -v rc | sort -Vr | head -n 1)"'
declare -r MASTER_UPDATER='git rebase origin/master master'
declare -rA UPDATERS=(
    [fzf]=$TAG_UPDATER
    [zsh-autosuggestions]=$TAG_UPDATER
    [zsh-notify]=$MASTER_UPDATER
    [zsh-syntax-highlighting]=$MASTER_UPDATER
)

main() {
    # Split into two [[ invocations so bash doesn't complain about $1 being
    # undefined when the script is called with zero arguments.
    if [[ $# -gt 0 ]] && [[ $1 == -h || $1 == --help ]]; then
        usage
        exit
    fi
    declare check=false
    if [[ $# -gt 0 ]] && [[ $1 == --check ]]; then
        check=true
        shift
    fi

    # Make sure we're in the submodules dir.
    cd_to_repo_root
    cd submodules

    declare -a submodules=()
    if [[ $# -gt 0 ]]; then
        submodules=("$@")

        declare fail=false
        for submodule in "${submodules[@]}"; do
            if ! [[ -d $submodule ]]; then
                fail=true
                warn "$submodule is not a submodule"
            fi
        done
        if [[ $fail == true ]]; then
            fail 'Nonexistent submodules were specified!'
        fi
    else
        readarray -d '' submodules \
            < <(find . -maxdepth 1 -mindepth 1 -type d -print0 \
                | sed -z 's;^\./;;')
    fi

    declare all_ok=true
    for submodule in "${submodules[@]}"; do
        if ! [[ -v "UPDATERS[$submodule]" && -v "FETCHERS[$submodule]" ]]; then
            error "Don't know how to update $submodule!"
            all_ok=false
            continue
        fi

        pushd "$submodule" > /dev/null

        declare fetch_command=${FETCHERS[$submodule]}
        info "Fetching updates for $submodule with \`$fetch_command\`"
        eval "$fetch_command"

        declare update_command=${UPDATERS[$submodule]}
        info "Updating $submodule with \`$update_command\`"
        eval "$update_command"

        popd > /dev/null
    done

    declare -a grep_args=(-o -z -Z)
    for submodule in "${submodules[@]}"; do
        grep_args+=(-e "$submodule")
    done

    declare -a updated=()
    readarray -d '' updated < <(git status . -z | grep "${grep_args[@]}")

    if [[ ${#updated[@]} -gt 0 ]]; then
        if [[ $check == true ]]; then
            for submodule in "${updated[@]}"; do
                echo -n "::warning file=submodules/$submodule"
                echo "::$submodule submodule can be updated"
            done
        else
            info "Updated ${updated[*]}"
            info "Make sure to commit the updates!"
        fi
    else
        info "Submodules are already up to date"
    fi

    if [[ $all_ok == false ]]; then
        fail "Failed to update one or more submodules!"
    fi
}

main "$@"
