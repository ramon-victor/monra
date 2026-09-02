# Domínio e HTTPS

## Modo automático

Antes da instalação:

1. Crie um registro A (e AAAA somente se o IPv6 estiver roteado corretamente) para o domínio.
2. Libere TCP 80 e 443; libere UDP 443 para HTTP/3.
3. Garanta que nenhum outro serviço use essas portas.

Depois execute:

```bash
./monra install --domain monra.exemplo.com --email admin@exemplo.com
```

O instalador configura a URL canônica de autenticação e ativa o perfil `public` do Caddy. Um hostname no Caddyfile habilita gerenciamento automático de certificados e redirecionamento HTTP para HTTPS. O estado dos certificados persiste em `monra_caddy_data`.

## Já existe um proxy reverso

Mantenha a instalação padrão em loopback e encaminhe para `127.0.0.1:5522`. Configure no `.env` antes de reiniciar:

```env
MONRA_PUBLIC_URL=https://monra.exemplo.com
MONRA_TRUSTED_ORIGINS=https://monra.exemplo.com
```

Deixe `MONRA_ENABLE_HTTPS=false` para o Caddy incluído não disputar as portas. Seu proxy deve preservar `Host`, `X-Forwarded-Proto` e os headers normais de upgrade WebSocket. Termine o TLS nesse proxy e restrinja acesso direto à porta 5522.

## Falhas de DNS e certificado

Verifique DNS público a partir de outra rede, regras de firewall/NAT, uso das portas e logs do Caddy:

```bash
./monra logs caddy
```

Não apague repetidamente o volume do Caddy; novos pedidos de certificado podem atingir limites da autoridade certificadora.
