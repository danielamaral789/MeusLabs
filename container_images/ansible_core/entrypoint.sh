#!/bin/bash
set -e

# Garante diretório SSH e permissões
mkdir -p /home/ansible/.ssh
chmod 700 /home/ansible/.ssh

# Se não tiver chave, gera uma
if [ ! -f /home/ansible/.ssh/id_ed25519 ]; then
  echo "Nenhuma chave SSH encontrada, gerando uma nova id_ed25519..."
  ssh-keygen -t ed25519 -f /home/ansible/.ssh/id_ed25519 -N "" -C "ansible@container"

  echo
  echo "======================================================================="
  echo "Chave pública SSH gerada (adicione isso no authorized_keys dos servidores):"
  echo
  cat /home/ansible/.ssh/id_ed25519.pub
  echo "======================================================================="
  echo
fi

# Ajusta permissões
chmod 600 /home/ansible/.ssh/id_ed25519 || true
[ -f /home/ansible/.ssh/known_hosts ] && chmod 600 /home/ansible/.ssh/known_hosts || true

# Segue para o comando original (bash por padrão)
exec "$@"