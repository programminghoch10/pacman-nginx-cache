FROM docker.io/nginx

# disable default nginx page
COPY <<EOF /etc/nginx/conf.d/default.conf
EOF
