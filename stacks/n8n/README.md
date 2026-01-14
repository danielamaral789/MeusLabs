# MeuLabN8N - n8n (Podman + PostgreSQL)

## 1) Objetivo do componente
Executar o n8n como orquestrador de automacao com banco PostgreSQL em Podman, com persistencia por volumes e recriacao total via comandos documentados.

## 2) Arquitetura
- Pod: `n8n-pod`
- Containers:
  - `n8n` (imagem `docker.io/n8nio/n8n:latest`)
  - `n8n-postgres` (imagem `docker.io/postgres:16`)
- Volumes:
  - `n8n_data` -> `/home/node/.n8n`
  - `n8n_pgdata` -> `/var/lib/postgresql/data`
- Porta exposta do pod: `5678:5678`
- Host de conexao do Postgres dentro do pod: `127.0.0.1:5432`

## 3) Pre-requisitos
- Windows + PowerShell
- Podman Desktop com Podman Machine ativa
- Pasta do projeto: `C:\Users\danie\OneDrive\Documentos\Projetos\MeuLabN8N`
- Sem uso de docker-compose

## 4) Passo a passo completo
### 4.1) Criar volumes
```powershell
podman volume create n8n_data
podman volume create n8n_pgdata
```

### 4.2) Criar o pod
```powershell
podman pod create `
  --name n8n-pod `
  -p 5678:5678
```

### 4.3) Criar o container do Postgres
```powershell
podman run -d `
  --pod n8n-pod `
  --name n8n-postgres `
  -e POSTGRES_USER=n8n `
  -e POSTGRES_PASSWORD=n8npass `
  -e POSTGRES_DB=n8n `
  -v n8n_pgdata:/var/lib/postgresql/data `
  docker.io/postgres:16
```

### 4.4) Criar o container do n8n
```powershell
podman run -d `
  --pod n8n-pod `
  --name n8n `
  -v n8n_data:/home/node/.n8n `
  -e N8N_ENCRYPTION_KEY="coloque-uma-chave-fixa-aqui" `
  -e DB_TYPE=postgresdb `
  -e DB_POSTGRESDB_HOST=127.0.0.1 `
  -e DB_POSTGRESDB_PORT=5432 `
  -e DB_POSTGRESDB_DATABASE=n8n `
  -e DB_POSTGRESDB_USER=n8n `
  -e DB_POSTGRESDB_PASSWORD=n8npass `
  -e N8N_HOST=localhost `
  -e N8N_PORT=5678 `
  -e N8N_PROTOCOL=http `
  docker.io/n8nio/n8n:latest
```

### 4.5) Acesso
- UI: `http://localhost:5678`
- O valor de `N8N_ENCRYPTION_KEY` deve ser fixo entre recriacoes.

## 5) Operacao diaria
```powershell
# Status
podman pod ps
podman ps

# Parar e iniciar
podman pod stop n8n-pod
podman pod start n8n-pod

# Logs
podman logs n8n
podman logs n8n-postgres

# Entrar no container
podman exec -it n8n /bin/sh
```

## 6) Backup e restore
### 6.1) Backup dos volumes
```powershell
podman volume export n8n_data -o n8n_data.tar
podman volume export n8n_pgdata -o n8n_pgdata.tar
```

### 6.2) Restore dos volumes
```powershell
podman volume create n8n_data
podman volume create n8n_pgdata
podman volume import n8n_data n8n_data.tar
podman volume import n8n_pgdata n8n_pgdata.tar
```

## 7) Troubleshooting
- Erro ao criar pod: use `podman pod create`, nao existe `podman create pod`.
- Erro de volume: `Error: volume n8n_data does not exist` -> rode `podman volume create n8n_data`.
- Erro de conexao com Postgres: confirme `DB_POSTGRESDB_*` e veja `podman logs n8n-postgres`.
- n8n nao abre na porta 5678: verifique `podman pod ps` e se a porta foi publicada no pod.
- Erro de criptografia: se `N8N_ENCRYPTION_KEY` mudou, o n8n nao consegue ler credenciais antigas.

## 8) Proximos passos
- Reverse proxy local (ex.: adicionar TLS e caminho por subpath).
- Webhooks com roteamento local e controle de origem.
- Workers do n8n para filas e escalabilidade.
- Pipelines de automacao com disparos de playbooks Ansible.
