#!/bin/sh

# Clean up the spell files
vim -c 'runtime spell/cleanadd.vim'

# Don't forget to add the modified spell files to our commit
dotfiles add "$HOME/.vim/spell"
