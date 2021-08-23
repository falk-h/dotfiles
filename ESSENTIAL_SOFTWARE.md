# Essential software

This is a (work in progress) list of all the programs that are required for the
dotfiles to fully work. This should make setup on a new computer a bit easier.

## Package manager

- ccls
- chktex
- clang-format
- firefox
- gdb
- go
- neovim
- nodejs
- npm
- pip
- rstcheck
- rustup
- shellcheck
- tidy
- tmux
- yamllint
- zoxide
- zsh

### If available, otherwise via Cargo

- alacritty
- bat
- rust-analyzer
- selene
- stylua
- taplo (with --features=lsp)

### If available, otherwise via Go

- actionlint (github.com/rhysd/actionlint/cmd/actionlint@latest)
- fzf
- gopls (golang.org/x/tools/gopls@latest)
- shfmt (github.com/mvdan/sh/cmd/shfmt@latest)

### If available, otherwise via NPM

- @fsouza/prettierd
- markdownlint-cli
- jsonlint

### If available, otherwise from source

- bashls
- dockerls

## Rustup

Both stable and nightly, for nightly rustfmt. Also `rustup component add
rust-src`.

## Cargo

- cargo-audit
- cargo-binutils
- cargo-update
- cargo-watch
- cargo-whatfeatures
- exa
- fd-find
- git-delta
- ripgrep
- tokei

## Pip

- pynvim
- pyright
- cmakelang
- sqlfluff

## GNOME plugins

- Dash to Panel
- Nothing to say
- Window Is Ready - Notification Remover
