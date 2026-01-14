# MeuLabN8N - Documentacao geral

## 1) Objetivo do componente
Consolidar a visao geral do lab, com os blocos principais (n8n, PostgreSQL e Ansible) e o fluxo de uso.

## 2) Arquitetura
- Podman Desktop executa o pod `n8n-pod` com `n8n` + `n8n-postgres`.
- Um container separado `ansible` executa playbooks montados do host.
- Mattermost roda em stack dedicada com Postgres proprio.
- Persistencia via volumes `n8n_data` e `n8n_pgdata`.
- Acesso local via `http://localhost:5678`.

## 3) Pre-requisitos
- Windows + PowerShell
- Podman Desktop + Podman Machine ativos
- Estrutura do projeto em `C:\Users\danie\OneDrive\Documentos\Projetos\MeuLabN8N`

## 4) Passo a passo completo
1. Criar volumes e pod do n8n conforme `docs/n8n.md`.
2. Criar a imagem e o container do Ansible conforme `docs/ansible.md`.
3. Subir o Mattermost conforme `docs/mattermost/SETUP.md`.
4. Validar acesso ao n8n em `http://localhost:5678` e ao Mattermost em `http://localhost:8065`.

## 5) Operacao diaria
- Subir/parar o pod n8n com `podman pod start/stop n8n-pod`.
- Executar playbooks via `podman run` ou `podman exec` no container `ansible`.

## 6) Backup e restore
- Backups dos volumes do n8n usando `podman volume export`.
- Playbooks ficam no host e devem entrar no backup padrao do Windows/OneDrive.

## 7) Troubleshooting
- Pod nao cria: confirme o comando `podman pod create` e o nome `n8n-pod`.
- Sem acesso ao n8n: confira publicacao da porta `5678:5678` no pod.
- Falha de SSH no Ansible: valide chave publica e permissoes.

## 8) Proximos passos
- Reverse proxy local com TLS.
- Webhooks internos para workflows do n8n.
- Workers do n8n para escalabilidade.
- Pipelines de automacao que disparam Ansible.
