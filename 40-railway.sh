#!/bin/sh
# Railway wrapper for OmniTools: nginx listens on $PORT (IPv4 and IPv6), serves an
# open /healthz for Railway's health check, and turns on HTTP basic auth only when
# both BASIC_AUTH_USERNAME and BASIC_AUTH_PASSWORD are set. Safe to run on every start.
set -eu

PORT="${PORT:-8080}"
case "$PORT" in ''|*[!0-9]*) echo "40-railway.sh: PORT must be a number, got '$PORT'" >&2; exit 1 ;; esac

AUTH_CONF=""
if [ -n "${BASIC_AUTH_USERNAME:-}" ] && [ -n "${BASIC_AUTH_PASSWORD:-}" ]; then
  case "$BASIC_AUTH_USERNAME" in *:*) echo "40-railway.sh: BASIC_AUTH_USERNAME must not contain ':'" >&2; exit 1 ;; esac
  HASH=$(printf '%s' "$BASIC_AUTH_PASSWORD" | mkpasswd -m sha-512 -s)
  [ -n "$HASH" ] || { echo "40-railway.sh: could not hash BASIC_AUTH_PASSWORD" >&2; exit 1; }
  umask 027
  printf '%s:%s\n' "$BASIC_AUTH_USERNAME" "$HASH" > /etc/nginx/.htpasswd
  chown root:nginx /etc/nginx/.htpasswd
  AUTH_CONF='auth_basic "OmniTools"; auth_basic_user_file /etc/nginx/.htpasswd;'
  echo "40-railway.sh: basic auth on for user $BASIC_AUTH_USERNAME"
elif [ -n "${BASIC_AUTH_USERNAME:-}${BASIC_AUTH_PASSWORD:-}" ]; then
  echo "40-railway.sh: set both BASIC_AUTH_USERNAME and BASIC_AUTH_PASSWORD to turn on basic auth" >&2
  exit 1
else
  rm -f /etc/nginx/.htpasswd
fi

cat > /etc/nginx/conf.d/default.conf <<CONF
server {
    listen       ${PORT};
    listen       [::]:${PORT};
    server_name  _;
    root         /usr/share/nginx/html;

    gzip on;
    gzip_types text/plain text/css application/javascript application/json image/svg+xml application/wasm;
    gzip_min_length 1024;

    location = /healthz {
        access_log off;
        default_type text/plain;
        return 200 "ok\n";
    }

    location /assets/ {
        ${AUTH_CONF}
        add_header Cache-Control "public, max-age=2592000, immutable";
        try_files \$uri =404;
    }

    location / {
        ${AUTH_CONF}
        index  index.html;
        try_files \$uri \$uri/ /index.html;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html { }
}
CONF

nginx -t -q
echo "40-railway.sh: OmniTools listening on port $PORT"
