@echo off
setlocal
if "%~1"=="" (
    echo [ERRO] Forneça uma mensagem de commit.
    exit /b 1
)

set MESSAGE=%~1

echo === [DEPLOY COMPLETO] Enviando alterações para o GitHub ===
git add . && git commit -m "%MESSAGE%" && git push
if %errorlevel% neq 0 (
    echo [ERRO] Falha ao enviar para o GitHub. Abortando deploy.
    exit /b 1
)

echo === Disparando compilação do Agente Windows (.exe) no GitHub Actions ===
gh workflow run build-desktop-agent.yml --ref master

echo === Conectando ao servidor e atualizando Docker ===
ssh root@187.77.43.72 "cd /srv/imovel-facil && git fetch --all && git reset --hard origin/master && docker compose up --build -d"

echo === Deploy do site e compilação do Agente finalizados com sucesso! ===
endlocal
