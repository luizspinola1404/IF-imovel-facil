import { mongoDb } from "../db";
import { type ProspeccaoLead } from "@shared/schema";

export interface SyncItem {
  id?: string;
  titulo: string;
  link: string;
  fonte?: string;
  trecho?: string;
  direto_proprietario?: boolean;
  published_at?: string;
  data_publicacao_raw?: string;
}

export interface SyncBatchRequest {
  batchId?: string;
  fonte?: string;
  estado: string;
  cidade: string;
  tipo: string;
  modalidade: string;
  items: SyncItem[];
}

export interface BuscaParams {
  estado?: string;
  cidade?: string;
  tipo?: string;
  modalidade?: string;
  status?: string;
}

function toLead(doc: any): ProspeccaoLead {
  return {
    id: doc.id || String(doc._id),
    titulo: doc.titulo,
    link: doc.link,
    fonte: doc.fonte || "olx.com.br (Particular)",
    trecho: doc.trecho || null,
    diretoProprietario: doc.diretoProprietario ?? doc.direto_proprietario ?? true,
    cidade: doc.cidade,
    estado: doc.estado,
    tipo: doc.tipo,
    modalidade: doc.modalidade,
    status: doc.status || "active",
    isNew: doc.isNew ?? doc.is_new ?? false,
    firstSeenAt: doc.firstSeenAt ? new Date(doc.firstSeenAt) : doc.first_seen_at ? new Date(doc.first_seen_at) : null,
    lastSeenAt: doc.lastSeenAt ? new Date(doc.lastSeenAt) : doc.last_seen_at ? new Date(doc.last_seen_at) : null,
    lastBatchId: doc.lastBatchId || doc.last_batch_id || null,
    publishedAt: doc.publishedAt ? new Date(doc.publishedAt) : doc.published_at ? new Date(doc.published_at) : null,
    dataPublicacaoRaw: doc.dataPublicacaoRaw || doc.data_publicacao_raw || null,
  };
}

function gerarId(titulo: string, link: string): string {
  const raw = `${titulo}${link}`;
  let hash = 0;
  for (let i = 0; i < raw.length; i++) {
    const char = raw.charCodeAt(i);
    hash = (hash << 5) - hash + char;
    hash |= 0;
  }
  return Math.abs(hash).toString(16);
}

/**
 * Processa a sincronização de lote enviada pelo Agente Desktop ou Navegador.
 * Classifica automaticamente em NOVOS, MANTIDOS e REMOVIDOS no MongoDB.
 */
export async function sincronizarLoteProspeccao(payload: SyncBatchRequest) {
  const colLeads = mongoDb.collection("prospeccao_leads");
  const colBatches = mongoDb.collection("prospeccao_batches");

  const {
    batchId = `batch-${Date.now()}`,
    fonte = "olx.com.br",
    estado,
    cidade,
    tipo,
    modalidade,
    items = [],
  } = payload;

  const cleanEstado = estado.trim().toUpperCase();
  const cleanCidade = cidade.trim();
  const cleanTipo = tipo.trim();
  const cleanModalidade = modalidade.trim().toLowerCase();

  let novosEncontrados = 0;
  let mantidosEncontrados = 0;
  const now = new Date();

  // 1. Processa cada item enviado no lote
  for (const item of items) {
    const leadId = item.id || gerarId(item.titulo, item.link);
    const pubDate = item.published_at ? new Date(item.published_at) : null;

    const existing = await colLeads.findOne({ id: leadId });
    if (existing) {
      await colLeads.updateOne(
        { id: leadId },
        {
          $set: {
            lastSeenAt: now,
            lastBatchId: batchId,
            status: "active",
            isNew: false,
            publishedAt: pubDate || existing.publishedAt || null,
            dataPublicacaoRaw: item.data_publicacao_raw || existing.dataPublicacaoRaw || null,
          },
        }
      );
      mantidosEncontrados++;
    } else {
      await colLeads.insertOne({
        id: leadId,
        _id: leadId as any,
        titulo: item.titulo,
        link: item.link,
        fonte: item.fonte || `${fonte} (Particular)`,
        trecho: item.trecho || `Imóvel particular em ${cleanCidade}-${cleanEstado}.`,
        diretoProprietario: item.direto_proprietario ?? true,
        cidade: cleanCidade,
        estado: cleanEstado,
        tipo: cleanTipo,
        modalidade: cleanModalidade,
        status: "active",
        isNew: true,
        firstSeenAt: now,
        lastSeenAt: now,
        lastBatchId: batchId,
        publishedAt: pubDate,
        dataPublicacaoRaw: item.data_publicacao_raw || null,
      });
      novosEncontrados++;
    }
  }

  // 2. Identifica imóveis que pertencem a este filtro mas NÃO vieram no lote atual (Removidos da plataforma)
  const removidosRes = await colLeads.updateMany(
    {
      estado: cleanEstado,
      cidade: cleanCidade,
      tipo: cleanTipo,
      modalidade: cleanModalidade,
      lastBatchId: { $ne: batchId },
      status: "active",
    },
    {
      $set: { status: "removed" },
    }
  );
  const removidosEncontrados = removidosRes.modifiedCount || 0;

  // 3. Registra o histórico do lote em prospeccao_batches
  const batchRecord = {
    batchId,
    fonte,
    estado: cleanEstado,
    cidade: cleanCidade,
    tipo: cleanTipo,
    modalidade: cleanModalidade,
    totalEncontrados: items.length,
    novosEncontrados,
    removidosEncontrados,
    createdAt: now,
  };
  await colBatches.insertOne(batchRecord);

  return {
    batchRecord,
    totalEncontrados: items.length,
    novosEncontrados,
    mantidosEncontrados,
    removidosEncontrados,
  };
}

/**
 * Lista os leads de prospecção salvos e sincronizados no MongoDB.
 * Parâmetros opcionais: se nenhum for passado, exibe TODOS os imóveis prospectados.
 * Ordenados pelo anúncio mais recente (publishedAt DESC).
 */
export async function listarLeadsProspeccao(params?: Partial<BuscaParams>): Promise<ProspeccaoLead[]> {
  try {
    const { estado, cidade, tipo, modalidade, status } = params || {};
    const query: any = {};

    if (estado && estado.trim() && estado.trim().toLowerCase() !== "todos") {
      query.estado = estado.trim().toUpperCase();
    }
    if (cidade && cidade.trim() && cidade.trim().toLowerCase() !== "todas") {
      query.cidade = cidade.trim();
    }
    if (tipo && tipo.trim() && tipo.trim().toLowerCase() !== "todos") {
      query.tipo = tipo.trim();
    }
    if (modalidade && modalidade.trim() && modalidade.trim().toLowerCase() !== "todas") {
      query.modalidade = modalidade.trim().toLowerCase();
    }
    if (status && status.trim() && status.trim().toLowerCase() !== "todos") {
      query.status = status.trim();
    }

    const docs = await mongoDb
      .collection("prospeccao_leads")
      .find(query)
      .sort({ publishedAt: -1, lastSeenAt: -1 })
      .toArray();

    return docs.map(toLead);
  } catch (err) {
    console.error("Erro ao consultar prospeccao_leads:", err);
    return [];
  }
}

/**
 * Exclui um lead específico pelo ID.
 */
export async function excluirLeadProspeccao(id: string) {
  await mongoDb.collection("prospeccao_leads").deleteOne({ id });
}

/**
 * Atualiza o status do lead (ex: 'tentou_converter', 'active', 'em_atendimento') sem cadastrar imóvel.
 */
export async function atualizarStatusLeadProspeccao(id: string, status: string) {
  await mongoDb.collection("prospeccao_leads").updateOne(
    { id },
    { $set: { status, lastSeenAt: new Date() } }
  );
}

/**
 * Limpa todos os leads e lotes de prospecção armazenados.
 */
export async function limparTodosLeadsProspeccao() {
  await mongoDb.collection("prospeccao_leads").deleteMany({});
  await mongoDb.collection("prospeccao_batches").deleteMany({});
}

/**
 * Retorna a lista de cidades alvo salvas para prospecção remota.
 */
export async function listarCidadesAlvoProspeccao(): Promise<{ estado: string; cidade: string }[]> {
  const docs = await mongoDb
    .collection("prospeccao_cidades_alvo")
    .find({ ativo: { $ne: false } })
    .sort({ id: 1 })
    .toArray();

  return docs.map((row: any) => ({ estado: row.estado, cidade: row.cidade }));
}

/**
 * Salva e substitui a lista de cidades alvo no banco de dados.
 */
export async function salvarCidadesAlvoProspeccao(cidades: { estado: string; cidade: string }[]) {
  const colCidades = mongoDb.collection("prospeccao_cidades_alvo");
  const colLeads = mongoDb.collection("prospeccao_leads");

  // 1. Identificar quais cidades foram removidas da lista
  const existentes = await colCidades.find({ ativo: { $ne: false } }).toArray();
  const novasChaves = new Set(cidades.map(c => `${c.estado.toUpperCase().trim()}:${c.cidade.trim().toLowerCase()}`));

  for (const row of existentes) {
    const key = `${row.estado.toUpperCase().trim()}:${row.cidade.trim().toLowerCase()}`;
    if (!novasChaves.has(key)) {
      console.log(`[PROSPECÇÃO] Cidade removida (${row.cidade}-${row.estado}). Excluindo imóveis associados...`);
      await colLeads.deleteMany({
        estado: row.estado.toUpperCase().trim(),
        cidade: row.cidade.trim(),
      });
    }
  }

  // 2. Atualizar a lista de cidades alvo no servidor
  await colCidades.deleteMany({});

  let nextId = 1;
  const docsToInsert = cidades
    .filter(c => c.estado && c.cidade)
    .map(c => ({
      id: nextId++,
      estado: c.estado.toUpperCase().trim(),
      cidade: c.cidade.trim(),
      ativo: true,
      createdAt: new Date(),
    }));

  if (docsToInsert.length > 0) {
    await colCidades.insertMany(docsToInsert);
  }
}

export async function obterConfigProspeccaoServidor() {
  const cidades = await listarCidadesAlvoProspeccao();
  const cfgDoc = (await mongoDb.collection("prospeccao_config").findOne({ id: 1 })) as any;

  return {
    cidades,
    polling_schedules: cfgDoc?.polling_schedules || ["08:00", "12:00", "16:00", "20:00"],
    auto_polling_enabled: cfgDoc?.auto_polling_enabled ?? true,
  };
}

export async function salvarConfigProspeccaoServidor(data: {
  cidades?: { estado: string; cidade: string }[];
  polling_schedules?: string[];
  auto_polling_enabled?: boolean;
}) {
  if (Array.isArray(data.cidades)) {
    await salvarCidadesAlvoProspeccao(data.cidades);
  }

  if (Array.isArray(data.polling_schedules) || typeof data.auto_polling_enabled === "boolean") {
    const colConfig = mongoDb.collection("prospeccao_config");
    const current = ((await colConfig.findOne({ id: 1 })) || {}) as any;
    const scheds = data.polling_schedules || current.polling_schedules || ["08:00", "12:00", "16:00", "20:00"];
    const autoOpt = data.auto_polling_enabled ?? current.auto_polling_enabled ?? true;

    await colConfig.updateOne(
      { id: 1 },
      { $set: { id: 1, polling_schedules: scheds, auto_polling_enabled: autoOpt } },
      { upsert: true }
    );
  }
}

export { listarLeadsProspeccao as buscarImoveisProspeccao };
