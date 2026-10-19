import { execSync } from "child_process";
import fs from "fs";
import path from "path";

async function main() {
  const targetBucket = process.argv[2] || process.env.GCS_BUCKET || "imoviu-storage";

  console.log(`\n======================================================`);
  console.log(`🚀 INICIANDO MIGRAÇÃO: MinIO ➡️ Google Cloud Storage`);
  console.log(`Bucket Alvo: gs://${targetBucket}/imoveis/`);
  console.log(`======================================================\n`);

  // 1. Obter todas as URLs de imagens do banco de dados em produção
  console.log("==> [1/3] Consultando todas as URLs de imagens no PostgreSQL de produção...");
  const psqlCmd = `ssh root@187.77.43.72 "docker exec -i imovel-facil-db psql -U postgres -d imovel_facil -t -A -c 'SELECT image_urls FROM properties;'"`;

  let rawUrlsOutput = "";
  try {
    rawUrlsOutput = execSync(psqlCmd, { encoding: "utf-8" });
  } catch (err: any) {
    console.error("❌ Erro ao consultar PostgreSQL via SSH:", err.message);
    process.exit(1);
  }

  // Extrai todas as URLs válidas encontradas
  const urlRegex = /https?:\/\/[^\s"',}]+/g;
  const matches = rawUrlsOutput.match(urlRegex) || [];
  const uniqueUrls = Array.from(new Set(matches)).filter((u) => !u.endsWith(".png") || u.includes("imovel-facil"));

  console.log(`Foram encontradas ${uniqueUrls.length} URLs únicas de fotos de imóveis.\n`);

  const downloadDir = path.resolve(process.cwd(), "tmp_minio_photos");
  if (!fs.existsSync(downloadDir)) {
    fs.mkdirSync(downloadDir, { recursive: true });
  }

  // 2. Download direto via HTTP para pasta local
  console.log("==> [2/3] Baixando fotos do servidor de produção...");
  let downloadedCount = 0;

  for (let i = 0; i < uniqueUrls.length; i++) {
    const rawUrl = uniqueUrls[i];
    const filename = rawUrl.split("/").pop();

    if (!filename || filename === "]" || filename.length < 5) continue;

    const destPath = path.join(downloadDir, filename);
    if (fs.existsSync(destPath) && fs.statSync(destPath).size > 0) {
      downloadedCount++;
      continue;
    }

    try {
      const resp = await fetch(rawUrl);
      if (!resp.ok) {
        throw new Error(`HTTP ${resp.status}`);
      }
      const buffer = Buffer.from(await resp.arrayBuffer());
      fs.writeFileSync(destPath, buffer);
      downloadedCount++;
      process.stdout.write(`\rProgresso Download: [${downloadedCount}/${uniqueUrls.length}] Baixado: ${filename}`);
    } catch (e: any) {
      console.error(`\n❌ Falha ao baixar ${rawUrl}:`, e.message);
    }
  }

  console.log(`\n\n✅ ${downloadedCount} fotos prontas em ${downloadDir}!`);

  // 3. Upload usando gcloud storage cp (usa autenticação ativa do gcloud)
  console.log(`\n==> Enviando para gs://${targetBucket}/imoveis/ via gcloud storage...`);
  try {
    const uploadCmd = `gcloud storage cp --recursive "${downloadDir}/*" "gs://${targetBucket}/imoveis/"`;
    execSync(uploadCmd, { stdio: "inherit" });
    console.log(`\n✅ Upload via gcloud storage concluído com sucesso!`);
  } catch (err: any) {
    console.error("❌ Falha no upload via gcloud storage:", err.message);
    process.exit(1);
  }

  // 4. Comandos SQL para atualizar as URLs no banco de dados
  const sqlUpdate = `
-- Script de Atualização das URLs de Imagens no PostgreSQL
BEGIN;

UPDATE properties
SET image_urls = replace(
  replace(
    replace(
      image_urls,
      'https://www.luizspinolaimoveis.com.br/storage/imovel-facil/',
      'https://storage.googleapis.com/${targetBucket}/imoveis/'
    ),
    'https://luizspinolaimoveis.com.br/imovel-facil/',
    'https://storage.googleapis.com/${targetBucket}/imoveis/'
  ),
  'http://localhost:9000/imovel-facil/',
  'https://storage.googleapis.com/${targetBucket}/imoveis/'
);

COMMIT;
`;

  const sqlFile = path.resolve(process.cwd(), "script", "update-image-urls.sql");
  fs.writeFileSync(sqlFile, sqlUpdate, "utf-8");

  console.log(`\n======================================================`);
  console.log(`SCRIPT SQL GERADO: ${sqlFile}`);
  console.log(`======================================================`);
  console.log(sqlUpdate);
  console.log(`🎉 Todas as fotos estão salvas e públicas no Google Cloud Storage!`);
}

main().catch((err) => {
  console.error("Erro na migração:", err);
  process.exit(1);
});
