# Contributing

[Português (Brasil)](./CONTRIBUTING.pt-BR.md)

Keep this repository focused on deployment orchestration. Product behavior belongs in the Studio or WA Service repository.

Before opening a pull request:

1. Do not include `.env`, backups, real domains, account data, or credentials.
2. Keep English and `pt-BR` documentation equivalent.
3. Run `bash -n monra`, `sh -n scripts/postgres/init-databases.sh`, ShellCheck, and `docker compose config --quiet` with generated test configuration.
4. Test install, readiness, backup, restore, and rollback paths for changes that affect them.
5. Pin GitHub Actions by commit and container infrastructure by multi-platform digest.
6. Document operator-visible changes in `CHANGELOG.md`.

Prefer Conventional Commit messages such as `feat(deploy): ...` and `fix(backup): ...`.
