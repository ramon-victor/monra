# Security Guide

## Secure defaults

- Studio binds to loopback unless the operator explicitly chooses another IPv4 address.
- Data stores and WA Service have no published host ports.
- Independent random credentials protect each trust boundary.
- Webhook signatures are required and full webhook payload logging is disabled.
- Application containers run non-root, read-only, with dropped Linux capabilities and writable tmpfs/volumes only where needed.
- Versioned images, digest-pinned infrastructure, CI secret scanning, SBOMs, and provenance reduce supply-chain ambiguity.

## Operator responsibilities

- Keep Docker, the host OS, and this deployment updated.
- Restrict SSH, use key authentication, and enable a host firewall.
- Use HTTPS for any untrusted network.
- Protect `.env` and backups; never transmit them in support channels.
- Store off-host backups encrypted and test restoration.
- Review application logs before sharing them.
- Use least-privilege GitHub tokens only when private package access is necessary.

Docker daemon access is root-equivalent on a typical host. Only trusted administrators should belong to the Docker group or be able to modify this repository, `.env`, Compose files, or the Docker socket.

## Secrets and rotation

The installer generates seven independent 256-bit values. Do not replace them with memorable passwords. A suspected exposure requires rotation even if Git history is later cleaned. Secrets previously committed to either component repository must be considered compromised and rotated at their external provider.

## Data and privacy

WhatsApp events can contain personal data, phone numbers, media, and message content. Choose lawful retention settings, restrict administrator access, establish deletion/incident procedures, and understand which optional AI provider receives data before adding its API key.

## Reporting

Use GitHub private vulnerability reporting. Include sanitized reproduction steps, affected version, and impact. Never include working production credentials or real user data.
