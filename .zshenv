#!/bin/sh
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

for editor in nvim vim vi nano; do
    which "$editor" > /dev/null 2>&1 && export EDITOR="$editor" && break
done
export VISUAL="$EDITOR"

for browser in firefox-developer-edition firefox firefox-beta chromium w3m elinks links lynx; do
    which "$browser" > /dev/null 2>&1 && export BROWSER="$browser" && break
done
