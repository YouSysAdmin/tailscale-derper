#!/usr/bin/env bash

cat <<EOF

==========================================
Start Tailscale DERP Server
Version: $(/derper/derper -version | sed 's/-.*$//g')
Bind Addr: $DERP_ADDR
HTTP Port: $(if [ $DERP_HTTP_PORT != -1 ]; then echo -n "$DERP_HTTP_PORT"; else echo -n "Disabled"; fi)
DERP Enabled: $DERP_DERP_ENABLE
STUN Enabled: $DERP_STUN_ENABLE
STUN Port: $DERP_STUN_PORT
==========================================

EOF

pid=0

# SIGUSR1, SIGINT
user_term() {
    echo "The Tailscale DERP Server is stopped"
    if [ $pid -ne 0 ]; then
      kill -TERM "$pid"
      wait "$pid"
    fi
    exit 0;
}

# SIGTERM
sigterm() {
  echo "The Tailscale DERP Server is stopped"
  if [ $pid -ne 0 ]; then
    kill -SIGTERM "$pid"
    wait "$pid"
  fi
  exit 143; # 128 + 15 -- SIGTERM
}

trap 'kill ${!}; user_term' SIGUSR1 SIGINT
trap 'kill ${!}; sigterm' SIGTERM

/derper/derper \
    --a="$DERP_ADDR" \
    --accept-connection-burst="$DERP_ACCEPT_CONNECTION_BURST" \
    --accept-connection-limit="$DERP_ACCEPT_CONNECTION_LIMIT" \
    --bootstrap-dns-names="$DERP_BOOTSTRAP_DNS_NAMES" \
    --c="$DERP_CONFIG_FILE" \
    --certdir="$DERP_CERT_DIR" \
    --certmode="$DERP_CERT_MODE" \
    --derp="$DERP_DERP_ENABLE" \
    --dev="$DERP_DEV_MODE" \
    --home="$DERP_HOME_PAGE" \
    --hostname="$DERP_HOSTNAME" \
    --http-port="$DERP_HTTP_PORT" \
    --mesh-psk-file="$DERP_MESH_PSK_FILE" \
    --mesh-with="$DERP_MESH_WITH" \
    --secrets-cache-dir="$DERP_SECRETS_CACHE_DIR" \
    --secrets-path-prefix="$DERP_SECRETS_PATH_PREFIX" \
    --secrets-url="$DERP_SECRETS_URL" \
    --socket="$DERP_SOCKET" \
    --stun-port="$DERP_STUN_PORT" \
    --stun="$DERP_STUN_ENABLE" \
    --tcp-keepalive-time="$DERP_TCP_KEEPALIVE_TIME" \
    --tcp-user-timeout="$DERP_TCP_USER_TIMEOUT" \
    --tcp-write-timeout="$DERP_TCP_WRITE_TIMEOUT" \
    --unpublished-bootstrap-dns-names="$DERP_UNPUBLISHED_BOOTSTRAP_DNS_NAMES" \
    --verify-client-url-fail-open="$DERP_VERIFY_CLIENT_URL_FAIL_OPEN" \
    --verify-client-url="$DERP_VERIFY_CLIENT_URL" \
    --verify-clients="$DERP_VERIFY_CLIENTS"


if [ $? != 0 ]; then
  sigterm
fi

pid="$!"

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
