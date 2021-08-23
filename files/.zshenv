#!/bin/zsh

# User binaries, manpages and things installed with cargo and PIP
export PATH="$HOME/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

export MANPATH="$HOME/.local/share/man:$MANPATH"

# NPM stuff
export NPM_PREFIX=$HOME/.local/npm
export PATH="$PATH:$NPM_PREFIX/bin"
export MANPATH="$NPM_PREFIX/share/man:$MANPATH"

# Go stuff
export GOPATH="$HOME/.local/go"
export PATH="$PATH:$GOPATH/bin"

# Krew (package manager for kubectl)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# APT user config
export APT_CONFIG="$HOME/.apt.conf"

export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Default defmt log level
export DEFMT_LOG=debug

# Print Rust backtraces by default
export RUST_BACKTRACE=1

# Difftastic settings
export DFT_DISPLAY=side-by-side-show-both # Side by side, always show both files
export DFT_GRAPH_LIMIT=100000000 # Use all the RAM
export DFT_TAB_WIDTH=4 # Render tabs as 4 spaces

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
