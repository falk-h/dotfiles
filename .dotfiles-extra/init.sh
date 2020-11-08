#!/bin/bash
set -eu

hoster="github.com"
repo="falk-h/dotfiles"
dotfile_dir="$HOME/.dotfiles"
extra_dir="$dotfile_dir-extra"
backup_dir="$dotfile_dir-backup"
dotfiles() {
    git --git-dir="$dotfile_dir" --work-tree="$HOME" "$@"
}

get_url() {
    url="$([ -f "$HOME/.ssh/id_rsa" ] && echo 'git@github.com:falk-h/dotfiles.git' || echo 'https://github.com/falk-h/dotfiles.git')"
    if try "Checking for SSH key" [ -f "$HOME/.ssh/id_rsa" ] > /dev/null; then
        if try "Checking if the key works" ssh -T "git@$hoster" > /dev/null; then
            echo "git@$hoster:$repo.git"
            return
        fi
    fi

    echo "  Using HTTPS instead..." >&2
    echo "https://$hoster/$repo.git"
}

# shellcheck disable=1090
source "$(dirname "$0")/utils.sh"

# Ensure we have git, etc. This might be a bit excessive.
check_commands grep awk xargs ssh git vim

url="$(get_url)"

# Ensure $dotfile_dir doesn't already exist.
if ! try "Checking for dotfile directory" [ ! -e "$dotfile_dir" ] > /dev/null; then
    if yesno n "Dotfile directory $dotfile_dir already exists. Overwrite?"; then
        rm -r "$dotfile_dir"
    else
        exit 1
    fi
fi

cd

try "Cloning from $url" git clone --bare "$url" "$dotfile_dir"
try "Fetching submodules" dotfiles submodule update --init --recursive
try "Ignoring untracked files in ~/" dotfiles config --local status.showUntrackedFiles no

if ! try "Checking out" dotfiles checkout > /dev/null; then
    echo "  Backing up existing dotfiles to $backup_dir..." >&2
    if try "  Creating backup directory" [ -e "$backup_dir" ] > /dev/null; then
        if yesno n "  Backup directory $backup_dir already exists. Overwrite?"; then
            rm -r "$backup_dir"
        else
            exit 1
        fi
    fi

    mkdir -p "$backup_dir"
    files=$(dotfiles checkout 2>&1 | grep -E -e "\s+\." -e "\s+README.md" | awk '{print $1}')
    for file in $files; do
        mkdir -p "$dotfile_dir/$(dirname "$file")"
	mv "$file" "$dotfile_dir/$file"
    done

    if ! try "  Checking out again..." dotfiles checkout; then
	exit 1
    fi
fi

try "Installing pre-commit hook" ln -s "$extra_dir/clean-spell-hook.sh" "$dotfile_dir/hooks/pre-commit"
echo "$(tput setaf 2)All Done!$(tput sgr0)"
