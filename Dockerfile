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

# increase worker connections
COPY --chmod=554 <<EOF /docker-entrypoint.d/35-worker-connections.sh
#/bin/sh
sed -i 's/worker_connections \+[0-9]\+ *;/worker_connections 4096;/' /etc/nginx/nginx.conf
EOF

COPY mirror.template /docker-entrypoint.d/
COPY --chmod=554 setup-mirrors.sh /docker-entrypoint.d/90-setup-mirrors.sh

COPY nginx.conf /etc/nginx/conf.d/cacheserver.conf
