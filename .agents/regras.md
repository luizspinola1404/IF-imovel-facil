# Regras de Negócio e Arquitetura - Fork Fisgando Imóveis (QR Code & NFC)

## 1. Visão Geral do Produto (Fork)
Uma plataforma voltada para captação e apresentação rápida de imóveis através de mídia física (outdoors, placas de venda, painéis e tags NFC). 
O objetivo principal é conectar pessoas que passam na rua/estrada diretamente ao anúncio e formulário de contato/agendamento do corretor com apenas um escaneamento ou aproximação de smartphone (NFC).

### Stack Tecnológica Definida:
- **Backend**: Rust (Axum / Tokio)
- **Template Engine**: Tera
- **Frontend Interativo**: Alpine.js
- **Estilização**: TailwindCSS
- **Banco de Dados**: Firebase Realtime Database (Google) via REST / SDK

---

## 2. Múltiplos Slugs/Códigos por Imóvel (Rastreamento por Bairro / Ponto Físico)

### 2.1. Relação 1-para-Muitos (Vários Slugs/Códigos -> 1 Imóvel)
1. **Atribuição de Múltiplos Códigos/Slugs**:
   - Um único imóvel pode ter **múltiplos slugs ou códigos de rastreamento** associados a ele.
   - *Exemplo*: O imóvel "Casa de Luxo #101" pode responder pelos slugs:
     - `casa-alphaville-placa-rua-a` (Placa no bairro/Rua A)
     - `casa-alphaville-outdoor-avenida-central` (Outdoor na Av. Central)
     - `casa-alphaville-nfc-vitrine` (Tag NFC na vitrine)
2. **Geração e Validação de Unicidade**:
   - O backend gera automaticamente os slugs sugeridos com fallback numérico em caso de duplicidade no banco (`ex: casa-alphaville-1`).
3. **Métricas de Acesso por Código/Slug (Origem da Visita)**:
   - Sempre que o visitante acessa qualquer um dos slugs/códigos vinculados ao imóvel, o sistema identifica qual código exato foi escaneado/acessado.
   - O backend contabiliza a visita especificamente para aquele slug/bairro/localidade, permitindo ao corretor saber exatamente qual placa, outdoor ou bairro gera mais tráfego e interesse.

---

## 3. Fluxo do Lead & Apresentação da Landing Page

### 3.1. Hub Completo do Corretor / Dono
Quando o visitante acessa por qualquer um dos QR Codes/NFCs:
1. É exibida a landing page do imóvel com o padrão visual do Imóvel Fácil.
2. **Hub de Redes Sociais e Contatos**:
   - Exibição de todas as redes sociais cadastradas do corretor/dono (Instagram, WhatsApp direct, YouTube, LinkedIn, E-mail, Telefone).
3. **Vitrine Completa de Imóveis**:
   - Acesso fácil à lista de outros imóveis do corretor.

### 2.2. Parâmetros Obrigatórios no Cadastro do Imóvel (Imoviu)
Ao cadastrar ou editar um imóvel no Imoviu, o formulário deve obrigatoriamente contemplar **todos os parâmetros nativos do Imóvel Fácil** adicionados dos **dados do Vendedor/Corretor**:
1. **Dados do Imóvel (Imóvel Fácil)**:
   - Título do Anúncio
   - Modalidade (Venda / Aluguel)
   - Categoria (Casa, Apartamento, Comercial, Terreno)
   - Valor (R$)
   - CEP / Endereço / Bairro / Cidade / Estado
   - Quartos / Suítes / Banheiros / Vagas de Garagem / Área Útil (m²)
   - Descrição Detalhada & Comodidades/Diferenciais
   - Fotos / Galeria de Imagens & Link de Vídeo (YouTube/Tour)
   - Status (Disponível, Vendido, Alugado)
2. **Dados do Vendedor / Corretor (Adicional Imoviu)**:
   - Nome Completo do Vendedor/Corretor
   - Cargo / Função (Ex: Consultor Imobiliário / Proprietário)
   - Registro CRECI
   - WhatsApp Direto (com mensagem personalizada)
   - Telefone de Contato / E-mail
   - Instagram / Redes Sociais
   - Foto do Vendedor (Avatar)
3. **Identificador NFC / Tag**:
   - Token / Código único da Placa Física ou QR Code (ex: `#nfc-101`)

---

## 4. Modelo Comercial
- Cobranças pelo uso do espaço publicitário em outdoors/placas serão geridas por fora da plataforma.

---

## 5. Próximos Passos
- Documentação atualizada e validada em `.agents/regras.md`.
- Aguardando tag `#implementação` para início dos trabalhos de desenvolvimento e quebra de plano.
