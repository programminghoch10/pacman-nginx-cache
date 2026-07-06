#!/bin/sh

podman build \
    --pull=newer \
    --tag=pacman-nginx-cache \
    .

exec \
podman run \
    --interactive \
    --tty \
    localhost/pacman-nginx-cache \
    "$@"
