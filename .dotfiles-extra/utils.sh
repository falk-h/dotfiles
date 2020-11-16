#!/bin/sh

# Ask a yes/no question with $1 ('y'/'n') as the default.
yesno() {
    default=
    prompt="$2"
    if [ "$1" = y ]; then
        default=0
        prompt="$prompt [Y/n] "
    elif [ "$1" = n ]; then
        default=1
        prompt="$prompt [y/N] "
    else
        echo "Invalid argument to $0: '$1'"
        exit 1
    fi

    while true; do
        answer=
        printf "%s" "$prompt"
        read -r answer
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
    red=
    green=
    reset=
    if type tput > /dev/null 2>&1; then
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        reset="$(tput sgr0)"
    fi

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

# Checks wether the given executables exist.
check_commands() {
    for cmd in "$@"; do
        try "Checking for $cmd" command -v "$cmd" > /dev/null || return 1
    done
}
