# Contribuindo

[English](./CONTRIBUTING.md)

Mantenha este repositório focado na orquestração de deploy. Comportamento do produto pertence ao repositório do Studio ou do WA Service.

Antes de abrir um pull request:

1. Não inclua `.env`, backups, domínios reais, dados de contas ou credenciais.
2. Mantenha a documentação em inglês e `pt-BR` equivalente.
3. Execute `bash -n monra`, `sh -n scripts/postgres/init-databases.sh`, ShellCheck e `docker compose config --quiet` com configuração de teste gerada.
4. Teste instalação, prontidão, backup, restauração e rollback quando a mudança afetar esses fluxos.
5. Fixe GitHub Actions por commit e containers de infraestrutura por digest multiplataforma.
6. Documente mudanças visíveis ao operador em `CHANGELOG.md`.

Prefira commits convencionais como `feat(deploy): ...` e `fix(backup): ...`.
