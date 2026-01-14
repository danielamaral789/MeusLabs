# n8n + PostgreSQL em Podman

## 1) Objetivo do componente
Documentar a instalacao, operacao e recuperacao do n8n com PostgreSQL em um pod Podman no Windows.

## 2) Arquitetura
- Pod: `n8n-pod`
- Containers:
  - `n8n` (docker.io/n8nio/n8n:latest)
  - `n8n-postgres` (docker.io/postgres:16)
- Volumes:
  - `n8n_data` -> `/home/node/.n8n`
  - `n8n_pgdata` -> `/var/lib/postgresql/data`
- Porta: `5678:5678`
- Banco dentro do pod: `127.0.0.1:5432`

### Integracao n8n -> Ansible (conceitual, sem dominio externo)
- O n8n deve apenas disparar a automacao; o Ansible continua isolado no container `ansible`.
- Opcao A: n8n aciona um script PowerShell local que executa `podman exec ansible ansible-playbook ...`.
- Opcao B: n8n acessa um endpoint local que faz o disparo do playbook no host.
- Em ambos os casos, sem dominio externo, apenas `localhost`/rede local do host.

## 3) Pre-requisitos
- Podman Desktop + Podman Machine ativos
- PowerShell
- Variaveis fixas:
  - `N8N_ENCRYPTION_KEY="coloque-uma-chave-fixa-aqui"`
  - `DB_POSTGRESDB_USER=n8n`
  - `DB_POSTGRESDB_PASSWORD=n8npass`
  - `DB_POSTGRESDB_DATABASE=n8n`

## 4) Passo a passo completo
### 4.1) Criar volumes
```powershell
podman volume create n8n_data
podman volume create n8n_pgdata
```

### 4.2) Criar pod
```powershell
podman pod create `
  --name n8n-pod `
  -p 5678:5678
```

### 4.3) Postgres
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

### 4.4) n8n
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

podman volume create n8n_data
podman volume create n8n_pgdata
podman volume import n8n_data n8n_data.tar
podman volume import n8n_pgdata n8n_pgdata.tar
```

## 7) Troubleshooting
- Pod nao cria: use `podman pod create`, nao `podman create pod`.
- Volume nao existe: rode `podman volume create`.
- Postgres indisponivel: verifique `podman logs n8n-postgres`.
- Erro de credenciais no n8n: confirme `DB_POSTGRESDB_*`.
- Credenciais do n8n "quebradas": `N8N_ENCRYPTION_KEY` mudou.

## 8) Proximos passos
- Reverse proxy local.
- Webhooks controlados na rede local.
- Workers para filas e escalabilidade.
- Disparo de playbooks Ansible a partir de workflows n8n.
