# Plano de Resolução de Bug (.agents/bug_resolution_plan.md)

## Descrição do Bug
- **Sintoma**: O projeto Firebase `imoviu-a1fc6` estava indevidamente associado ao projeto `imoviu` (fork), quando na verdade `imoviu-a1fc6` pertence **exclusivamente** ao **Imóvel Fácil (`IF-imovel-facil`)** (`https://imoviu-a1fc6.firebaseapp.com/`).
- **Comportamento Esperado**: 
  - `IF-imovel-facil` mantém a posse exclusiva do GCP/Firebase `imoviu-a1fc6` e do Cloud Run `imovel-facil-backend`.
  - `imoviu` (fork) utilizará um projeto GCP/Firebase próprio e dedicado a ser definido/criado.

## Causa Raiz Identificada
- Houve uma sobreposição nos arquivos de configuração ao atribuir o `imoviu-a1fc6` para o novo projeto Imoviu.

## Abordagens Tentadas/Consideradas
- Compartilhar `imoviu-a1fc6` entre ambos os projetos (Descartado - O Imóvel Fácil é o dono do `imoviu-a1fc6`).
- Manter `imoviu-a1fc6` 100% exclusivo no Imóvel Fácil e desvincular do Imoviu (Solução Adotada).

## Plano de Ação Passo a Passo

1. **Fixar `IF-imovel-facil` no Firebase `imoviu-a1fc6`**:
   - Atualizado `.agents/AGENTS.md` no Imóvel Fácil definindo a posse exclusiva do `imoviu-a1fc6` e Cloud Run `imovel-facil-backend`.

2. **Desvincular `imoviu-a1fc6` do Fork Imoviu**:
   - Atualizar a documentação do projeto `/home/claus/src/imoviu` para aguardar a definição do novo ID de projeto Firebase/GCP dedicado ao Imoviu.

3. **Validação**:
   - Confirmar que o Imóvel Fácil é o único responsável pelo `imoviu-a1fc6` e seu Firebase Hosting `https://imoviu-a1fc6.firebaseapp.com/`.
