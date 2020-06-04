#!/bin/bash
set -euxo pipefail

# Check if a stale pid file exists
if [ -f "/var/run/nginx.pid" ]; then
    rm "/var/run/nginx.pid"
fi

case "$TLS_FLAVOR" in
  "letsencrypt" | "mail-letsencrypt")
    /letsencrypt.py
    ;;
  "mail" | "cert")
    /certwatcher.py
    ;;
esac

/config.py

exec /usr/sbin/nginx -g "daemon off;"

