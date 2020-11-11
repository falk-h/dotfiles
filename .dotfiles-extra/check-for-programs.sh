#!/bin/bash
# Simple script to check if all my usual programs are installed.

set -uo pipefail

cd "$(dirname "$0")" || exit 1

# shellcheck disable=1091
source utils.sh

programs=(
    vim
    ssh
    git
    fzf
    rg
    docker
    docker-compose
    node
    npm
)

check_commands "${programs[@]}"
