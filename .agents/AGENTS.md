# Regras de Modificação de Código e Diagnóstico de Erros

- **Diagnóstico Prévio**: Nunca modifique o código-fonte sem antes realizar um diagnóstico detalhado do erro.
- **Plano de Implementação**: Sempre crie um plano de implementação detalhado explicando a causa do erro e a solução proposta. Use o modo de planejamento (Planning Mode).
- **Aprovação**: Sempre aguarde a aprovação explícita do usuário no plano de implementação antes de realizar qualquer alteração no código.

# Regras do Projeto - Imóvel Fácil (IF-imovel-facil)

## 0. Sistema Estrito de Tags
O modo de trabalho da IA é estritamente controlado por **Tags** e só mudará quando uma nova tag for informada. **Se o usuário enviar uma nova solicitação sem nenhuma tag, a IA DEVE considerar automaticamente essa solicitação sob o contexto da última tag utilizada.**

## 1. Protocolo de Resolução de Bugs (Análise & Planejamento):
Sempre que o usuário enviar uma mensagem contendo a tag **`#bug`**, siga estritamente o seguinte fluxo antes de alterar qualquer código:

1. **Proibição de Código Imediato**: NUNCA escreva, edite ou altere código-fonte antes de concluir a análise e registrar o plano no arquivo de documentação. É estritamente PROIBIDO alterar arquivos de código no mesmo turno/resposta em que o plano `.agents/bug_resolution_plan.md` for criado.
2. **Exigência de Dados Reais**: Se a mensagem inicial não contiver logs de erro, tracebacks ou payloads reais (JSON), a IA DEVE pausar e solicitar essas evidências antes de continuar. Nenhuma suposição deve ser feita.
3. **Análise de Causa Raiz e Histórico**: Investigue exaustivamente todas as possíveis causas do erro, baseando-se estritamente nas evidências reais fornecidas. **A IA DEVE obrigatoriamente analisar o arquivo `.agents/bug_resolution_plan.md` pré-existente ou o histórico da conversa para verificar se é um bug reincidente.**
4. **Criação Obrigatória do Plano ANTES de Alterar Código (`.agents/bug_resolution_plan.md`)**:
   - O arquivo DEVE conter a causa raiz, abordagens consideradas e o plano de ação.
5. **Pausa Obrigatória para Apresentação do Plano**.

## Contexto Tecnológico e Infraestrutura do Projeto (Imóvel Fácil)
- **Nome do Projeto**: IF-imovel-facil (Plataforma Imóvel Fácil)
- **Linguagem**: Node.js / TypeScript + Python / Tauri
- **Banco de Dados**: PostgreSQL / Firebase Realtime Database
- **Frontend / Interface**: React / Vite / TailwindCSS

### 📌 Mapeamento Estrito de Serviços Nuvem e Repositório (IMOVIU / IMÓVEL FÁCIL)
- **Google Cloud Platform (GCP Project ID)**: `imoviu-a1fc6` *(NÃO misturar com claus-7b33d do LysiaTalk)*
- **Serviço Google Cloud Run Existente**: `imovel-facil-backend`
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
