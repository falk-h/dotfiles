#!/bin/sh
set -eu

link=/usr/share/X11/xkb/symbols/custom

if [ -h "$link" ]; then
    echo "$link is already a symbolic link, not linking anything" >&2
elif [ -e "$link" ]; then
    echo "$link already exists, but isn't a symbolic link" >&2
    exit 1
else
    target="$HOME/.config/xkb/symbols/svdvorak_a5"
    sudo ln -s "$target" "$link"
    echo "Created symlink $link → $target"
fi
