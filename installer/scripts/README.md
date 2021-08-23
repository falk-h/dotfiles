# Install scripts

Scripts in this directory are executed by the installer after it has initialized
the git submodules and linked the dotfiles to the home directory. They are
executed in the root directory of this repository, and are passed the path to
the directory in the repository that contains the dotfiles (e.g.
`~/dotfiles/files`) as a command line argument.

Scripts can be written in any programming language as long as they have the
appropriate shebang and are marked as executable (`chmod +x`).

A script can print output to stdout and warnings to stderr. The script inherits
stdin from the installer process.

If a fatal error occurs, the script should exit with a non-zero return code.
Scripts should succeed even if they have already been run. For example, if a
script installs some program, it should not return an error if that program is
already installed.
