#!/bin/sh
sed -i 's/worker_connections \+[0-9]\+ *;/worker_connections 4096;/' /etc/nginx/nginx.conf
