#!/bin/zsh
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

if which rustup &> /dev/null; then
    export MANPATH="$(rustup toolchain list -v | grep '(default)' | cut -f 2)/share/man:${MANPATH:-$(manpath)}"
fi

for editor in nvim vim vi nano; do
    which "$editor" &> /dev/null && export EDITOR="$editor" && break
done
export VISUAL="$EDITOR"

for browser in firefox-developer-edition firefox firefox-beta chromium w3m elinks links lynx; do
    which "$browser" &> /dev/null && export BROWSER="$browser" && break
done
