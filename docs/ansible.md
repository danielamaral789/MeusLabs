# Ansible em container dedicado

## 1) Objetivo do componente
Executar automacoes Ansible isoladas em container, usando playbooks montados do host.

## 2) Arquitetura
- Imagem: `ansible-core` (build local)
- Container: `ansible` (quando persistente)
- Playbooks no host: `C:\Users\danie\OneDrive\Documentos\Projetos\MeuLabN8N\Ansible`
- Playbooks no container: `/ansible`
- Build a partir de: `C:\Users\danie\OneDrive\Documentos\Projetos\MeuLabN8N\images\ansible_core`

### Integracao n8n -> Ansible (conceitual, sem dominio externo)
- O n8n dispara o Ansible chamando `podman exec` no host.
- Uma abordagem comum e um script PowerShell local que roda:
  `podman exec ansible ansible-playbook -i /ansible/inventory.ini /ansible/site.yml`
- O n8n apenas aciona o script (sem expor dominio externo).

## 3) Pre-requisitos
- Podman Desktop + Podman Machine ativos
- Arquivos do Containerfile e entrypoint prontos na pasta de build
- Playbooks disponiveis no diretorio do host

## 4) Passo a passo completo
### 4.1) Build da imagem
```powershell
podman build -t ansible-core `
  -f "C:\Users\danie\OneDrive\Documentos\Projetos\MeuLabN8N\images\ansible_core\Containerfile" `
  "C:\Users\danie\OneDrive\Documentos\Projetos\MeuLabN8N\images\ansible_core"
```

### 4.2) Execucao pontual
```powershell
podman run --rm -it `
  --name ansible `
  -v "C:\Users\danie\OneDrive\Documentos\Projetos\MeuLabN8N\Ansible:/ansible" `
  ansible-core `
  ansible-playbook -i /ansible/inventory.ini /ansible/site.yml
```

### 4.3) Execucao persistente
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
podman start ansible
podman stop ansible
podman exec -it ansible bash
```

## 6) Backup e restore
- O estado critico sao os playbooks no host.
- Para restaurar: reconstruir a imagem e montar o diretorio de playbooks.

## 7) Troubleshooting
- `Permission denied (publickey)`:
  - Copie `/home/ansible/.ssh/id_ed25519.pub` para o `authorized_keys` do alvo.
- `UNPROTECTED PRIVATE KEY FILE`:
  - Ajuste permissoes no container:
    ```powershell
    podman exec -it ansible chmod 600 /home/ansible/.ssh/id_ed25519
    ```
- Chave nao aparece:
  - O entrypoint gera a chave na primeira inicializacao.
  - Em `--rm`, a chave e recriada sempre.

## 8) Proximos passos
- Padronizar roles e colecoes.
- Versionar inventarios e variaveis no repositorio.
- Integrar disparos do n8n via scripts locais.
