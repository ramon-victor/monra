# Operações

Execute os comandos sempre na raiz do repositório. O wrapper `./monra` carrega os dois arquivos de ambiente e o perfil HTTPS opcional de forma consistente.

## Status, logs e saúde

```bash
./monra status
./monra doctor
./monra logs studio
./monra logs wa
./monra logs all
```

`doctor` valida o Compose, verifica permissões do `.env`, chama o endpoint de prontidão do Studio, confere o binding de rede e mostra estado dos containers/disco. Ele nunca imprime valores secretos.

## Iniciar e parar

```bash
./monra stop
./monra start
./monra restart
```

`stop` preserva containers e todos os volumes nomeados. Não use `docker compose down --volumes`: isso apaga os bancos.

## Backup

```bash
./monra backup
```

O comando pausa rapidamente Studio e WA Service para que PostgreSQL e Valkey representem o mesmo ponto da aplicação. Ele cria:

- dumps em formato custom dos três bancos da aplicação;
- globals do PostgreSQL para referência em desastre;
- snapshot do volume do Valkey enquanto parado;
- `.env`, `versions.env`, Compose e configuração do Caddy;
- manifesto e checksums SHA-256.

Os serviços reiniciam automaticamente após o snapshot. Backups ficam em `backups/<data UTC>` com permissões exclusivas do dono.

Copie-os para fora do servidor. Um backup no mesmo disco não é recuperação de desastre. Como contém hashes de senha e `.env`, use armazenamento criptografado e política de retenção testada.

## Restauração

```bash
./monra restore backups/20260901T120000Z
```

A restauração valida todos os checksums, pede a palavra exata `RESTORE`, para os escritores, recria os três bancos com seus donos de privilégio mínimo, substitui os dados do Valkey, inicia a stack e espera a prontidão.

Use `--yes` apenas em automação controlada:

```bash
./monra restore backups/20260901T120000Z --yes
```

O `.env` salvo não é restaurado automaticamente. Ele fica em `config/` dentro do backup para recuperação manual; substituir credenciais atuais silenciosamente poderia bloquear uma instalação saudável.

Teste restaurações regularmente em um host isolado. Backup não testado é apenas uma hipótese.

## Atualização e rollback

```bash
./monra update
```

O atualizador exige uma árvore Git limpa, cria backup, faz fast-forward do repositório de deploy, baixa as imagens selecionadas, aplica migrações e espera a prontidão. Se falhar, volta o repositório ao commit anterior em modo detached, restaura o backup e inicia a release anterior.

Após um rollback automático, investigue os logs antes de voltar à branch principal:

```bash
./monra logs all
git switch main
```

Revise `CHANGELOG.md`, `compose.yaml` e `versions.env` antes de atualizações em produção. Reserve uma janela de manutenção quando a release contiver migrações.

## Rotação de credenciais

Faça backup primeiro. Trocar senhas do banco ou Valkey exige atualizar os papéis/configuração no servidor e também o `.env`; editar somente o `.env` quebra a conexão. Em rotação normal, siga o runbook da release e altere um limite de confiança por vez. Trocar `MONRA_AUTH_SECRET` invalida sessões ativas. Chaves da API e webhook precisam reiniciar as duas aplicações com o mesmo valor novo.
