#!/bin/bash
# Usage: ./deploy.sh "commit message"
if [ -z "$1" ]; then
  echo "Please provide a commit message."
  exit 1
fi
MESSAGE="$1"

echo "==> Compilando o scraper em Rust localmente..."
(cd scraper && cargo build --release)

if [ ! -f "scraper/target/release/scraper" ]; then
  echo "Erro: Falha na compilação do binário do scraper."
  exit 1
fi

echo "==> Enviando alterações para o repositório..."
git add .
git commit -m "$MESSAGE"
git push

echo "==> Executando deploy automático no servidor remoto..."
ssh root@187.77.43.72 <<'EOF'
cd /srv/imovel-facil
git fetch --all && git reset --hard origin/master
docker compose build
docker compose up -d --remove-orphans
EOF

echo "Deployment concluído com sucesso!"
