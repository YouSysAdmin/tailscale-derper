![](doc/ops-duck-wide-890px.png)

# Dockerized Tailscale DERP server

A new version is automatically created, if exists, every Monday at 00:00 UTC.

Registry:
- [GitHub](https://github.com/YouSysAdmin/tailscale-derper/pkgs/container/tailscale-derper)

```shell
docker pull ghcr.io/yousysadmin/tailscale-derper:latest
```

## Usage

Official DERP documentation: https://tailscale.com/kb/1118/custom-derp-servers/

### Minimal
```shell
docker run -p 80:80 -p 443:443 -p 3478:3478/udp -e DERP_HOSTNAME=derper.example.com ghcr.io/yousysadmin/tailscale-derper:latest
```

### With Client Verification
If you run DERP on a host with installed `tailscaled` you can use the client verification functionality

> Anyone that knows the IP address of your DERP server could add it to their DERP map and route their tailnet traffic through your DERP server. To allow only your tailnet traffic through your DERP server, run tailscaled on the same device as your DERP server, and start derper with the --verify-clients
> 
> [official documentation](https://tailscale.com/kb/1118/custom-derp-servers#optional-verify-client-traffic-to-the-custom-derp-server)

```shell
docker run -p 80:80 -p 443:443 -p 3478:3478/udp \
       -e DERP_HOSTNAME=derper.example.com \
       -e DERP_VERIFY_CLIENTS=true \
       -v /var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock
       ghcr.io/yousysadmin/tailscale-derper:latest
```
You can use the `DERP_SOCKET` environment variable to change the default socket path
```shell
...
docker run -p 80:80 -p 443:443 -p 3478:3478/udp \
       -e DERP_HOSTNAME=derper.example.com \
       -e DERP_VERIFY_CLIENTS=true \
       -e DERP_SOCKET=/tmp/tailscaled.sock
       -v /tmp/tailscaled.sock:/var/run/tailscale/tailscaled.sock
       ghcr.io/yousysadmin/tailscale-derper:latest
```

## Environment variables

| ENV variable                         | CLI flag                         | Default value                  | Description                                                                                                                                                                                                                                             |
|--------------------------------------|----------------------------------|--------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| DERP_ACCEPT_CONNECTION_BURST         | -accept-connection-burst         | 9223372036854775807            | burst limit for accepting new connection                                                                                                                                                                                                                |
| DERP_ACCEPT_CONNECTION_LIMIT         | -accept-connection-limit         | +Inf                           | rate limit for accepting new connection                                                                                                                                                                                                                 |
| DERP_ADDR                            | -a                               | 0.0.0.0:443                    | server HTTP/HTTPS listen address, in form ":port", "ip:port", or for IPv6 "[ip]:port". If the IP is omitted, it defaults to all interfaces. Serves HTTPS if the port is 443 and/or -certmode is manual, otherwise HTTP.                                 |
| DERP_BOOTSTRAP_DNS_NAMES             | -bootstrap-dns-names             | ""                             | optional comma-separated list of hostnames to make available at /bootstrap-dns                                                                                                                                                                          |
| DERP_CERT_DIR                        | -certdir                         | "/derper/certs"                | directory to store LetsEncrypt certs, if addr's port is :443                                                                                                                                                                                            |
| DERP_CERT_MODE                       | -certmode                        | letsencrypt                    | mode for getting a cert. possible options: manual, letsencrypt                                                                                                                                                                                          |
| DERP_CONFIG_FILE                     | -c                               | ""                             | config file path                                                                                                                                                                                                                                        |
| DERP_DERP_ENABLE                     | -derp                            | true                           | 	whether to run a DERP server. The only reason to set this false is if you're decommissioning a server but want to keep its bootstrap DNS functionality still running.                                                                                  |
| DERP_DEV_MODE                        | -dev                             | false                          | run in localhost development mode (overrides -a)                                                                                                                                                                                                        |
| DERP_HOME_PAGE                       | -home                            | "blank"                        | what to serve at the root path. It may be left empty (the default, for a default homepage), "blank" for a blank page, or a URL to redirect to                                                                                                           |
| DERP_HOSTNAME                        | -hostname                        | "example.com"                  | LetsEncrypt host name, if addr's port is :443. When --certmode=manual, this can be an IP address to avoid SNI checks                                                                                                                                    |
| DERP_HTTP_PORT                       | -http-port                       | 80                             | The port on which to serve HTTP. Set to -1 to disable. The listener is bound to the same IP (if any) as specified in the -a flag.                                                                                                                       |
| DERP_MESH_PSK_FILE                   | -mesh-psk-file                   | ""                             | if non-empty, path to file containing the mesh pre-shared key file. It should contain some hex string; whitespace is trimmed                                                                                                                            |
| DERP_MESH_WITH                       | -mesh-with                       | ""                             | optional comma-separated list of hostnames to mesh with; the server's own hostname can be in the list. If an entry contains a slash, the second part names a hostname to be used when dialing the target.                                               |
| DERP_SECRETS_CACHE_DIR               | -secrets-cache-dir               | "/derper/cache/derper-secrets" | directory to cache setec secrets in (required if --secrets-url is set)                                                                                                                                                                                  |
| DERP_SECRETS_PATH_PREFIX             | -secrets-path-prefix             | "prod/derp"                    | setec path prefix for "meshkey" secret for DERP mesh key                                                                                                                                                                                                |
| DERP_SECRETS_URL                     | -secrets-url                     | ""                             | SETEC server URL for secrets retrieval of mesh key                                                                                                                                                                                                      |
| DERP_SOCKET                          | -socket                          | ""                             | optional alternate path to tailscaled socket (only relevant when using --verify-clients)                                                                                                                                                                |
| DERP_STUN_ENABLE                     | -stun                            | true                           | whether to run a STUN server. It will bind to the same IP (if any) as the --addr flag value.                                                                                                                                                            |
| DERP_STUN_PORT                       | -stun-port                       | 3478                           | The UDP port on which to serve STUN. The listener is bound to the same IP (if any) as specified in the -a flag.                                                                                                                                         |
| DERP_TCP_KEEPALIVE_TIME              | -tcp-keepalive-time              | "10m0s"                        | TCP keepalive time                                                                                                                                                                                                                                      |
| DERP_TCP_USER_TIMEOUT                | -tcp-user-timeout                | "15s"                          | TCP user timeout                                                                                                                                                                                                                                        | 
| DERP_TCP_WRITE_TIMEOUT               | -tcp-write-timeout               | "2s"                           | TCP write timeout; 0 results in no timeout being set on writes                                                                                                                                                                                          | 
| DERP_UNPUBLISHED_BOOTSTRAP_DNS_NAMES | -unpublished-bootstrap-dns-names | ""                             | optional comma-separated list of hostnames to make available at /bootstrap-dns and not publish in the list. If an entry contains a slash, the second part names a DNS record to poll for its TXT record with a 0 to `100` value for rollout percentage. |
| DERP_VERIFY_CLIENTS                  | -verify-clients                  | false                          | verify clients to this DERP server through a local tailscaled instance                                                                                                                                                                                  |
| DERP_VERIFY_CLIENT_URL               | -verify-client-url               | ""                             | if non-empty, an admission controller URL for permitting client connections; see tailcfg.DERPAdmitClientRequest                                                                                                                                         |
| DERP_VERIFY_CLIENT_URL_FAIL_OPEN     | -verify-client-url-fail-open     | true                           | whether we fail open if --verify-client-url is unreachable (default true)                                                                                                                                                                               |
