import type { Express } from "express";
import type { Server } from "http";
import { execFile } from "child_process";
import path from "path";
import { storage } from "./storage";
import { api } from "@shared/routes";
import { z } from "zod";
import { eq } from "drizzle-orm";
import { setupAuth, registerAuthRoutes, isAuthenticated } from "./replit_integrations/auth";
import { authStorage } from "./replit_integrations/auth/storage";
import { db } from "./db";
import { users } from "@shared/models/auth";
import { scryptSync, randomBytes } from "crypto";
import multer from "multer";
import { ensureBucketExists, uploadImage, deleteObjects, isMinioUrl, extractKeyFromUrl } from "./minio";

// Helper function to hash passwords using Node.js crypto  
function hashPassword(password: string): string {
  const salt = randomBytes(16).toString("hex");
  const hash = scryptSync(password, salt, 64).toString("hex");
  return `${salt}_${hash}`;
}

export async function registerRoutes(
  httpServer: Server,
  app: Express
): Promise<Server> {
  // Setup Auth
  await setupAuth(app);
  registerAuthRoutes(app);

  // Properties API
  app.get(api.properties.list.path, async (req, res) => {
    const filters = {
      type: req.query.type as string,
      category: req.query.category as string,
      neighborhood: req.query.neighborhood as string,
      minPrice: req.query.minPrice ? Number(req.query.minPrice) : undefined,
      maxPrice: req.query.maxPrice ? Number(req.query.maxPrice) : undefined,
      bedrooms: req.query.bedrooms ? Number(req.query.bedrooms) : undefined,
    };
    const properties = await storage.getProperties(filters);
    res.json(properties);
  });

  app.get(api.properties.get.path, async (req, res) => {
    const property = await storage.getProperty(Number(req.params.id));
    if (!property) {
      return res.status(404).json({ message: "Property not found" });
    }
    res.json(property);
  });

  // Protected Routes
  app.post(api.properties.create.path, isAuthenticated, async (req, res) => {
    try {
      const input = api.properties.create.input.parse(req.body);
      const property = await storage.createProperty(input);
      res.status(201).json(property);
    } catch (err) {
      if (err instanceof z.ZodError) {
        return res.status(400).json({
          message: err.errors[0].message,
          field: err.errors[0].path.join('.'),
        });
      }
      throw err;
    }
  });

  app.put(api.properties.update.path, isAuthenticated, async (req, res) => {
    try {
      const input = api.properties.update.input.parse(req.body);
      const property = await storage.updateProperty(Number(req.params.id), input);
      res.json(property);
    } catch (err) {
      if (err instanceof z.ZodError) {
        return res.status(400).json({
          message: err.errors[0].message,
          field: err.errors[0].path.join('.'),
        });
      }
      throw err;
    }
  });

  app.delete(api.properties.delete.path, isAuthenticated, async (req, res) => {
    await storage.deleteProperty(Number(req.params.id));
    res.status(204).end();
  });

  // Advantages API
  app.get(api.advantages.list.path, async (req, res) => {
    const advs = await storage.getAdvantages();
    res.json(advs);
  });

  app.get(api.advantages.get.path, async (req, res) => {
    const advantage = await storage.getAdvantage(Number(req.params.id));
    if (!advantage) {
      return res.status(404).json({ message: "Advantage not found" });
    }
    res.json(advantage);
  });

  app.post(api.advantages.create.path, isAuthenticated, ensureAdmin, async (req, res) => {
    try {
      const input = api.advantages.create.input.parse(req.body);
      const advantage = await storage.createAdvantage(input);
      res.status(201).json(advantage);
    } catch (err) {
      if (err instanceof z.ZodError) {
        return res.status(400).json({
          message: err.errors[0].message,
          field: err.errors[0].path.join('.'),
        });
      }
      throw err;
    }
  });

  app.put(api.advantages.update.path, isAuthenticated, ensureAdmin, async (req, res) => {
    try {
      const input = api.advantages.update.input.parse(req.body);
      const advantage = await storage.updateAdvantage(Number(req.params.id), input);
      res.json(advantage);
    } catch (err) {
      if (err instanceof z.ZodError) {
        return res.status(400).json({
          message: err.errors[0].message,
          field: err.errors[0].path.join('.'),
        });
      }
      throw err;
    }
  });

  app.delete(api.advantages.delete.path, isAuthenticated, ensureAdmin, async (req, res) => {
    await storage.deleteAdvantage(Number(req.params.id));
    res.status(204).end();
  });

  // Property advantages API
  app.get("/api/properties/:propertyId/advantages", async (req, res) => {
    const advs = await storage.getPropertyAdvantages(Number(req.params.propertyId));
    res.json(advs);
  });

  app.post("/api/properties/:propertyId/advantages", isAuthenticated, async (req, res) => {
    try {
      const input = z.object({ advantageId: z.number() }).parse(req.body);
      const result = await storage.addPropertyAdvantage(Number(req.params.propertyId), input.advantageId);
      res.status(201).json(result);
    } catch (err) {
      if (err instanceof z.ZodError) {
        return res.status(400).json({
          message: err.errors[0].message,
          field: err.errors[0].path.join('.'),
        });
      }
      throw err;
    }
  });

  app.delete("/api/properties/:propertyId/advantages/:advantageId", isAuthenticated, async (req, res) => {
    await storage.removePropertyAdvantage(Number(req.params.propertyId), Number(req.params.advantageId));
    res.status(204).end();
  });

  // File uploads (images) - sent to MinIO
  const upload = multer({ 
    storage: multer.memoryStorage(), 
    limits: { fileSize: 10 * 1024 * 1024 } // 10MB limit
  });

  app.post("/api/uploads", isAuthenticated, upload.array("files", 10), async (req, res) => {
    const files = (req.files || []) as Express.Multer.File[];
    if (!files.length) return res.status(400).json({ message: "no files" });
    // ensure bucket exists before uploading
    await ensureBucketExists();
    const urls = await Promise.all(files.map((f) => uploadImage(f.buffer, f.mimetype)));
    res.json({ urls });
  });

  // Error handler for multer file size errors
  app.use((err: any, req: any, res: any, next: any) => {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(413).json({ message: 'Arquivo muito grande. Tamanho máximo: 10MB' });
    }
    next(err);
  });

  app.delete("/api/uploads", isAuthenticated, async (req, res) => {
    const { urls } = req.body || {};
    if (!Array.isArray(urls)) return res.status(400).json({ message: "urls required" });
    const keys = (urls as string[]).filter(isMinioUrl).map(extractKeyFromUrl).filter(Boolean);
    if (keys.length) await deleteObjects(keys);
    res.json({ ok: true });
  });

  // Admin user management endpoints
  function ensureAdmin(req: any, res: any, next: any) {
    const userId = req.user?.claims?.sub;
    if (!userId) return res.status(401).json({ message: "Unauthorized" });
    authStorage.getUser(userId).then((u) => {
      if (!u || (u as any).role !== "admin") return res.status(403).json({ message: "Forbidden" });
      next();
    }).catch(next);
  }

  app.get("/api/admin/users", isAuthenticated, ensureAdmin, async (_req, res) => {
    const all = await db.select().from(users).orderBy(users.createdAt);
    res.json(all.map((u) => ({ id: u.id, email: u.email, firstName: u.firstName, lastName: u.lastName, role: (u as any).role })));
  });

  app.post("/api/admin/users", isAuthenticated, ensureAdmin, async (req, res) => {
    const { email, firstName, lastName, role, username, password } = req.body || {};
    if (!email) return res.status(400).json({ message: "email required" });
    try {
      let passwordHash: string | undefined = undefined;
      if (password) {
        passwordHash = hashPassword(password);
      }
      const inserted = await db
        .insert(users)
        .values({ email, firstName, lastName, role: role || "user", username, passwordHash } as any)
        .returning();
      res.status(201).json(inserted[0]);
    } catch (err) {
      res.status(500).json({ message: "failed to create user" });
    }
  });

  app.put("/api/admin/users/:id", isAuthenticated, ensureAdmin, async (req, res) => {
    const id = req.params.id;
    const { role, password } = req.body || {};
    const updates: any = {};
    if (role) updates.role = role;
    if (password) {
      updates.passwordHash = hashPassword(password);
    }
    if (!Object.keys(updates).length) return res.status(400).json({ message: "role or password required" });
    await db.update(users).set(updates).where(eq(users.id, id));
    res.json({ ok: true });
  });

  app.delete("/api/admin/users/:id", isAuthenticated, ensureAdmin, async (req, res) => {
    const id = req.params.id;
    await db.delete(users).where(eq(users.id, id));
    res.json({ ok: true });
  });

  // Secret registration route with a UUID to prevent bot discovery
  app.post("/api/auth/register-8fbe54ad-291b-4b10-8533-8c4bf6cd5d12", async (req, res) => {
    const { username, email, password, firstName, lastName, role } = req.body || {};
    if (!username || !email || !password) {
      return res.status(400).json({ message: "username, email and password are required" });
    }
    try {
      const existing = await storage.getUserByIdentifier(username);
      const existingEmail = await storage.getUserByIdentifier(email);
      if (existing || existingEmail) {
        return res.status(400).json({ message: "User or email already exists" });
      }

      const passwordHash = hashPassword(password);
      const inserted = await db
        .insert(users)
        .values({
          username,
          email,
          passwordHash,
          firstName: firstName || null,
          lastName: lastName || null,
          role: role || "admin",
        } as any)
        .returning();
      
      res.status(201).json({ 
        ok: true, 
        message: "User registered successfully", 
        user: { id: inserted[0].id, username: inserted[0].username, role: inserted[0].role } 
      });
    } catch (err) {
      console.error("Secret registration error:", err);
      res.status(500).json({ message: "Internal server error" });
    }
  });

  // Prospecção Web (Rust Scraper)
  app.post("/api/prospeccao/buscar", isAuthenticated, async (req, res) => {
    const { estado, cidade, tipo, modalidade } = req.body || {};
    if (!estado || !cidade || !tipo || !modalidade) {
      return res.status(400).json({ error: "Campos obrigatórios: estado, cidade, tipo, modalidade" });
    }

    const binaryPath = process.env.SCRAPER_PATH || 
      (process.env.NODE_ENV === "production"
        ? path.resolve(process.cwd(), "scraper/target/release/scraper")
        : path.resolve(process.cwd(), "scraper/target/debug/scraper"));
    const args = [
      "--estado", estado,
      "--cidade", cidade,
      "--tipo", tipo,
      "--modalidade", modalidade
    ];

    execFile(binaryPath, args, { timeout: 35000 }, (error, stdout, stderr) => {
      if (error) {
        console.error("Erro ao rodar o scraper Rust:", error, stderr);
        return res.status(502).json({ error: "Erro interno ao executar a busca de prospecção. Certifique-se de que o geckodriver está disponível." });
      }

      try {
        const results = JSON.parse(stdout);
        res.json(results);
      } catch (err) {
        console.error("Erro ao parsear JSON do scraper:", err, stdout);
        res.status(500).json({ error: "Erro ao interpretar resultados da busca" });
      }
    });
  });

  app.post("/api/prospeccao/salvar-lead", isAuthenticated, async (req, res) => {
    try {
      const { titulo, link, trecho, cidade, estado, tipo, modalidade } = req.body || {};
      if (!titulo) {
        return res.status(400).json({ error: "Campos obrigatórios faltando" });
      }

      let category = "house";
      if (tipo) {
        const t = tipo.toLowerCase();
        if (t.includes("apartamento") || t.includes("ap")) {
          category = "apartment";
        } else if (t.includes("terreno") || t.includes("lote")) {
          category = "land";
        } else if (t.includes("comercial") || t.includes("sala") || t.includes("galpão")) {
          category = "commercial";
        }
      }

      const type = modalidade === "aluguel" ? "rent" : "sale";
      const desc = `${trecho || "Lead Prospectado automaticamente."}\n\nLink Original: ${link || "Sem link"}\nLocalização: ${cidade} - ${estado}`;

      const newProperty = await storage.createProperty({
        title: titulo,
        description: desc,
        type,
        category,
        price: "0",
        neighborhood: cidade || "Indefinido",
        bedrooms: 0,
        bathrooms: 0,
        area: 0,
        imageUrls: [],
        status: "available"
      });

      res.status(201).json(newProperty);
    } catch (err) {
      console.error("Erro ao salvar lead:", err);
      res.status(500).json({ error: "Erro interno ao salvar lead" });
    }
  });

  // Contacts API
  app.post(api.contacts.create.path, async (req, res) => {
    try {
      const input = api.contacts.create.input.parse(req.body);
      const contact = await storage.createContact(input);
      res.status(201).json(contact);
    } catch (err) {
      if (err instanceof z.ZodError) {
        return res.status(400).json({
          message: err.errors[0].message,
          field: err.errors[0].path.join('.'),
        });
      }
      throw err;
    }
  });

  // Ensure admin exists
  await ensureAdminUser();

  // Seed Data
  await seedDatabase();

  return httpServer;
}

async function ensureAdminUser() {
  try {
    const [existingAdmin] = await db.select().from(users).where(eq(users.username, "admin"));
    if (existingAdmin) {
      if (existingAdmin.role !== "admin") {
        await db.update(users).set({ role: "admin" }).where(eq(users.username, "admin"));
        console.log("Enforced 'admin' role for default 'admin' user");
      } else {
        console.log("Admin user 'admin' already exists with correct role");
      }
      return;
    }

    const password = process.env.ADMIN_PASSWORD || "admin123";
    const passwordHash = hashPassword(password);

    await db
      .insert(users)
      .values({
        username: "admin",
        email: "admin@local",
        firstName: "Admin",
        lastName: "Local",
        role: "admin",
        passwordHash,
      });

    console.log(`Created default admin 'admin' (${process.env.ADMIN_PASSWORD ? 'ADMIN_PASSWORD' : 'admin123'})`);
  } catch (err) {
    console.error('ensureAdminUser error:', err);
  }
}

async function seedDatabase() {
  const existing = await storage.getProperties();
  if (existing.length === 0) {
    console.log("Seeding database...");
    await storage.createProperty({
      title: "Casa Moderna no Centro",
      description: "Linda casa com 3 quartos, suíte master, piscina e área gourmet. Localização privilegiada no centro de Juazeiro.",
      type: "sale",
      category: "house",
      price: "450000",
      neighborhood: "Centro",
      bedrooms: 3,
      bathrooms: 2,
      area: 150,
      imageUrls: [
        "https://images.unsplash.com/photo-1568605114967-8130f3a36994?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
        "https://images.unsplash.com/photo-1576941089067-2de3c901e126?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80"
      ],
      status: "available"
    });
    await storage.createProperty({
      title: "Apartamento com Vista para o Rio",
      description: "Apartamento de luxo com vista panorâmica para o Rio São Francisco. Condomínio completo com segurança 24h.",
      type: "rent",
      category: "apartment",
      price: "1500",
      neighborhood: "Orla",
      bedrooms: 2,
      bathrooms: 1,
      area: 80,
      imageUrls: [
        "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80"
      ],
      status: "available"
    });
    await storage.createProperty({
      title: "Terreno em Condomínio Fechado",
      description: "Oportunidade única! Terreno plano em condomínio de alto padrão.",
      type: "sale",
      category: "land",
      price: "120000",
      neighborhood: "Nova Juazeiro",
      bedrooms: 0,
      bathrooms: 0,
      area: 300,
      imageUrls: [
        "https://images.unsplash.com/photo-1500382017468-9049fed747ef?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80"
      ],
      status: "available"
    });
  }
}
