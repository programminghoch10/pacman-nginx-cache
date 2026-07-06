FROM docker.io/nginx

# disable default nginx page
COPY <<EOF /etc/nginx/conf.d/default.conf
EOF

# setup nginx dns resolvers
COPY --chmod=554 <<EOF /docker-entrypoint.d/16-resolvers.sh
#/bin/sh
grep '^nameserver' < /etc/resolv.conf \
    | cut -d' ' -f2 \
    | tr '\n' ' ' \
    | sed 's/^\(.*\)$/resolver \1;\n/' \
    > /etc/nginx/conf.d/resolvers.conf
EOF

COPY mirror.template /docker-entrypoint.d/
COPY --chmod=554 setup-mirrors.sh /docker-entrypoint.d/90-setup-mirrors.sh
