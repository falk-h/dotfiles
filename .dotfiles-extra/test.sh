#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")" || exit 1

# shellcheck disable=1091
source utils.sh

check_commands shellcheck docker sed

if ! try 'Checking that docker works' docker ps > /dev/null; then
    echo 'Ensure that docker is running and you have the correct permssions'
fi

try 'Shellchecking scripts...' shellcheck ./*.sh

trap 'echo "You might want to run \`docker image prune --all\`"' EXIT

tests=
if [ $# -eq 0 ]; then
    tests=(dockerfiles/*.Dockerfile)
else
    tests=("$@")
fi
tests=("${tests[@]/dockerfiles\/}")
tests=("${tests[@]/\.Dockerfile}")

echo 'Building images...'
for test in "${tests[@]}"; do
    try "  Building image $test" \
        docker build \
        --tag "dotfiles-test-$test:latest" \
        --file "dockerfiles/$test.Dockerfile" .
done
echo 'Running tests...'
for test in "${tests[@]}"; do
    echo "  Running test $test..."
    docker run --rm --tty "dotfiles-test-$test:latest" | sed -e 's/^/    /'
done

try 'Removing images' docker image rm --force "dotfiles-test-$test:latest"

echo 'All tests succeeded'

