# Domain and HTTPS

## Automatic mode

Before installation:

1. Create an A record (and AAAA only if IPv6 is correctly routed) for the chosen domain.
2. Allow inbound TCP 80 and 443; allow UDP 443 for HTTP/3.
3. Make sure no other service occupies those ports.

Then run:

```bash
./monra install --domain monra.example.com --email admin@example.com
```

The installer sets the canonical authentication URL and activates the Caddy `public` profile. A hostname in the Caddyfile triggers automatic certificate management and HTTP-to-HTTPS redirects. Certificate state persists in `monra_caddy_data`.

## Reverse proxy already exists

Keep the default loopback installation and proxy to `127.0.0.1:5522`. Set these values in `.env` before restarting:

```env
MONRA_PUBLIC_URL=https://monra.example.com
MONRA_TRUSTED_ORIGINS=https://monra.example.com
```

Leave `MONRA_ENABLE_HTTPS=false` so the bundled Caddy does not compete for ports. Your proxy must preserve `Host`, `X-Forwarded-Proto`, and normal WebSocket upgrade headers. Terminate TLS at that proxy and restrict direct access to port 5522.

## DNS and certificate failures

Check public DNS from a different network, firewall/NAT rules, port ownership, and Caddy logs:

```bash
./monra logs caddy
```

Do not repeatedly delete Caddy's data volume; repeated certificate requests can trigger CA rate limits.
