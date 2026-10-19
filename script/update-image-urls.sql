
-- Script de Atualização das URLs de Imagens no PostgreSQL
BEGIN;

UPDATE properties
SET image_urls = replace(
  replace(
    replace(
      image_urls,
      'https://www.luizspinolaimoveis.com.br/storage/imovel-facil/',
      'https://storage.googleapis.com/imoviu-storage/imoveis/'
    ),
    'https://luizspinolaimoveis.com.br/imovel-facil/',
    'https://storage.googleapis.com/imoviu-storage/imoveis/'
  ),
  'http://localhost:9000/imovel-facil/',
  'https://storage.googleapis.com/imoviu-storage/imoveis/'
);

COMMIT;
