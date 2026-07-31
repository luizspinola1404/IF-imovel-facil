import axios from "axios";
import * as cheerio from "cheerio";
import { execFile } from "child_process";
import path from "path";
import fs from "fs";

export interface ScraperResult {
  id: string;
  titulo: string;
  link: string;
  fonte: string;
  trecho: string;
  direto_proprietario: boolean;
  cidade: string;
  estado: string;
  tipo: string;
  modalidade: string;
}

interface BuscaParams {
  estado: string;
  cidade: string;
  tipo: string;
  modalidade: string;
}

const DIRETO_KEYWORDS = [
  "proprietário",
  "proprietario",
  "dono",
  "direto",
  "particular",
  "sem corretor",
  "sem imobiliária",
  "sem imobiliaria",
  "estou vendendo",
  "estou vendendo meu",
  "estou alugando",
  "estou alugando meu",
  "vendo direto",
  "alugo direto",
  "vendo proprietário",
  "alugo proprietário",
  "direto com proprietário",
  "direto com dono",
  "venda particular",
  "locação particular",
  "anúncio particular",
  "tratar direto",
  "contato direto",
  "imóvel direto",
  "direto com o dono",
  "direto do proprietário",
  "vendo urgente",
  "alugo urgente",
  "particular vende",
  "particular aluga",
];

function classificarDireto(texto: string): boolean {
  const lower = texto.toLowerCase();
  return DIRETO_KEYWORDS.some((kw) => lower.includes(kw));
}

function extrairFonte(urlStr: string): string {
  try {
    const clean = urlStr.replace(/^https?:\/\//, "");
    const parts = clean.split("/");
    if (parts.length > 0) {
      return parts[0].replace(/^www\./, "");
    }
  } catch {
    // fallback
  }
  return "Web";
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

function extrairUrlReal(link: string): string {
  if (link.includes("uddg=")) {
    try {
      const match = link.match(/uddg=([^&]+)/);
      if (match && match[1]) {
        return decodeURIComponent(match[1]);
      }
    } catch {
      // ignore
    }
  }
  return link;
}

function normalizarTexto(texto: string): string {
  return texto
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9\s-]/g, "")
    .trim()
    .replace(/\s+/g, "-");
}

const USER_AGENTS = [
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36",
  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
];

function getRandomUserAgent(): string {
  return USER_AGENTS[Math.floor(Math.random() * USER_AGENTS.length)];
}

/**
 * Busca via DuckDuckGo HTML
 */
async function buscarDuckDuckGo(params: BuscaParams): Promise<ScraperResult[]> {
  const { estado, cidade, tipo, modalidade } = params;
  const results: ScraperResult[] = [];

  const queryTerm = `"${tipo}" "${modalidade}" "${cidade}" "${estado}" ("direto com proprietario" OR "particular" OR "sem corretor" OR "direto proprietario")`;
  const url = `https://html.duckduckgo.com/html/?q=${encodeURIComponent(queryTerm)}&kl=br-pt`;

  try {
    const response = await axios.get(url, {
      headers: {
        "User-Agent": getRandomUserAgent(),
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        "Accept-Language": "pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7",
      },
      timeout: 7000,
    });

    const $ = cheerio.load(response.data);

    $(".result").each((_, el) => {
      const titleEl = $(el).find(".result__a");
      const title = titleEl.text().trim();
      const rawLink = titleEl.attr("href") || "";

      if (!title || !rawLink) return;

      let realLink = extrairUrlReal(rawLink);
      if (realLink.startsWith("//")) {
        realLink = `https:${realLink}`;
      }

      if (
        realLink.includes("duckduckgo.com") ||
        realLink.startsWith("/") ||
        realLink.toLowerCase().includes("proprietariodireto.com.br")
      ) {
        return;
      }

      const snippet = $(el).find(".result__snippet").text().trim();
      const isDirect = classificarDireto(title) || classificarDireto(snippet);
      const source = extrairFonte(realLink);
      const id = gerarId(title, realLink);

      results.push({
        id,
        titulo: title,
        link: realLink,
        fonte: source,
        trecho: snippet,
        direto_proprietario: isDirect,
        cidade,
        estado,
        tipo,
        modalidade,
      });
    });
  } catch (err) {
    console.error("Erro no DuckDuckGo Direct Scraper:", (err as Error).message);
  }

  return results;
}

/**
 * Busca / Gerador para OLX Vendedor Particular
 */
async function buscarOLXParticular(params: BuscaParams): Promise<ScraperResult[]> {
  const { estado, cidade, tipo, modalidade } = params;
  const results: ScraperResult[] = [];

  const cleanState = estado.toLowerCase();
  const cleanCity = normalizarTexto(cidade);
  const cleanTipo = normalizarTexto(tipo);
  const mode = modalidade.toLowerCase() === "aluguel" ? "aluguel" : "venda";

  // OLX URL structure for particular sellers (f=p)
  const olxUrl = `https://www.olx.com.br/imoveis/${mode}/${cleanTipo}/estado-${cleanState}/${cleanCity}?f=p`;

  try {
    const response = await axios.get(olxUrl, {
      headers: {
        "User-Agent": getRandomUserAgent(),
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "pt-BR,pt;q=0.9",
      },
      timeout: 5000,
    });

    const $ = cheerio.load(response.data);

    // Parse OLX ad items if present in HTML
    $('[data-lurker-detail="list_id"]').each((_, el) => {
      const title = $(el).find("h2").text().trim() || $(el).attr("title") || "";
      const rawLink = $(el).find("a").attr("href") || "";
      const price = $(el).find('[aria-label*="Preço"]').text().trim() || "";

      if (title && rawLink) {
        const link = rawLink.startsWith("http") ? rawLink : `https://www.olx.com.br${rawLink}`;
        const snippet = `Imóvel particular anunciado na OLX em ${cidade}-${estado}.${price ? ` Preço: ${price}` : ""}`;

        results.push({
          id: gerarId(title, link),
          titulo: title,
          link,
          fonte: "olx.com.br (Particular)",
          trecho: snippet,
          direto_proprietario: true,
          cidade,
          estado,
          tipo,
          modalidade,
        });
      }
    });
  } catch {
    // If OLX blocks or returns challenge, we return a curated direct search link card for OLX particular
  }

  // Fallback: If no direct items extracted, provide the official filtered OLX link
  if (results.length === 0) {
    results.push({
      id: `olx-particular-custom-${cleanCity}`,
      titulo: `OLX - Anúncios de Proprietários Particulares (${tipo} em ${cidade}-${estado})`,
      link: olxUrl,
      fonte: "olx.com.br",
      trecho: `Acessar anúncios filtrados exclusivamente para Vendedores Particulares (Sem Imobiliária) para ${tipo} para ${modalidade} em ${cidade}-${estado}.`,
      direto_proprietario: true,
      cidade,
      estado,
      tipo,
      modalidade,
    });
  }

  return results;
}

export async function executarScraperRust(params: BuscaParams): Promise<ScraperResult[]> {
  const binaryPath = path.join(process.cwd(), "scraper/target/release/scraper");
  if (!fs.existsSync(binaryPath)) {
    throw new Error(`Scraper binary not found at ${binaryPath}`);
  }

  return new Promise((resolve, reject) => {
    execFile(
      binaryPath,
      ["--cidade", params.cidade, "--estado", params.estado, "--tipo", params.tipo, "--modalidade", params.modalidade],
      { timeout: 60000, maxBuffer: 10 * 1024 * 1024 },
      (error, stdout, stderr) => {
        if (error) {
          console.error("Erro executando scraper Rust:", stderr || error.message);
          return reject(error);
        }
        try {
          const results: ScraperResult[] = JSON.parse(stdout);
          resolve(results);
        } catch (parseErr) {
          console.error("Erro ao interpretar JSON do scraper Rust:", parseErr);
          reject(parseErr);
        }
      }
    );
  });
}

/**
 * Função Principal de Prospecção que agrega múltiplas fontes
 */
export async function buscarImoveisProspeccao(params: BuscaParams): Promise<ScraperResult[]> {
  const { estado, cidade, tipo, modalidade } = params;

  // 1. Tenta executar o scraper Rust nativo (thirtyfour) se não estiver em ambiente de testes unitários
  if (!process.env.VITEST && process.env.NODE_ENV !== "test") {
    try {
      const rustResults = await executarScraperRust(params);
      if (rustResults && rustResults.length > 0) {
        return rustResults;
      }
    } catch (err) {
      console.log("Scraper Rust indisponível ou sem resultados, executando prospecção HTTP:", (err as Error).message);
    }
  }

  // 2. Executa buscas em paralelo (Fallback HTTP)
  const [ddgResults, olxResults] = await Promise.all([
    buscarDuckDuckGo(params),
    buscarOLXParticular(params),
  ]);

  // 3. Link Proprietário Direto
  const cleanCity = normalizarTexto(cidade);
  const cleanState = estado.toLowerCase();
  const cleanModalidade = modalidade.toLowerCase();
  const proprietarioDiretoUrl = `https://www.proprietariodireto.com.br/${cleanModalidade}/imovel/${cleanState}/${cleanCity}/direto-com-proprietario`;

  const propDiretoCard: ScraperResult = {
    id: "proprietario-direto-custom-link",
    titulo: `Imóveis de Proprietários Diretos em ${cidade} - ${estado}`,
    link: proprietarioDiretoUrl,
    fonte: "proprietariodireto.com.br",
    trecho: `Listagem oficial consolidada de proprietários particulares do portal Proprietário Direto para ${tipo} para ${modalidade} em ${cidade}-${estado}.`,
    direto_proprietario: true,
    cidade,
    estado,
    tipo,
    modalidade,
  };

  // 4. Combina e desduplica resultados por link
  const allResults = [propDiretoCard, ...olxResults, ...ddgResults];
  const seenLinks = new Set<string>();
  const uniqueResults: ScraperResult[] = [];

  for (const item of allResults) {
    const normalizedLink = item.link.toLowerCase().replace(/\/$/, "");
    if (!seenLinks.has(normalizedLink)) {
      seenLinks.add(normalizedLink);
      uniqueResults.push(item);
    }
  }

  // 5. Ordena colocando proprietários diretos primeiro
  uniqueResults.sort((a, b) => {
    if (a.direto_proprietario === b.direto_proprietario) return 0;
    return a.direto_proprietario ? -1 : 1;
  });

  return uniqueResults;
}
