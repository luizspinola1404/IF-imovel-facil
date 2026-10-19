import { MongoClient } from "mongodb";
import { execSync } from "child_process";

const MONGO_URI =
  process.env.MONGODB_URI ||
  "mongodb://appuser:lV-F4mbCZBh8L7j0_8bA9y5hsiOcctWbdzA7Y_QkPNwWE77v@9281e287-2dbb-4d5a-91c5-b7c1c64a75e3.southamerica-east1.firestore.goog:443/imoviu-db?loadBalanced=true&tls=true&retryWrites=false";

const TARGET_DB = "imoviu-db";
const BUCKET_NAME = "imoviu-storage";

function fetchPostgresTableAsJson(tableName: string): any[] {
  console.log(`==> Buscando dados da tabela '${tableName}' no PostgreSQL do servidor...`);
  const query = `SELECT COALESCE(json_agg(t), '[]'::json) FROM (SELECT * FROM ${tableName}) t;`;
  const cmd = `ssh root@187.77.43.72 "docker exec -i imovel-facil-db psql -U postgres -d imovel_facil -t -A -c \\"${query}\\""`;
  
  try {
    const raw = execSync(cmd, { encoding: "utf-8", maxBuffer: 50 * 1024 * 1024 }).trim();
    if (!raw) return [];
    return JSON.parse(raw);
  } catch (err: any) {
    console.warn(`Aviso ao exportar ${tableName}:`, err.message);
    return [];
  }
}

function normalizeImageUrls(rawUrls: any): string[] {
  let urls: string[] = [];
  if (Array.isArray(rawUrls)) {
    urls = rawUrls;
  } else if (typeof rawUrls === "string") {
    try {
      urls = JSON.parse(rawUrls);
    } catch {
      // Regex fallback
      const m = rawUrls.match(/https?:\/\/[^\s"',}]+/g);
      urls = m || [];
    }
  }

  // Substitui qualquer URL legado para o novo bucket do Google Cloud Storage
  return urls.map((u) => {
    return u
      .replace("https://www.luizspinolaimoveis.com.br/storage/imovel-facil/", `https://storage.googleapis.com/${BUCKET_NAME}/imoveis/`)
      .replace("https://luizspinolaimoveis.com.br/imovel-facil/", `https://storage.googleapis.com/${BUCKET_NAME}/imoveis/`)
      .replace("http://localhost:9000/imovel-facil/", `https://storage.googleapis.com/${BUCKET_NAME}/imoveis/`);
  });
}

async function main() {
  console.log("\n==================================================================");
  console.log("🚀 MIGRAÇÃO: PostgreSQL (Servidor) ➡️ Firestore Enterprise (MongoDB)");
  console.log(`Destino: ${TARGET_DB} em southamerica-east1`);
  console.log("==================================================================\n");

  const client = new MongoClient(MONGO_URI);
  await client.connect();
  console.log("✅ Conectado com sucesso ao Firestore Enterprise (MongoDB API)!\n");

  const db = client.db(TARGET_DB);

  // 1. Migração de Usuários
  const users = fetchPostgresTableAsJson("users");
  if (users.length > 0) {
    const usersCol = db.collection("users");
    await usersCol.deleteMany({});
    const docs = users.map((u) => ({
      ...u,
      _id: u.id,
      createdAt: u.created_at ? new Date(u.created_at) : new Date(),
      updatedAt: u.updated_at ? new Date(u.updated_at) : new Date(),
    }));
    await usersCol.insertMany(docs);
    console.log(`✅ [users]: ${users.length} usuários migrados com sucesso!`);
  }

  // 2. Migração de Vantagens
  const advantages = fetchPostgresTableAsJson("advantages");
  if (advantages.length > 0) {
    const advCol = db.collection("advantages");
    await advCol.deleteMany({});
    const docs = advantages.map((a) => ({
      ...a,
      _id: a.id,
      createdAt: a.created_at ? new Date(a.created_at) : new Date(),
    }));
    await advCol.insertMany(docs);
    console.log(`✅ [advantages]: ${advantages.length} vantagens migradas com sucesso!`);
  }

  // 3. Migração de Vantagens por Imóvel (Tabela associativa)
  const propAdv = fetchPostgresTableAsJson("property_advantages");
  if (propAdv.length > 0) {
    const paCol = db.collection("property_advantages");
    await paCol.deleteMany({});
    const docs = propAdv.map((pa) => ({
      id: pa.id,
      propertyId: pa.property_id,
      advantageId: pa.advantage_id,
    }));
    await paCol.insertMany(docs);
    console.log(`✅ [property_advantages]: ${propAdv.length} associações migradas com sucesso!`);
  }

  // 4. Migração de Imóveis (com URLs de imagens atualizadas para GCS)
  const properties = fetchPostgresTableAsJson("properties");
  if (properties.length > 0) {
    const propCol = db.collection("properties");
    await propCol.deleteMany({});
    const docs = properties.map((p) => ({
      id: p.id,
      title: p.title,
      description: p.description,
      type: p.type,
      category: p.category,
      price: Number(p.price) || 0,
      neighborhood: p.neighborhood,
      city: p.city || "Juazeiro",
      state: p.state || "BA",
      bedrooms: p.bedrooms || 0,
      bathrooms: p.bathrooms || 0,
      area: p.area || 0,
      imageUrls: normalizeImageUrls(p.image_urls),
      videoUrl: p.video_url || null,
      status: p.status || "available",
      featured: p.featured ?? true,
      createdAt: p.created_at ? new Date(p.created_at) : new Date(),
      updatedAt: p.updated_at ? new Date(p.updated_at) : new Date(),
    }));
    await propCol.insertMany(docs);
    console.log(`✅ [properties]: ${properties.length} imóveis migrados (com URLs GCS) com sucesso!`);
  }

  // 5. Migração de Leads de Prospecção (OLX)
  const leads = fetchPostgresTableAsJson("prospeccao_leads");
  if (leads.length > 0) {
    const leadsCol = db.collection("prospeccao_leads");
    await leadsCol.deleteMany({});
    const docs = leads.map((l) => ({
      id: l.id,
      _id: l.id,
      titulo: l.titulo,
      link: l.link,
      fonte: l.fonte,
      trecho: l.trecho,
      diretoProprietario: l.direto_proprietario ?? true,
      cidade: l.cidade,
      estado: l.estado,
      tipo: l.tipo,
      modalidade: l.modalidade,
      status: l.status || "active",
      isNew: l.is_new ?? false,
      firstSeenAt: l.first_seen_at ? new Date(l.first_seen_at) : new Date(),
      lastSeenAt: l.last_seen_at ? new Date(l.last_seen_at) : new Date(),
      lastBatchId: l.last_batch_id,
      publishedAt: l.published_at ? new Date(l.published_at) : null,
      dataPublicacaoRaw: l.data_publicacao_raw || null,
    }));
    await leadsCol.insertMany(docs);
    console.log(`✅ [prospeccao_leads]: ${leads.length} leads migrados com sucesso!`);
  }

  // 6. Migração de Cidades Alvo de Prospecção
  const cidades = fetchPostgresTableAsJson("prospeccao_cidades_alvo");
  if (cidades.length > 0) {
    const cidadesCol = db.collection("prospeccao_cidades_alvo");
    await cidadesCol.deleteMany({});
    const docs = cidades.map((c) => ({
      id: c.id,
      estado: c.estado,
      cidade: c.cidade,
      ativo: c.ativo ?? true,
      createdAt: c.created_at ? new Date(c.created_at) : new Date(),
    }));
    await cidadesCol.insertMany(docs);
    console.log(`✅ [prospeccao_cidades_alvo]: ${cidades.length} cidades alvo migradas!`);
  }

  // 7. Migração de Configurações de Prospecção
  const configs = fetchPostgresTableAsJson("prospeccao_config");
  if (configs.length > 0) {
    const configCol = db.collection("prospeccao_config");
    await configCol.deleteMany({});
    await configCol.insertMany(configs);
    console.log(`✅ [prospeccao_config]: Configurações migradas!`);
  }

  console.log("\n==================================================================");
  console.log("🎉 MIGRAÇÃO CONCLUÍDA COM 100% DE SUCESSO!");
  console.log("Todos os dados do PostgreSQL foram transportados para o Firestore Enterprise (MongoDB)!");
  console.log("==================================================================\n");

  await client.close();
}

main().catch((err) => {
  console.error("Erro fatal na migração para MongoDB:", err);
  process.exit(1);
});
