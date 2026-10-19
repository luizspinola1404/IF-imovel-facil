# Plano de Implementação: Ficha Completa do Imóvel no próprio Imoviu

## Contexto
Ajustar a arquitetura de páginas do **Imoviu** para que a **Ficha Completa do Imóvel** seja renderizada internamente no próprio app Rust (em `/imovel/:id`), em vez de redirecionar para um link externo.

Ao aproximar a tag NFC ou ler o QR Code (`/q/:token`), o usuário vê o Card de Apresentação e o botão de CTA leva para a rota interna da **Ficha Completa no Imoviu** (`/imovel/:id`), contendo a galeria completa de fotos, mapa, descrição detalhada, comodidades e formulário de contato com o corretor.

## 📋 Checklist de Subproblemas (Executar UM por turno)

- [x] **1. Criação do Template da Ficha Completa (`templates/property_detail.html`)**
  - Desenvolver uma página de detalhes completa do imóvel dentro do próprio Imoviu (Galeria de Fotos em Carousel/Grid, Mapa, Características/Comodidades, Simulador de Financiamento/Contato).
  - Manter o padrão visual do Imóvel Fácil (Paleta Royal Blue + Accent Gold).

- [x] **2. Rota Interna `/imovel/:id` no Rust (Axum)**
  - Adicionar a rota `/imovel/:id` no `src/main.rs`.
  - Atualizar o botão de CTA na landing page NFC (`templates/property_nfc.html`) para apontar diretamente para `/imovel/{{ token }}`.

- [x] **3. Build Local e Deploy no Cloud Run (`imoviu-backend`)**
  - Fazer o build 100% local do container com a nova rota e templates.
  - Atualizar o Cloud Run e testar a navegação completa.

---
**Status**: CONCLUÍDO
https://imoviu-backend-939027583445.southamerica-east1.run.app/dashboard