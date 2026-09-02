# Architecture

## Why a deployment repository

Monra Studio and Monra WA Service have different runtimes, release cycles, and responsibilities. Combining their source into a monorepo would couple development without making deployment materially easier. This repository is an orchestration layer: it selects compatible immutable releases and defines the operational contract between them.

This gives beginners one entry point while preserving independent source histories, CI, ownership, and rollback boundaries.

## Service boundaries

| Service | Responsibility | Host exposure | Persistent data |
| --- | --- | --- | --- |
| Studio | UI, authentication, automation, webhook receiver | Loopback/LAN, or Caddy | PostgreSQL |
| WA Service | WhatsApp protocol and REST gateway | None | PostgreSQL, Valkey, rotated logs |
| PostgreSQL | Relational state for both apps | None | `monra_postgres_data` |
| Valkey | Chat history/cache used by WA Service | None | `monra_valkey_data` |
| Caddy | Optional TLS termination | TCP 80/443, UDP 443 | Certificate data/config |

## Networks and trust boundaries

`backend` is an internal Docker network shared by the applications and data stores. `services` lets Studio, WA Service, and optional Caddy communicate and gives the applications outbound internet access. PostgreSQL and Valkey are never attached to `services` and have no published ports.

The browser never talks directly to WA Service. Studio authenticates to it using an independent random API key. WA Service signs callbacks with a separate shared HMAC key; Studio rejects missing or invalid signatures.

## Data isolation

One PostgreSQL cluster reduces memory and backup complexity, but it uses separate login roles:

- `monra_studio` owns only `monra_studio`.
- `monra_wa` owns only `monra_wa_auth` and `monra_wa_users`.
- `monra_admin` is reserved for initialization, health administration, and backup/restore.

The passwords are generated independently. A compromise of one application role does not grant access to the other application's database.

## Startup sequence

1. PostgreSQL initializes roles/databases and becomes healthy.
2. Valkey becomes healthy with authentication enabled.
3. WA Service connects to both and exposes dependency-aware readiness.
4. `studio-migrate` acquires a PostgreSQL advisory lock and applies committed migrations.
5. Studio starts only after WA readiness and a successful migration.
6. Optional Caddy starts after Studio becomes ready.

Compose's `service_healthy` and `service_completed_successfully` conditions enforce this order.

This follows Docker's documented [startup-order and readiness model](https://docs.docker.com/compose/how-tos/startup-order/); container start alone is not treated as application readiness.

## Scope and scaling

This stack targets one reliable host. It deliberately does not claim high availability: the data volumes and Compose control plane are single-node. For higher availability, use managed PostgreSQL/Valkey, an orchestrator, replicated storage, external secret management, and component-specific availability testing.

## Design references

- [Docker Compose startup and shutdown order](https://docs.docker.com/compose/how-tos/startup-order/)
- [Caddy automatic HTTPS behavior](https://caddyserver.com/docs/caddyfile/options#auto-https)
- [Caddy reverse proxy directive](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy)
- [GitHub Dependabot supported ecosystems](https://docs.github.com/en/code-security/reference/supply-chain-security/supported-ecosystems-and-repositories)
- [Gitleaks configuration](https://github.com/gitleaks/gitleaks/blob/master/README.md#configuration)
