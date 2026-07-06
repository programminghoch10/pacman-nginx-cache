#!/bin/sh

podman build \
    --pull=newer \
    --tag=pacman-nginx-cache \
    .

exec \
podman run \
    --interactive \
    --tty \
    --publish 8080:80 \
    --mount type=bind,src=/etc/pacman.conf,dst=/etc/pacman.conf,ro \
    --mount type=bind,src=/etc/pacman.d,dst=/etc/pacman.d,ro \
    --mount type=tmpfs,dst=/var/www/cache,notmpcopyup \
    localhost/pacman-nginx-cache \
    "$@"
