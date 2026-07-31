import { db } from "../db";
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
  const { estado, cidade, tipo, modalidade, status } = params || {};

  const conditions = [];

  if (estado && estado.trim()) {
    conditions.push(eq(prospeccaoLeads.estado, estado.trim().toUpperCase()));
  }
  if (cidade && cidade.trim()) {
    conditions.push(eq(prospeccaoLeads.cidade, cidade.trim()));
  }
  if (tipo && tipo.trim() && tipo.trim().toLowerCase() !== "todos") {
    conditions.push(eq(prospeccaoLeads.tipo, tipo.trim()));
  }
  if (modalidade && modalidade.trim() && modalidade.trim().toLowerCase() !== "todos") {
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
}
