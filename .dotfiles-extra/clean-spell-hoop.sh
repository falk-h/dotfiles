#!/bin/sh

# Clean up the spell files
vim -E -c 'runtime spell/cleanadd.vim' -c 'quitall!'

# Don't forget to add the modified spell files to our commit
git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" add "$HOME/.vim/spell"
