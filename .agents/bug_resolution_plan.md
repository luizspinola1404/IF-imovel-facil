# Plano de Resolução de Bug (.agents/bug_resolution_plan.md)

## Descrição do Bug
- **Sintoma**: O projeto Firebase `imoviu-a1fc6` (e URL `https://imoviu-a1fc6.firebaseapp.com/`) foi indevidamente associado ao projeto `LysiaTalkOficial` em arquivos de documentação/configuração anteriores, quando na verdade `imoviu-a1fc6` é o projeto do **Imóvel Fácil / IMOVIU** (plataforma de divulgação de imóveis via QR Code & NFC).
- **Comportamento Esperado**: 
  - `LysiaTalkOficial` deve usar **exclusivamente** o projeto GCP/Firebase `claus-7b33d`.
  - `Imoviu` / `IF-imovel-facil` deve usar **exclusivamente** o projeto GCP/Firebase `imoviu-a1fc6`.

## Causa Raiz Identificada
- Configurações antigas do arquivo `AGENTS.md` (no repositório IF-imovel-facil) misturavam informações do LysiaTalk e do Imoviu, gerando confusão de infraestrutura onde o `imoviu-a1fc6` foi incorretamente citado como se fosse infraestrutura do LysiaTalk.

## Abordagens Tentadas/Consideradas
- Associação de `imoviu-a1fc6` com LysiaTalk (Falhou - Incorreto).
- Re-mapeamento completo da infraestrutura de cada projeto em seus respectivos repositórios e documentações (Solução Proposta).

## Plano de Ação Passo a Passo

1. **Ajustar `IF-imovel-facil/.agents/AGENTS.md`**:
   - Remover qualquer menção ao projeto `LysiaTalkOficial` ou `claus-7b33d`.
   - Definir claramente o contexto do **Imóvel Fácil / IMOVIU** associado ao GCP `imoviu-a1fc6`.
   - Mapear o serviço Cloud Run `imovel-facil-backend` (existente na região `southamerica-east1`) e o novo serviço `imoviu-backend`.

2. **Ajustar `imoviu/.agents/AGENTS.md` e `imoviu/firebase.json`**:
   - Garantir que o repositório `/home/claus/src/imoviu` esteja 100% vinculado ao `imoviu-a1fc6`.
   - Manter a separação total entre os projetos `imoviu` (GCP: `imoviu-a1fc6`) e `LysiaTalk` (GCP: `claus-7b33d`).

3. **Validação**:
   - Confirmar se a documentação e os arquivos de configuração de ambos os projetos refletem a separação estrita de infraestrutura.
