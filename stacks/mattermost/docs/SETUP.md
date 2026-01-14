# Mattermost (Team Edition) em Podman

## 1) Objetivo do componente
Subir o Mattermost Team Edition em Podman com Postgres dedicado, rede isolada e volumes persistentes, mantendo tudo reproduzivel no lab.

## 2) Arquitetura
- Stack dedicada em Podman Compose
- Servicos:
  - `mattermost` (docker.io/mattermost/mattermost-team-edition:latest)
  - `mm-postgres` (docker.io/postgres:16)
- Rede: `mattermost-net`
- Volumes:
  - `mm_postgres_data`
  - `mm_data`
  - `mm_config`
  - `mm_logs`
  - `mm_plugins`
  - `mm_client_plugins`
  - `mm_bleve`
- Porta local: `http://localhost:8065`

## 3) Pre-requisitos
- Windows + PowerShell
- Podman Desktop com Podman Machine ativa
- Repositorio clonado em: `C:\Users\danie\OneDrive\Documentos\Projetos\MeuLabN8N`
- Podman Compose disponivel (comando `podman compose`)

## 4) Estrutura de diretorios
```
stacks/mattermost/
  compose.yml
  env/
    app.env
    db.env
    credentials.env
  docs/
    SETUP.md
  volumes/
```

## 5) Variaveis e credenciais (registradas)
### 5.1) Postgres do Mattermost
- Usuario: `mmuser`
- Senha: `et3g0Dnp11uBi4bkAHxf5FpIMv9iWnQV`
- Database: `mattermost`
- Arquivo: `stacks/mattermost/env/db.env`

### 5.2) Admin do Mattermost (para criar no setup inicial)
- Usuario: `mmadmin`
- Senha: `Kmp4j/7hVoHKH0DDaqAHnsBKsYZmHoo5`
- Arquivo: `stacks/mattermost/env/credentials.env`

## 6) Passo a passo completo
### 6.1) Subir o stack
```powershell
podman compose -f .\mattermost\compose.yml up -d
```

### 6.2) Verificar status
```powershell
podman compose -f .\mattermost\compose.yml ps
podman ps --filter name=mm-postgres
podman ps --filter name=mattermost
```

### 6.3) Logs
```powershell
podman compose -f .\mattermost\compose.yml logs -f
podman logs mm-postgres
podman logs mattermost
```

### 6.4) Parar o stack
```powershell
podman compose -f .\mattermost\compose.yml down
```

### 6.5) Reset completo (cuidado: apaga dados)
```powershell
podman compose -f .\mattermost\compose.yml down -v
podman volume rm mm_postgres_data mm_data mm_config mm_logs mm_plugins mm_client_plugins mm_bleve
```

## 7) Acesso e configuracao inicial
1. Acesse `http://localhost:8065`.
2. Crie o admin usando:
   - Usuario: `mmadmin`
   - Senha: `Kmp4j/7hVoHKH0DDaqAHnsBKsYZmHoo5`
3. Crie um time base (ex.: `lab`).
4. Crie um canal inicial (ex.: `inbox`).

## 8) Runbook rapido (troubleshooting)
- DB nao conecta:
  - Verifique `mm-postgres` com `podman logs mm-postgres`.
  - Confirme `MM_SQLSETTINGS_DATASOURCE` em `stacks/mattermost/env/app.env`.
- Porta 8065 ocupada:
  - Veja quem usa a porta no Windows e ajuste o `ports` do compose.
- Container reiniciando:
  - Rode `podman logs mattermost` e corrija variaveis do DB.
  - Confirme que o Postgres esta healthy.

## 9) Checklist de validacao
- [ ] `http://localhost:8065` abre no browser
- [ ] Login admin funciona com `mmadmin`
- [ ] Time base criado
- [ ] Canal `#inbox` criado

## 10) Integracao planejada com n8n (sem implementar)
### 10.1) Incoming Webhooks
- Em Mattermost: **System Console > Integrations > Integration Management**
- Habilitar: **Enable Incoming Webhooks**
- Criar webhook para um canal (ex.: `#inbox`)
- Salvar a URL aqui (placeholder):
  - `MM_WEBHOOK_URL=<substituir-quando-criar>`

### 10.2) Bot Accounts
- Em Mattermost: **System Console > Integrations > Bot Accounts**
- Habilitar: **Enable Bot Account Creation**
- Criar bot e gerar token
- Salvar o token aqui (placeholder):
  - `MM_BOT_TOKEN=<substituir-quando-criar>`

### 10.3) Onde armazenar
- Guardar os valores acima em um arquivo novo quando existir:
  - `stacks/mattermost/env/integration.env`
- Registrar na documentacao quando os tokens forem criados.
