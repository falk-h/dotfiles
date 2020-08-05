#!/bin/sh
set -eu

dotfile_dir="$HOME/.dotfiles"
backup_dir="$dotfile_dir-backup"

dotfiles() {
    git --git-dir="$dotfile_dir" --work-tree="$HOME" "$@"
}

# Ensure we have git, etc. This might be a bit excessive.
for cmd in git xargs grep awk vim; do
    if ! command -v "$cmd" > /dev/null 2>&1; then
        printf "Couldn't find %s\n" "$cmd"
        exit 1
    fi
done

if [ -e "$dotfile_dir" ]; then
    printf "%s already exists\n" "$dotfile_dir"
    exit 1
fi

printf "Cloning repo...\n"
git clone --bare git@github.com:falk-h/dotfiles.git "$dotfile_dir"
dotfiles submodule update --init --recursive

# Ignore untracked files in $HOME
dotfiles config --local status.showUntrackedFiles no

if ! dotfiles checkout; then
    printf "Checkout failed, backing up existing dotfiles to %s...\n" "$backup_dir"

    if [ -e "$backup_dir" ]; then
        printf "%s already exists\n" "$backup_dir"
        exit 1
    fi

    mkdir -p "$backup_dir"
    files=$(dotfiles checkout 2>&1 | grep -E -e "\s+\." -e "\s+README.md" | awk '{print $1}')
    for file in $files; do
        mkdir -p "$dotfile_dir/$(dirname $file)"
	mv "$file" "$dotfile_dir/$file"
    done

    printf "Checking out again...\n"
    if ! dotfiles checkout; then
        printf "Checkout failed again, you're on your own\n"
	exit 1
    fi
fi

# Install pre-commit hook
ln -s "$HOME/.clean-spell-hook.sh" "$dotfile_dir/hooks/pre-commit"

printf "Done!\n"
