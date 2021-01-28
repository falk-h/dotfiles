#!/bin/zsh
# User binaries and things installed with cargo and PIP
export PATH="$HOME/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

# APT user config
export APT_CONFIG="$HOME/.apt.conf"

# Manpages for crates installed via cargo
if which rustup &> /dev/null; then
    export MANPATH="$(rustup toolchain list -v | grep '(default)' | cut -f 2)/share/man:${MANPATH:-$(manpath)}"
fi

for editor in nvim vim vi nano; do
    which "$editor" &> /dev/null && export EDITOR="$editor" && break
done
export VISUAL="$EDITOR"

for browser in x-www-browser firefox-developer-edition firefox firefox-beta chromium w3m elinks links lynx; do
    which "$browser" &> /dev/null && export BROWSER="$browser" && break
done
