# Guia de segurança

## Padrões seguros

- Studio fica em loopback, salvo escolha explícita de outro IPv4.
- Bancos e WA Service não publicam portas no host.
- Credenciais aleatórias independentes protegem cada limite de confiança.
- Assinaturas de webhook são obrigatórias e o log do payload completo fica desligado.
- Containers de aplicação rodam sem root, em filesystem somente leitura, com capacidades Linux removidas e apenas tmpfs/volumes necessários graváveis.
- Imagens versionadas, infraestrutura fixada por digest, scanner de segredos, SBOM e proveniência reduzem ambiguidade da cadeia de fornecimento.

## Responsabilidades do operador

- Mantenha Docker, sistema do host e este deploy atualizados.
- Restrinja SSH, use autenticação por chave e ative firewall.
- Use HTTPS em qualquer rede não confiável.
- Proteja `.env` e backups; nunca os envie em canais de suporte.
- Guarde backups externos criptografados e teste restaurações.
- Revise logs antes de compartilhá-los.
- Use tokens GitHub com privilégio mínimo apenas para pacotes privados.

O acesso ao daemon Docker normalmente equivale a root no host. Somente administradores confiáveis devem pertencer ao grupo Docker ou poder alterar este repositório, `.env`, arquivos Compose ou o socket do Docker.

## Segredos e rotação

O instalador gera sete valores independentes de 256 bits. Não os substitua por senhas memorizáveis. Uma suspeita de exposição exige rotação mesmo que o histórico Git seja limpo depois. Segredos já versionados nos componentes devem ser considerados comprometidos e rotacionados no provedor externo.

## Dados e privacidade

Eventos do WhatsApp podem conter dados pessoais, telefones, mídias e mensagens. Escolha retenção legal, restrinja administradores, defina procedimentos de exclusão/incidente e entenda qual provedor opcional de IA receberá dados antes de adicionar sua chave.

## Relato

Use o relato privado de vulnerabilidades do GitHub. Inclua reprodução sanitizada, versão afetada e impacto. Nunca inclua credenciais funcionais ou dados reais de usuários.
