FROM docker.io/nginx

# disable default nginx page
COPY <<EOF /etc/nginx/conf.d/default.conf
EOF

# setup nginx dns resolvers
COPY --chmod=554 setup-resolvers.sh /docker-entrypoint.d/16-setup-resolvers.sh

# increase worker connections
COPY --chmod=554 setup-worker-connections.sh /docker-entrypoint.d/35-worker-connections.sh

COPY mirror.template /docker-entrypoint.d/
COPY --chmod=554 setup-mirrors.sh /docker-entrypoint.d/90-setup-mirrors.sh

COPY nginx.conf /etc/nginx/templates/cacheserver.conf.template
ENV NGINX_ENVSUBST_FILTER="^CACHE_|^CONNECT_TIMEOUT$"

ENV \
    CONNECT_TIMEOUT=10s \
    CACHE_TIMEOUT=365d \
    CACHE_MIN_FREE=4G \
    CACHE_MAX_SIZE=32G
