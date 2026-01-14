# MeuLabN8N - Ansible (container dedicado)

## 1) Objetivo do componente
Executar Ansible em container isolado, com playbooks montados do host e sem dependencias instaladas no Windows.

## 2) Arquitetura
- Imagem: `ansible-core` (build local)
- Container (quando persistente): `ansible`
- Diretorio de playbooks no host: `C:\Users\danie\OneDrive\Documentos\Projetos\MeuLabN8N\Ansible`
- Diretorio no container: `/ansible`
- Base de build: arquivos em `C:\Users\danie\OneDrive\Documentos\Projetos\Container Images\Ansible Core`

## 3) Pre-requisitos
- Podman Desktop + Podman Machine ativos
- Arquivos do build disponiveis em `Container Images\Ansible Core`
- Playbooks salvos em `C:\Users\danie\OneDrive\Documentos\Projetos\MeuLabN8N\Ansible`

## 4) Passo a passo completo
### 4.1) Build da imagem
```powershell
podman build -t ansible-core `
  -f "C:\Users\danie\OneDrive\Documentos\Projetos\Container Images\Ansible Core\Containerfile" `
  "C:\Users\danie\OneDrive\Documentos\Projetos\Container Images\Ansible Core"
```

### 4.2) Execucao pontual (container descartavel)
```powershell
podman run --rm -it `
  --name ansible `
  -v "C:\Users\danie\OneDrive\Documentos\Projetos\MeuLabN8N\Ansible:/ansible" `
  ansible-core `
  ansible-playbook -i /ansible/inventory.ini /ansible/site.yml
```

### 4.3) Execucao com container persistente
```powershell
podman run -d `
  --name ansible `
  -v "C:\Users\danie\OneDrive\Documentos\Projetos\MeuLabN8N\Ansible:/ansible" `
  ansible-core `
  sleep infinity

podman exec -it ansible `
  ansible-playbook -i /ansible/inventory.ini /ansible/site.yml
```

## 5) Operacao diaria
```powershell
podman ps --all --filter name=ansible
podman logs ansible
podman stop ansible
podman start ansible
podman exec -it ansible bash
```

## 6) Backup e restore
- O container nao guarda estado critico. O backup real sao os playbooks no host.
- Para restaurar, recrie a imagem com `podman build` e monte o diretorio de playbooks.

## 7) Troubleshooting
- Erro de SSH `Permission denied (publickey)`:
  - Garanta que `/home/ansible/.ssh/id_ed25519.pub` foi copiada para o `authorized_keys` do alvo.
  - Confirme permissao 600 dentro do container:
    ```powershell
    podman exec -it ansible chmod 600 /home/ansible/.ssh/id_ed25519
    ```
- Erro `WARNING: UNPROTECTED PRIVATE KEY FILE!`:
  - Ajuste permissoes no container como acima.
- Chave nao aparece:
  - O entrypoint gera a chave na primeira inicializacao do container.
  - Se usar `--rm`, a chave sera recriada a cada execucao.

## 8) Proximos passos
- Padronizar inventarios e variaveis em `group_vars/` e `host_vars/`.
- Criar imagens com colecoes extras especificas do lab.
- Integrar disparo via n8n com `podman exec` no host.
