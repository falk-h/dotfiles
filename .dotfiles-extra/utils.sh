#!/bin/bash

# Ask a yes/no question with $1 ('y'/'n') as the default.
yesno() {
    default=

    if [ "$1" = "y" ]; then
        default=0
    elif [ "$1" = "n" ]; then
        default=1
    else
        echo "Invalid argument to $0: '$1'"
        exit 1
    fi

    while true; do
        answer=
        if [ "$1" = "y" ]; then
            read -r -n 1 -p "$2 [Y/n] " answer
        elif [ "$1" = "n" ]; then
            read -r -n 1 -p "$2 [y/N] " answer
        fi
        case $answer in
            "") return $default ;;
            [Yy])
                return 0
                echo >&2
                ;;
            [Nn])
                return 1
                echo >&2
                ;;
        esac
    done
}

# Show a message ($1) and try a given command. Return its output if it fails.
try() {
    red="$(tput setaf 1)"
    green="$(tput setaf 2)"
    reset="$(tput sgr0)"

    printf "%s..." "$1" >&2
    shift
    if err="$("$@" 2>&1)"; then
        echo "$green Done!$reset" >&2
        return 0
    else
        echo "$red FAILED!$reset" >&2
        echo "$err"
        return 1
    fi
}

check_commands() {
    for cmd in "$@"; do
        if ! try "Checking for $cmd" command -v "$cmd" > /dev/null; then
            return 1
        fi
    done
}
