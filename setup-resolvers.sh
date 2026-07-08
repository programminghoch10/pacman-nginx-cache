#!/bin/sh
grep '^nameserver' < /etc/resolv.conf \
    | cut -d' ' -f2 \
    | tr '\n' ' ' \
    | sed 's/^\(.*\)$/resolver \1;\n/' \
    > /etc/nginx/conf.d/resolvers.conf
