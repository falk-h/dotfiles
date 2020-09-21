#!/bin/sh
export PATH="$HOME/bin:$PATH"

for editor in vim nvim vi nano; do
    which "$editor" > /dev/null 2>&1 && export EDITOR="$editor" && break
done
export VISUAL="$EDITOR"

for browser in firefox-developer-edition firefox firefox-beta w3m elinks links lynx; do
    which "$browser" > /dev/null 2>&1 && export BROWSER="$browser" && break
done
