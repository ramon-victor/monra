# Troubleshooting

Start with:

```bash
./monra doctor
./monra status
./monra logs all
```

Never paste complete logs publicly without reviewing them for phone numbers, message bodies, tokens, URLs, and database details.

## Images cannot be pulled

If the registry reports `not found` or `unauthorized`, verify that the `v0.1.1` application references in `versions.env` exist in GHCR and that their manifest digests match the component releases. Public Container packages pull anonymously. For an intentionally private package, authenticate with a read-only token using `docker login ghcr.io` before installing.

## `studio-migrate` failed

Inspect only its logs:

```bash
./monra logs migrate
```

Do not bypass the migration service or run schema push commands. Verify PostgreSQL health, disk space, image compatibility, and database credentials. Restore the pre-update backup if a release migration cannot be completed.

## Studio is unhealthy

Studio readiness requires PostgreSQL and WA Service readiness. Check in this order:

```bash
./monra logs postgres
./monra logs valkey
./monra logs wa
./monra logs studio
```

The public readiness response intentionally does not reveal which dependency failed; the container logs provide operator-only detail.

## Browser login or redirect fails

Confirm the address in the browser exactly matches `MONRA_PUBLIC_URL` or one of `MONRA_TRUSTED_ORIGINS`. After changing URLs, restart Studio. Clear stale cookies only after confirming the configuration.

## WhatsApp does not reconnect

Check WA logs, system clock, outbound internet/DNS, and the instance state in Studio. A new QR/pairing flow may be required after logout or a protocol change. Avoid rapid repeated pairing attempts, and use a dedicated number.

## Disk is full

`./monra doctor` shows filesystem usage. Backups are never removed automatically. Move verified backups off-host before deleting local copies. Do not remove named Docker volumes or run broad prune commands without identifying exactly what they contain.

## Port conflict

For local/LAN mode, choose another Studio port:

```bash
./monra install --port 15522
```

For HTTPS, identify the existing service on ports 80/443 or use your existing reverse proxy instead of bundled Caddy.
