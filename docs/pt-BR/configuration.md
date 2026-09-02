# Configuração

Execute `./monra install`; ele cria o `.env` com segredos independentes de 256 bits e permissão `600`. Não versione esse arquivo. `versions.env` é versionado porque contém referências de imagens, não credenciais.

## Opções de instalação

| Opção | Finalidade |
| --- | --- |
| `--bind IPv4` | Vincula o Studio a uma interface confiável; padrão `127.0.0.1` |
| `--port PORTA` | Porta do Studio no host; padrão `5522` |
| `--domain DOMÍNIO` | Ativa o perfil público do Caddy e HTTPS automático |
| `--email EMAIL` | E-mail da conta ACME; obrigatório com `--domain` |
| `--no-pull` | Pula download de imagens, apenas para teste local/recuperação |
| `--no-start` | Gera e valida a configuração sem iniciar serviços |

## Configurações principais

| Variável | Significado | Padrão gerado pelo instalador |
| --- | --- | --- |
| `MONRA_BIND_IP` | Interface que publica o Studio | `127.0.0.1` |
| `MONRA_PORT` | Porta publicada do Studio | `5522` |
| `MONRA_PUBLIC_URL` | URL canônica usada pela autenticação | Derivada do modo |
| `MONRA_TRUSTED_ORIGINS` | Origens do navegador separadas por vírgula | Derivadas da URL |
| `MONRA_ENABLE_HTTPS` | Ativa o perfil `public` do Compose | `false` |
| `MONRA_DOMAIN` | Nome DNS público | Vazio |
| `MONRA_ACME_EMAIL` | E-mail da conta de certificados | Vazio |
| `MONRA_SAVE_MESSAGES` | Persiste mensagens WA no PostgreSQL | `false` |
| `MONRA_WEBHOOK_FILES` | Inclui mídia/dados nos callbacks | `true` |
| `MONRA_CONNECT_ON_STARTUP` | Reconecta instâncias após reinício | `true` |
| `MONRA_WA_LOG_LEVEL` | Nível de log da biblioteca WhatsApp | `INFO` |
| `MONRA_IGNORE_GROUP_EVENTS` | Descarta eventos de grupos | `false` |
| `MONRA_IGNORE_STATUS_EVENTS` | Descarta eventos de status/stories | `true` |

As variáveis de senha, autenticação, API e webhook são geradas automaticamente. Nunca reutilize um valor em campos diferentes nem os cole em issues ou logs.

## Configurações opcionais de IA

As chaves ficam vazias propositalmente. Adicione apenas o provedor usado pelo `CHAT_AGENT_MODEL` escolhido:

- `AI_GATEWAY_API_KEY`
- `OPENCODE_API_KEY`
- `GROQ_API_KEY`
- `GEMINI_API_KEY`
- `OPENROUTER_API_KEY`
- `OPENAI_API_KEY` e `OPENAI_BASE_URL`
- `CHAT_AGENT_MODEL` e `CHAT_AGENT_MODEL_MAX_RETRIES`

Depois de editar o `.env`, execute `./monra restart` e `./monra doctor`.

## Versões de imagens

`versions.env` é o único arquivo de seleção de imagens. A infraestrutura é fixada por digest. As aplicações usam uma tag semântica junto do digest do manifesto multiplataforma (`tag@sha256:<manifest-digest>`); o Docker seleciona o digest, enquanto a tag permite que o operador reconheça a release. Altere os dois valores juntos somente depois que a release correspondente do componente terminar.

Nunca use `latest` em produção.
