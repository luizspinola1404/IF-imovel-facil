import { db, pool } from "../db";
import { prospeccaoBatches, prospeccaoLeads, ProspeccaoLead } from "@shared/schema";
import { eq, and, ne, desc } from "drizzle-orm";

export interface SyncItem {
  id?: string;
  titulo: string;
  link: string;
  fonte?: string;
  trecho?: string;
  direto_proprietario?: boolean;
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

let tablesChecked = false;
async function ensureTablesExist() {
  if (tablesChecked) return;
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS prospeccao_batches (
        id SERIAL PRIMARY KEY,
        batch_id TEXT NOT NULL,
        fonte TEXT NOT NULL DEFAULT 'olx.com.br',
        estado TEXT NOT NULL,
        cidade TEXT NOT NULL,
        tipo TEXT NOT NULL,
        modalidade TEXT NOT NULL,
        total_encontrados INTEGER NOT NULL DEFAULT 0,
        novos_encontrados INTEGER NOT NULL DEFAULT 0,
        removidos_encontrados INTEGER NOT NULL DEFAULT 0,
        created_at TIMESTAMP DEFAULT NOW()
      );

      CREATE TABLE IF NOT EXISTS prospeccao_leads (
        id TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        link TEXT NOT NULL,
        fonte TEXT NOT NULL DEFAULT 'olx.com.br (Particular)',
        trecho TEXT,
        direto_proprietario BOOLEAN NOT NULL DEFAULT TRUE,
        cidade TEXT NOT NULL,
        estado TEXT NOT NULL,
        tipo TEXT NOT NULL,
        modalidade TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        is_new BOOLEAN NOT NULL DEFAULT TRUE,
        first_seen_at TIMESTAMP DEFAULT NOW(),
        last_seen_at TIMESTAMP DEFAULT NOW(),
        last_batch_id TEXT
      );

      CREATE TABLE IF NOT EXISTS prospeccao_cidades_alvo (
        id SERIAL PRIMARY KEY,
        estado TEXT NOT NULL,
        cidade TEXT NOT NULL,
        ativo BOOLEAN NOT NULL DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT NOW()
      );

      CREATE TABLE IF NOT EXISTS prospeccao_config (
        id INTEGER PRIMARY KEY DEFAULT 1,
        polling_schedules JSONB NOT NULL DEFAULT '["08:00", "12:00", "16:00", "20:00"]',
        auto_polling_enabled BOOLEAN NOT NULL DEFAULT TRUE
      );

      INSERT INTO prospeccao_config (id, polling_schedules, auto_polling_enabled)
      VALUES (1, '["08:00", "12:00", "16:00", "20:00"]', true)
      ON CONFLICT (id) DO NOTHING;
    `);
    tablesChecked = true;
  } catch (err) {
    console.error("Erro ao verificar/criar tabelas de prospecção:", err);
  }
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
 * Classifica automaticamente em NOVOS, MANTIDOS e REMOVIDOS.
 */
export async function sincronizarLoteProspeccao(payload: SyncBatchRequest) {
  await ensureTablesExist();

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
    const existing = await db
      .select()
      .from(prospeccaoLeads)
      .where(eq(prospeccaoLeads.id, leadId))
      .limit(1);

    if (existing.length > 0) {
      // Já existia no banco: marca mantido, atualiza horários e batch
      await db
        .update(prospeccaoLeads)
        .set({
          lastSeenAt: now,
          lastBatchId: batchId,
          status: "active",
          isNew: false, // Não é mais novo pois foi reconfirmado
        })
        .where(eq(prospeccaoLeads.id, leadId));
      mantidosEncontrados++;
    } else {
      // Item novo no banco: marca como NOVO
      await db.insert(prospeccaoLeads).values({
        id: leadId,
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
      });
      novosEncontrados++;
    }
  }

  // 2. Identifica imóveis que pertencem a este filtro mas NÃO vieram no lote atual (Removidos da plataforma)
  const ativosAnteriores = await db
    .select()
    .from(prospeccaoLeads)
    .where(
      and(
        eq(prospeccaoLeads.estado, cleanEstado),
        eq(prospeccaoLeads.cidade, cleanCidade),
        eq(prospeccaoLeads.tipo, cleanTipo),
        eq(prospeccaoLeads.modalidade, cleanModalidade),
        ne(prospeccaoLeads.lastBatchId, batchId)
      )
    );

  let removidosEncontrados = 0;
  for (const leadRemovido of ativosAnteriores) {
    if (leadRemovido.status === "active") {
      await db
        .update(prospeccaoLeads)
        .set({ status: "removed" })
        .where(eq(prospeccaoLeads.id, leadRemovido.id));
      removidosEncontrados++;
    }
  }

  // 3. Registra o histórico do lote em prospeccaoBatches
  const [batchRecord] = await db
    .insert(prospeccaoBatches)
    .values({
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
    })
    .returning();

  return {
    batchRecord,
    totalEncontrados: items.length,
    novosEncontrados,
    mantidosEncontrados,
    removidosEncontrados,
  };
}

/**
 * Lista os leads de prospecção salvos e sincronizados no PostgreSQL.
 * Parâmetros opcionais: se nenhum for passado, exibe TODOS os imóveis prospectados.
 */
export async function listarLeadsProspeccao(params?: Partial<BuscaParams>): Promise<ProspeccaoLead[]> {
  await ensureTablesExist();

  try {
    const { estado, cidade, tipo, modalidade, status } = params || {};
    const conditions = [];

    if (estado && estado.trim() && estado.trim().toLowerCase() !== "todos") {
      conditions.push(eq(prospeccaoLeads.estado, estado.trim().toUpperCase()));
    }
    if (cidade && cidade.trim() && cidade.trim().toLowerCase() !== "todas") {
      conditions.push(eq(prospeccaoLeads.cidade, cidade.trim()));
    }
    if (tipo && tipo.trim() && tipo.trim().toLowerCase() !== "todos") {
      conditions.push(eq(prospeccaoLeads.tipo, tipo.trim()));
    }
    if (modalidade && modalidade.trim() && modalidade.trim().toLowerCase() !== "todas") {
      conditions.push(eq(prospeccaoLeads.modalidade, modalidade.trim().toLowerCase()));
    }
    if (status && status.trim() && status.trim().toLowerCase() !== "todos") {
      conditions.push(eq(prospeccaoLeads.status, status.trim()));
    }

    if (conditions.length > 0) {
      return await db
        .select()
        .from(prospeccaoLeads)
        .where(and(...conditions))
        .orderBy(desc(prospeccaoLeads.isNew), desc(prospeccaoLeads.lastSeenAt));
    }

    return await db
      .select()
      .from(prospeccaoLeads)
      .orderBy(desc(prospeccaoLeads.isNew), desc(prospeccaoLeads.lastSeenAt));
  } catch (err) {
    console.error("Erro ao consultar prospeccao_leads:", err);
    return [];
  }
}

/**
 * Exclui um lead específico pelo ID.
 */
export async function excluirLeadProspeccao(id: string) {
  await ensureTablesExist();
  await db.delete(prospeccaoLeads).where(eq(prospeccaoLeads.id, id));
}

/**
 * Atualiza o status do lead (ex: 'tentou_converter', 'active', 'em_atendimento') sem cadastrar imóvel.
 */
export async function atualizarStatusLeadProspeccao(id: string, status: string) {
  await ensureTablesExist();
  await db
    .update(prospeccaoLeads)
    .set({ status, lastSeenAt: new Date() })
    .where(eq(prospeccaoLeads.id, id));
}

/**
 * Limpa todos os leads e lotes de prospecção armazenados.
 */
export async function limparTodosLeadsProspeccao() {
  await ensureTablesExist();
  await pool.query("DELETE FROM prospeccao_leads");
  await pool.query("DELETE FROM prospeccao_batches");
}

/**
 * Retorna a lista de cidades alvo salvas para prospecção remota.
 */
export async function listarCidadesAlvoProspeccao(): Promise<{ estado: string; cidade: string }[]> {
  await ensureTablesExist();
  const res = await pool.query(
    "SELECT estado, cidade FROM prospeccao_cidades_alvo WHERE ativo = true ORDER BY id ASC"
  );

  return res.rows.map((row: any) => ({ estado: row.estado, cidade: row.cidade }));
}

/**
 * Salva e substitui a lista de cidades alvo no banco de dados remoto.
 */
export async function salvarCidadesAlvoProspeccao(cidades: { estado: string; cidade: string }[]) {
  await ensureTablesExist();

  // 1. Identificar quais cidades foram removidas da lista
  const resExistentes = await pool.query("SELECT estado, cidade FROM prospeccao_cidades_alvo WHERE ativo = true");
  const novasChaves = new Set(cidades.map(c => `${c.estado.toUpperCase().trim()}:${c.cidade.trim().toLowerCase()}`));

  for (const row of resExistentes.rows) {
    const key = `${row.estado.toUpperCase().trim()}:${row.cidade.trim().toLowerCase()}`;
    if (!novasChaves.has(key)) {
      console.log(`[PROSPECÇÃO] Cidade removida (${row.cidade}-${row.estado}). Excluindo imóveis associados...`);
      await pool.query(
        "DELETE FROM prospeccao_leads WHERE UPPER(estado) = $1 AND LOWER(cidade) = $2",
        [row.estado.toUpperCase().trim(), row.cidade.trim().toLowerCase()]
      );
    }
  }

  // 2. Atualizar a lista de cidades alvo no servidor
  await pool.query("DELETE FROM prospeccao_cidades_alvo");

  for (const c of cidades) {
    if (c.estado && c.cidade) {
      await pool.query(
        "INSERT INTO prospeccao_cidades_alvo (estado, cidade, ativo) VALUES ($1, $2, true)",
        [c.estado.toUpperCase().trim(), c.cidade.trim()]
      );
    }
  }
}

export async function obterConfigProspeccaoServidor() {
  await ensureTablesExist();
  const resCidades = await pool.query(
    "SELECT estado, cidade FROM prospeccao_cidades_alvo WHERE ativo = true ORDER BY id ASC"
  );
  const resConfig = await pool.query(
    "SELECT polling_schedules, auto_polling_enabled FROM prospeccao_config WHERE id = 1"
  );

  const cidades = resCidades.rows.map((row: any) => ({ estado: row.estado, cidade: row.cidade }));
  const cfgRow = resConfig.rows[0] || {};

  return {
    cidades,
    polling_schedules: cfgRow.polling_schedules || ["08:00", "12:00", "16:00", "20:00"],
    auto_polling_enabled: cfgRow.auto_polling_enabled ?? true,
  };
}

export async function salvarConfigProspeccaoServidor(data: {
  cidades?: { estado: string; cidade: string }[];
  polling_schedules?: string[];
  auto_polling_enabled?: boolean;
}) {
  await ensureTablesExist();
  
  if (Array.isArray(data.cidades)) {
    await salvarCidadesAlvoProspeccao(data.cidades);
  }

  if (Array.isArray(data.polling_schedules) || typeof data.auto_polling_enabled === "boolean") {
    const res = await pool.query("SELECT polling_schedules, auto_polling_enabled FROM prospeccao_config WHERE id = 1");
    const current = res.rows[0] || {};
    const scheds = JSON.stringify(data.polling_schedules || current.polling_schedules || ["08:00", "12:00", "16:00", "20:00"]);
    const autoOpt = data.auto_polling_enabled ?? current.auto_polling_enabled ?? true;

    await pool.query(
      `INSERT INTO prospeccao_config (id, polling_schedules, auto_polling_enabled)
       VALUES (1, $1::jsonb, $2)
       ON CONFLICT (id) DO UPDATE SET polling_schedules = $1::jsonb, auto_polling_enabled = $2`,
      [scheds, autoOpt]
    );
  }
}
