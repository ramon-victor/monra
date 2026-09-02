# Solução de problemas

Comece por:

```bash
./monra doctor
./monra status
./monra logs all
```

Nunca publique logs completos sem revisar números de telefone, mensagens, tokens, URLs e detalhes dos bancos.

## As imagens não são baixadas

Se o registry responder `not found`, confirme que as versões de aplicação em `versions.env` existem no GHCR e são públicas. As referências iniciais `v0.1.0` exigem que as releases correspondentes dos componentes tenham sido publicadas. Para um pacote privado, autentique com token somente de leitura usando `docker login ghcr.io`.

## `studio-migrate` falhou

Veja apenas os logs da migração:

```bash
./monra logs migrate
```

Não ignore o serviço nem execute comandos de schema push. Verifique saúde do PostgreSQL, espaço em disco, compatibilidade da imagem e credenciais. Restaure o backup anterior à atualização se uma migração não puder concluir.

## Studio não está saudável

A prontidão do Studio depende do PostgreSQL e da prontidão do WA Service. Verifique nesta ordem:

```bash
./monra logs postgres
./monra logs valkey
./monra logs wa
./monra logs studio
```

A resposta pública de prontidão não revela qual dependência falhou; os logs dos containers trazem os detalhes apenas para o operador.

## Login ou redirecionamento falha

Confirme que o endereço do navegador corresponde exatamente a `MONRA_PUBLIC_URL` ou a uma das `MONRA_TRUSTED_ORIGINS`. Reinicie o Studio após alterar URLs. Limpe cookies antigos somente depois de confirmar a configuração.

## WhatsApp não reconecta

Verifique logs do WA, relógio do sistema, internet/DNS de saída e estado da instância no Studio. Um novo QR/pareamento pode ser necessário após logout ou mudança do protocolo. Evite tentativas rápidas repetidas e use um número dedicado.

## Disco cheio

`./monra doctor` mostra uso do filesystem. Backups nunca são removidos automaticamente. Mova backups verificados para fora do host antes de apagar cópias locais. Não remova volumes Docker nomeados nem execute comandos amplos de prune sem identificar exatamente o conteúdo.

## Conflito de porta

No modo local/LAN, escolha outra porta do Studio:

```bash
./monra install --port 15522
```

Para HTTPS, identifique o serviço existente nas portas 80/443 ou use seu proxy reverso em vez do Caddy incluído.
