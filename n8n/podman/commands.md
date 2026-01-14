# n8n - Comandos Podman (referencia rapida)

## 1) Objetivo do componente
Listar os comandos oficiais usados para subir e operar o pod `n8n-pod` com n8n e PostgreSQL.

## 2) Arquitetura
- Pod: `n8n-pod`
- Containers: `n8n`, `n8n-postgres`
- Volumes: `n8n_data`, `n8n_pgdata`
- Porta: `5678:5678`

## 3) Pre-requisitos
- PowerShell
- Podman Desktop + Podman Machine ativos

## 4) Passo a passo completo
```powershell
# Volumes
podman volume create n8n_data
podman volume create n8n_pgdata

# Pod
podman pod create `
  --name n8n-pod `
  -p 5678:5678

# Postgres
podman run -d `
  --pod n8n-pod `
  --name n8n-postgres `
  -e POSTGRES_USER=n8n `
  -e POSTGRES_PASSWORD=n8npass `
  -e POSTGRES_DB=n8n `
  -v n8n_pgdata:/var/lib/postgresql/data `
  docker.io/postgres:16

# n8n
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

## 5) Operacao diaria
```powershell
podman pod ps
podman ps
podman logs n8n
podman logs n8n-postgres
podman pod stop n8n-pod
podman pod start n8n-pod
```

## 6) Backup e restore
```powershell
podman volume export n8n_data -o n8n_data.tar
podman volume export n8n_pgdata -o n8n_pgdata.tar
podman volume import n8n_data n8n_data.tar
podman volume import n8n_pgdata n8n_pgdata.tar
```

## 7) Troubleshooting
- `podman create pod` nao existe -> use `podman pod create`.
- `volume ... does not exist` -> crie com `podman volume create`.
- `ECONNREFUSED` no n8n -> confirme `DB_POSTGRESDB_HOST=127.0.0.1` e Postgres rodando.

## 8) Proximos passos
- Separar operacao em scripts PowerShell.
- Automatizar healthchecks com `podman healthcheck`.
