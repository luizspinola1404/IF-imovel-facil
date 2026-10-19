import { Express, Request, Response } from "express";
import fs from "fs";
import path from "path";
import { storage } from "./storage";

export function escapeHtml(str: string | null | undefined): string {
  if (!str) return "";
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

export function formatCurrency(val: number | string | null | undefined): string {
  if (val === null || val === undefined) return "R$ 0";
  const num = typeof val === "number" ? val : parseFloat(String(val));
  if (isNaN(num)) return "R$ 0";
  return new Intl.NumberFormat("pt-BR", {
    style: "currency",
    currency: "BRL",
    maximumFractionDigits: 0,
  }).format(num);
}

function getBaseUrl(req: Request): string {
  const host = req.get("x-forwarded-host") || req.get("host") || "imoviu-a1fc6.web.app";
  const protocol = req.get("x-forwarded-proto") || (host.includes("localhost") ? "http" : "https");
  return `${protocol}://${host}`;
}

let cachedAppHtml: string | null = null;

function getBaseAppHtml(): string {
  if (cachedAppHtml && process.env.NODE_ENV === "production") {
    return cachedAppHtml;
  }
  const appHtmlPath = path.resolve(process.cwd(), "dist", "public", "app.html");
  if (fs.existsSync(appHtmlPath)) {
    cachedAppHtml = fs.readFileSync(appHtmlPath, "utf-8");
    return cachedAppHtml;
  }
  const indexHtmlPath = path.resolve(process.cwd(), "dist", "public", "index.html");
  if (fs.existsSync(indexHtmlPath)) {
    cachedAppHtml = fs.readFileSync(indexHtmlPath, "utf-8");
    return cachedAppHtml;
  }
  return "<!DOCTYPE html><html><head><title>Imoviu</title></head><body><div id='root'></div></body></html>";
}

function injectMetadata(
  baseHtml: string,
  meta: {
    title: string;
    description: string;
    image?: string;
    url: string;
    type?: string;
  }
): string {
  const titleTag = `<title>${escapeHtml(meta.title)}</title>`;
  const descTag = `<meta name="description" content="${escapeHtml(meta.description)}" />`;
  const canonicalTag = `<link rel="canonical" href="${escapeHtml(meta.url)}" />`;
  const imageUrl = meta.image || "https://images.unsplash.com/photo-1600596542815-e32c12e32ade?q=80&w=1200&auto=format&fit=crop";

  const ogTags = `
    <!-- OpenGraph & Redes Sociais (WhatsApp, Facebook, Twitter) -->
    <meta property="og:type" content="${meta.type || "website"}" />
    <meta property="og:site_name" content="Imoviu - Luiz Spínola Imóveis" />
    <meta property="og:title" content="${escapeHtml(meta.title)}" />
    <meta property="og:description" content="${escapeHtml(meta.description)}" />
    <meta property="og:image" content="${escapeHtml(imageUrl)}" />
    <meta property="og:image:secure_url" content="${escapeHtml(imageUrl)}" />
    <meta property="og:image:width" content="1200" />
    <meta property="og:image:height" content="630" />
    <meta property="og:image:alt" content="${escapeHtml(meta.title)}" />
    <meta property="og:url" content="${escapeHtml(meta.url)}" />
    <meta name="twitter:card" content="summary_large_image" />
    <meta name="twitter:title" content="${escapeHtml(meta.title)}" />
    <meta name="twitter:description" content="${escapeHtml(meta.description)}" />
    <meta name="twitter:image" content="${escapeHtml(imageUrl)}" />
  `;

  return baseHtml.replace(
    /<title>.*?<\/title>/i,
    `${titleTag}\n    ${descTag}\n    ${canonicalTag}\n    ${ogTags}`
  );
}

export function registerSsrRoutes(app: Express) {
  // 1. Rota Home
  app.get("/", async (req: Request, res: Response) => {
    try {
      const baseHtml = getBaseAppHtml();
      const baseUrl = getBaseUrl(req);
      const html = injectMetadata(baseHtml, {
        title: "Imóveis à Venda e Locação em Juazeiro e Petrolina | Imoviu - Luiz Spínola Imóveis",
        description:
          "Encontre casas, apartamentos e terrenos para comprar ou alugar em Juazeiro-BA e Petrolina-PE com Luiz Spínola Imóveis.",
        image: "https://images.unsplash.com/photo-1600596542815-e32c12e32ade?q=80&w=1200&auto=format&fit=crop",
        url: `${baseUrl}/`,
        type: "website",
      });

      res.setHeader("Content-Type", "text/html; charset=utf-8");
      res.send(html);
    } catch (err) {
      console.error("Erro na rota Home:", err);
      res.status(500).send("Erro interno.");
    }
  });

  // 2. Rota Detalhes do Imóvel (com OpenGraph dinâmico para WhatsApp)
  app.get("/imovel/:id", async (req: Request, res: Response) => {
    try {
      const propertyId = parseInt(req.params.id, 10);
      const baseHtml = getBaseAppHtml();
      const baseUrl = getBaseUrl(req);

      if (isNaN(propertyId)) {
        res.setHeader("Content-Type", "text/html; charset=utf-8");
        return res.send(baseHtml);
      }

      const property = await storage.getProperty(propertyId);
      if (!property) {
        res.setHeader("Content-Type", "text/html; charset=utf-8");
        return res.send(baseHtml);
      }

      const mainImage =
        property.imageUrls && property.imageUrls.length > 0
          ? property.imageUrls[0]
          : "https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=1200&q=80";

      const formattedPrice = formatCurrency(property.price);
      const title = `${property.title} - ${formattedPrice} | Imoviu - Luiz Spínola Imóveis`;

      const specs: string[] = [];
      if (property.bedrooms && property.bedrooms > 0) specs.push(`${property.bedrooms} quartos`);
      if (property.bathrooms && property.bathrooms > 0) specs.push(`${property.bathrooms} banheiros`);
      if (property.area && property.area > 0) specs.push(`${property.area}m²`);
      const specsStr = specs.length > 0 ? specs.join(", ") + ". " : "";

      const location = [property.neighborhood, property.city, property.state].filter(Boolean).join(", ");
      const extraDesc = property.description ? property.description.replace(/\s+/g, " ").slice(0, 150) : "Clique para ver fotos e detalhes!";
      const description = `${location ? location + ". " : ""}${specsStr}Por ${formattedPrice}. ${extraDesc}`;

      const html = injectMetadata(baseHtml, {
        title,
        description,
        image: mainImage,
        url: `${baseUrl}/imovel/${property.id}`,
        type: "article",
      });

      res.setHeader("Content-Type", "text/html; charset=utf-8");
      res.send(html);
    } catch (err) {
      console.error("Erro ao carregar detalhes do imóvel:", err);
      res.status(500).send("Erro interno ao carregar detalhes do imóvel.");
    }
  });

  // 3. Rota Contato
  app.get("/contato", (req: Request, res: Response) => {
    const baseHtml = getBaseAppHtml();
    const baseUrl = getBaseUrl(req);
    const html = injectMetadata(baseHtml, {
      title: "Fale Conosco | Imoviu - Luiz Spínola Imóveis",
      description: "Entre em contato e tire suas dúvidas com Luiz Spínola Imóveis. Telefone: (74) 99969-5633.",
      url: `${baseUrl}/contato`,
      type: "website",
    });
    res.setHeader("Content-Type", "text/html; charset=utf-8");
    res.send(html);
  });

  // 4. Rota Anunciar Imóvel (Proprietário)
  app.get("/proprietario", (req: Request, res: Response) => {
    const baseHtml = getBaseAppHtml();
    const baseUrl = getBaseUrl(req);
    const html = injectMetadata(baseHtml, {
      title: "Anuncie seu Imóvel | Imoviu - Luiz Spínola Imóveis",
      description: "Venda ou alugue seu imóvel com rapidez e segurança em Juazeiro e Petrolina.",
      url: `${baseUrl}/proprietario`,
      type: "website",
    });
    res.setHeader("Content-Type", "text/html; charset=utf-8");
    res.send(html);
  });
}
