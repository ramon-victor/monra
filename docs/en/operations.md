# Operations

Always run commands from the repository root. The `./monra` wrapper loads both environment files and the optional HTTPS profile consistently.

## Status, logs, and health

```bash
./monra status
./monra doctor
./monra logs studio
./monra logs wa
./monra logs all
```

`doctor` validates Compose, checks `.env` permissions, calls Studio's dependency-aware readiness endpoint, verifies the network binding, and shows container/disk status. It never prints secret values.

## Start and stop

```bash
./monra stop
./monra start
./monra restart
```

`stop` preserves containers and every named volume. Do not use `docker compose down --volumes`: that deletes the databases.

## Backup

```bash
./monra backup
```

The command briefly pauses Studio and WA Service so PostgreSQL and Valkey describe the same application point in time. It creates:

- custom-format dumps for all three application databases;
- PostgreSQL globals for disaster-recovery reference;
- a stopped-volume snapshot of Valkey data;
- `.env`, `versions.env`, Compose, and Caddy configuration;
- a manifest and SHA-256 checksums.

Application services restart automatically after the snapshot. Backups live in `backups/<UTC timestamp>` with owner-only permissions.

Copy backups off the server. A backup on the same disk is not disaster recovery. Because it contains password hashes and `.env`, use encrypted storage and a tested retention policy.

## Restore

```bash
./monra restore backups/20260901T120000Z
```

Restore validates every checksum, asks for the exact word `RESTORE`, stops writers, recreates the three databases with their least-privilege owners, replaces Valkey data, starts the deployment, and waits for readiness.

Use `--yes` only in controlled automation:

```bash
./monra restore backups/20260901T120000Z --yes
```

The saved `.env` is not restored automatically. It is available under the backup's `config/` directory for manual disaster recovery; silently replacing current credentials could lock out a healthy installation.

Test restores regularly on an isolated host. An untested backup is only a hypothesis.

## Update and rollback

```bash
./monra update
```

The updater requires a clean tracked worktree, creates a backup, fast-forwards the deployment repository, pulls selected images, applies migrations, and waits for readiness. If deployment fails, it detaches the repository at the previous commit, restores the backup, and starts the previous release.

After an automatic rollback, investigate logs before returning to the main branch:

```bash
./monra logs all
git switch main
```

Review changes to `CHANGELOG.md`, `compose.yaml`, and `versions.env` before production updates. Schedule a maintenance window when a release contains migrations.

## Credential rotation

Take a backup first. Changing database or Valkey passwords requires updating the server-side roles/configuration as well as `.env`; editing only `.env` will break connectivity. For routine rotation, follow a release-specific runbook and rotate one trust boundary at a time. `MONRA_AUTH_SECRET` rotation invalidates active Studio sessions. API and webhook key rotations require both applications to restart with the same new value.
