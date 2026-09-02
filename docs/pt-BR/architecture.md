# Arquitetura

## Por que um repositório de deploy

Monra Studio e Monra WA Service têm runtimes, ciclos de release e responsabilidades diferentes. Unir os códigos em um monorepo acoplaria o desenvolvimento sem facilitar materialmente o deploy. Este repositório funciona como camada de orquestração: seleciona releases imutáveis compatíveis e define o contrato operacional entre elas.

Assim, iniciantes recebem um único ponto de entrada enquanto os históricos, CI, responsabilidades e limites de rollback continuam independentes.

## Limites dos serviços

| Serviço | Responsabilidade | Exposição no host | Dados persistentes |
| --- | --- | --- | --- |
| Studio | UI, autenticação, automações e recebimento de webhooks | Loopback/LAN ou Caddy | PostgreSQL |
| WA Service | Protocolo do WhatsApp e gateway REST | Nenhuma | PostgreSQL, Valkey e logs rotacionados |
| PostgreSQL | Estado relacional das duas aplicações | Nenhuma | `monra_postgres_data` |
| Valkey | Histórico/cache de chats usado pelo WA Service | Nenhuma | `monra_valkey_data` |
| Caddy | Terminação TLS opcional | TCP 80/443 e UDP 443 | Certificados e configuração |

## Redes e limites de confiança

`backend` é uma rede Docker interna compartilhada pelas aplicações e pelos bancos. `services` permite a comunicação entre Studio, WA Service e Caddy opcional, além da saída das aplicações para a internet. PostgreSQL e Valkey nunca entram em `services` e não publicam portas.

O navegador nunca acessa o WA Service diretamente. O Studio autentica nele com uma chave aleatória independente. O WA Service assina callbacks com outro segredo HMAC compartilhado; o Studio rejeita assinaturas ausentes ou inválidas.

## Isolamento dos dados

Um único cluster PostgreSQL reduz uso de memória e complexidade de backup, mas usa logins separados:

- `monra_studio` possui apenas `monra_studio`.
- `monra_wa` possui apenas `monra_wa_auth` e `monra_wa_users`.
- `monra_admin` fica reservado para inicialização, administração de saúde e backup/restauração.

As senhas são geradas de forma independente. Comprometer um papel de aplicação não libera o banco da outra aplicação.

## Sequência de inicialização

1. PostgreSQL inicializa papéis/bancos e fica saudável.
2. Valkey fica saudável com autenticação ativa.
3. WA Service conecta nos dois e expõe prontidão com dependências.
4. `studio-migrate` adquire um advisory lock do PostgreSQL e aplica migrações versionadas.
5. Studio inicia somente após a prontidão do WA e uma migração bem-sucedida.
6. Caddy opcional inicia depois que o Studio fica pronto.

As condições `service_healthy` e `service_completed_successfully` do Compose garantem essa ordem.

Essa abordagem segue o [modelo de ordem e prontidão documentado pelo Docker](https://docs.docker.com/compose/how-tos/startup-order/); iniciar o container não é considerado suficiente para declarar a aplicação pronta.

## Escopo e escala

Esta stack é voltada para um único host confiável. Ela não promete alta disponibilidade: volumes e plano de controle do Compose são de nó único. Para alta disponibilidade, use PostgreSQL/Valkey gerenciados, orquestrador, armazenamento replicado, gestão externa de segredos e testes de disponibilidade específicos por componente.

## Referências de projeto

- [Ordem de inicialização e desligamento no Docker Compose](https://docs.docker.com/compose/how-tos/startup-order/)
- [Comportamento do HTTPS automático do Caddy](https://caddyserver.com/docs/caddyfile/options#auto-https)
- [Diretiva de proxy reverso do Caddy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy)
- [Ecossistemas suportados pelo Dependabot](https://docs.github.com/en/code-security/reference/supply-chain-security/supported-ecosystems-and-repositories)
- [Configuração do Gitleaks](https://github.com/gitleaks/gitleaks/blob/master/README.md#configuration)
