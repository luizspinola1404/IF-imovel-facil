#!/bin/bash
# Usage: ./deploy-agent.sh "commit message"
if [ -z "$1" ]; then
  echo "Please provide a commit message."
  exit 1
fi
MESSAGE="$1"

echo "==> [DEPLOY COMPLETO] Enviando alterações para o repositório..."
git add .
git commit -m "$MESSAGE" || true
git push

echo "==> Disparando compilação do Agente Windows (.exe) no GitHub Actions..."
gh workflow run build-desktop-agent.yml --ref master || echo "Erro ao disparar workflow. Verifique se o GitHub CLI (gh) está autenticado."

echo "==> Executando deploy automático do site no servidor remoto..."
ssh root@187.77.43.72 <<'EOF'
cd /srv/imovel-facil
git fetch --all && git reset --hard origin/master
docker compose build
docker compose up -d --remove-orphans
EOF

echo "==> Deploy do site e disparo da compilação do Agente (.exe) concluídos!"
