# Dotfiles

These are my dotfiles.

## Installation

Generate up an SSH key for the computer:

```sh
ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub
```

Then [add it to GitHub](https://github.com/settings/ssh/new).

Clone this repo to `~/dotfiles`:

```sh
git clone git@github.com:falk-h/dotfiles.git ~/dotfiles
```

Note that the repo **must** be cloned to `~/dotfiles` as some things
unfortunately depend on knowing the absolute path to the repo.

Install symlinks in $HOME:

```sh
cargo run -- install
```

## Making changes

The procedure for making changes depends on whether the computer is using the
`main` branch or has its own local branch.

### When the current computer is on `main`

```sh
# Make changes...

git add files/...
git commit
# Repeat as needed...

git push
```

### When the current computer has its own branch

If the changes are only for this computer, the procedure is the same as above.
If the changes should be included in `main`, do as follows:

```sh
# Make changes...

./commit_on_main.sh files/...  # Repeat as needed...

./push_all_changes.sh
```

### Merging `main` into a local branch

This applies when changes have been added to `main` and need to be merged into a
computer's local branch.

```sh
./merge_main.sh
```

Licensed under the [3-clause BSD license](LICENSE.md). Submodules under
[`.dotfiles-submodules/`](./.submodules/) are licensed under their respective
licenses.
