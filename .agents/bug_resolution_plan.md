# Plano de Resolução de Bug (.agents/bug_resolution_plan.md)

## Descrição do Bug
- **Sintoma**: `https://imoviu-a1fc6.firebaseapp.com/` exibia o dashboard do LysiaTalk em vez do Imóvel Fácil.
- **Comportamento Esperado**: O site deve exibir a plataforma Imóvel Fácil.

## Causa Raiz Identificada
- O serviço Cloud Run `imovel-facil-backend` no GCP `imoviu-a1fc6` estava rodando a imagem Docker **errada**: `gcr.io/imoviu-a1fc6/lysiatalk:latest` em vez de `gcr.io/imoviu-a1fc6/imovel-facil-backend:latest`.
- O Firebase Hosting faz rewrite de `/` para o Cloud Run, que respondia com o LysiaTalk.

## Abordagens Tentadas/Consideradas
- Ajustar apenas documentação/AGENTS.md (Insuficiente - o problema era na imagem Docker do Cloud Run).
- Re-deploy apenas do Firebase Hosting estático (Insuficiente - o rewrite encaminha para o Cloud Run).
- **Build local + push + update da imagem Docker correta no Cloud Run (SOLUÇÃO DEFINITIVA)**.

## Resolução Aplicada
1. `docker build -t gcr.io/imoviu-a1fc6/imovel-facil-backend:latest .` (build local)
2. `docker push gcr.io/imoviu-a1fc6/imovel-facil-backend:latest`
3. `gcloud run services update imovel-facil-backend --image=gcr.io/imoviu-a1fc6/imovel-facil-backend:latest`
4. Revision `imovel-facil-backend-00006-cjr` deployada servindo 100% do tráfego.

## Status: ✅ RESOLVIDO
