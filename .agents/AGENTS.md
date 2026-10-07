# Regras do Projeto - Imóvel Fácil (IF-imovel-facil)

## 0. Sistema Estrito de Tags
O modo de trabalho da IA é estritamente controlado por **Tags** e só mudará quando uma nova tag for informada. **Se o usuário enviar uma nova solicitação sem nenhuma tag, a IA DEVE considerar automaticamente essa solicitação sob o contexto da última tag utilizada.**

## Contexto Tecnológico e Infraestrutura do Projeto (Imóvel Fácil)
- **Nome do Projeto**: IF-imovel-facil (Plataforma Imóvel Fácil)
- **Linguagem**: Node.js / TypeScript + Python / Tauri
- **Banco de Dados**: PostgreSQL / Firebase Realtime Database
- **Frontend / Interface**: React / Vite / TailwindCSS

### 📌 Mapeamento Estrito de Serviços Nuvem e Repositório (IMÓVEL FÁCIL)
- **Google Cloud Platform (GCP Project ID)**: `imoviu-a1fc6`
- **Serviço Google Cloud Run**: `imovel-facil-backend`
- **Região Cloud Run**: `southamerica-east1`
- **Container Registry / Image Tag**: `gcr.io/imoviu-a1fc6/imovel-facil-backend:latest`
- **Banco de Dados (Firebase Realtime Database)**: `https://imoviu-a1fc6-default-rtdb.firebaseio.com/`
- **Firebase Hosting**: Projeto `imoviu-a1fc6` (`https://imoviu-a1fc6.firebaseapp.com/`)

## 2. Protocolo de Implementação de Funcionalidades (#implementação)
- Sempre que receber a tag `#implementação`, crie uma nova branch git (`git checkout -b feature/<nome>`), crie o plano `.agents/implementacao.md` com checklist, e execute **UM subproblema por turno**.

## 9. Padrão Estrito de Arquivos Markdown na Pasta `.agents/`
- `.agents/implementacao.md`
- `.agents/regras.md`
- `.agents/bug_resolution_plan.md`
- `.agents/testes.md`

## 11. Protocolo de Alteração Rápida (#rapido)
- Aplicação direta de alterações sem necessidade de planos longos.

## 12. Proibição Estrita de Compilação Remota (Builds 100% Locais)
- Builds de imagens Docker devem ser efetuadas **100% locais** e enviadas via `docker push`.
