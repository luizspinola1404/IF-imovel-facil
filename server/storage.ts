import { mongoDb, getNextSequence } from "./db";
import {
  type Property,
  type InsertProperty,
  type UpdatePropertyRequest,
  type Contact,
  type InsertContact,
  type User,
  type UpsertUser,
  type Advantage,
  type InsertAdvantage,
  type PropertyAdvantage,
  type CrawlerJob,
  type InsertCrawlerJob,
  type CrawlerLead,
  type InsertCrawlerLead,
} from "@shared/schema";
import { authStorage, IAuthStorage } from "./replit_integrations/auth/storage";
import { isMinioUrl, extractKeyFromUrl, deleteObjects } from "./minio";

function toProperty(doc: any): Property {
  return {
    id: Number(doc.id),
    title: doc.title || "",
    description: doc.description || "",
    type: doc.type || "sale",
    category: doc.category || "house",
    price: String(doc.price ?? "0"),
    neighborhood: doc.neighborhood || "",
    city: doc.city || "Juazeiro",
    state: doc.state || "BA",
    bedrooms: Number(doc.bedrooms ?? 0),
    bathrooms: Number(doc.bathrooms ?? 0),
    area: Number(doc.area ?? 0),
    imageUrls: Array.isArray(doc.imageUrls) ? doc.imageUrls : [],
    videoUrl: doc.videoUrl || null,
    status: doc.status || "available",
    createdAt: doc.createdAt ? new Date(doc.createdAt) : null,
  };
}

function toAdvantage(doc: any): Advantage {
  return {
    id: Number(doc.id),
    name: doc.name || "",
    description: doc.description || null,
    icon: doc.icon || null,
    createdAt: doc.createdAt ? new Date(doc.createdAt) : null,
  };
}

function toPropertyAdvantage(doc: any): PropertyAdvantage {
  return {
    id: Number(doc.id),
    propertyId: Number(doc.propertyId),
    advantageId: Number(doc.advantageId),
    createdAt: doc.createdAt ? new Date(doc.createdAt) : null,
  };
}

function toContact(doc: any): Contact {
  return {
    id: Number(doc.id),
    name: doc.name,
    phone: doc.phone,
    email: doc.email || null,
    message: doc.message,
    propertyId: doc.propertyId ? Number(doc.propertyId) : null,
    createdAt: doc.createdAt ? new Date(doc.createdAt) : null,
  };
}

function toCrawlerJob(doc: any): CrawlerJob {
  return {
    id: Number(doc.id),
    cidade: doc.cidade,
    estado: doc.estado,
    tipo: doc.tipo,
    modalidade: doc.modalidade,
    depthPages: Number(doc.depthPages ?? 3),
    status: doc.status || "running",
    pagesCrawled: Number(doc.pagesCrawled ?? 0),
    leadsFound: Number(doc.leadsFound ?? 0),
    errorMessage: doc.errorMessage || null,
    createdAt: doc.createdAt ? new Date(doc.createdAt) : null,
  };
}

function toCrawlerLead(doc: any): CrawlerLead {
  return {
    id: Number(doc.id),
    jobId: doc.jobId ? Number(doc.jobId) : null,
    title: doc.title,
    price: doc.price ? String(doc.price) : null,
    tipo: doc.tipo || "apartamento",
    modalidade: doc.modalidade || "venda",
    cidade: doc.cidade || "Petrolina",
    estado: doc.estado || "PE",
    url: doc.url,
    snippet: doc.snippet || null,
    source: doc.source || "olx.com.br",
    sellerName: doc.sellerName || null,
    sellerPhone: doc.sellerPhone || null,
    isDirectOwner: doc.isDirectOwner ?? true,
    status: doc.status || "new",
    importedPropertyId: doc.importedPropertyId ? Number(doc.importedPropertyId) : null,
    createdAt: doc.createdAt ? new Date(doc.createdAt) : null,
  };
}

export interface IStorage extends IAuthStorage {
  getProperties(filters?: any): Promise<Property[]>;
  getProperty(id: number): Promise<Property | undefined>;
  createProperty(property: InsertProperty): Promise<Property>;
  updateProperty(id: number, updates: UpdatePropertyRequest): Promise<Property>;
  deleteProperty(id: number): Promise<void>;
  createContact(contact: InsertContact): Promise<Contact>;
  getAdvantages(): Promise<Advantage[]>;
  getAdvantage(id: number): Promise<Advantage | undefined>;
  createAdvantage(advantage: InsertAdvantage): Promise<Advantage>;
  updateAdvantage(id: number, updates: Partial<InsertAdvantage>): Promise<Advantage>;
  deleteAdvantage(id: number): Promise<void>;
  getPropertyAdvantages(propertyId: number): Promise<Advantage[]>;
  addPropertyAdvantage(propertyId: number, advantageId: number): Promise<PropertyAdvantage>;
  removePropertyAdvantage(propertyId: number, advantageId: number): Promise<void>;
  // Crawler Storage Methods
  createCrawlerJob(job: InsertCrawlerJob): Promise<CrawlerJob>;
  updateCrawlerJob(id: number, updates: Partial<CrawlerJob>): Promise<CrawlerJob>;
  getCrawlerJobs(): Promise<CrawlerJob[]>;
  createCrawlerLead(lead: InsertCrawlerLead): Promise<CrawlerLead>;
  getCrawlerLeads(filters?: { jobId?: number; isDirectOwner?: boolean; status?: string }): Promise<CrawlerLead[]>;
  importCrawlerLead(leadId: number): Promise<Property>;
}

export class DatabaseStorage implements IStorage {
  // Auth methods
  async getUser(id: string): Promise<User | undefined> {
    return authStorage.getUser(id);
  }

  async upsertUser(userData: UpsertUser): Promise<User> {
    return authStorage.upsertUser(userData);
  }

  async getUserByIdentifier(identifier: string): Promise<User | undefined> {
    return authStorage.getUserByIdentifier(identifier);
  }

  async listUsers(): Promise<User[]> {
    return authStorage.listUsers();
  }

  async updateUser(id: string, updates: Partial<User>): Promise<User | undefined> {
    return authStorage.updateUser(id, updates);
  }

  async deleteUser(id: string): Promise<void> {
    return authStorage.deleteUser(id);
  }

  // Property methods
  async getProperties(filters?: any): Promise<Property[]> {
    const query: any = {};

    if (filters) {
      if (filters.type && filters.type !== "all") query.type = filters.type;
      if (filters.category && filters.category !== "all") query.category = filters.category;
      if (filters.neighborhood && filters.neighborhood.trim()) {
        query.neighborhood = { $regex: new RegExp(filters.neighborhood.trim(), "i") };
      }
      if (filters.city && filters.city !== "all") query.city = filters.city;
      if (filters.state && filters.state !== "all") query.state = filters.state;
      if (filters.minPrice !== undefined && filters.minPrice !== null && !isNaN(Number(filters.minPrice))) {
        query.price = { ...(query.price || {}), $gte: Number(filters.minPrice) };
      }
      if (filters.maxPrice !== undefined && filters.maxPrice !== null && !isNaN(Number(filters.maxPrice))) {
        query.price = { ...(query.price || {}), $lte: Number(filters.maxPrice) };
      }
      if (filters.bedrooms !== undefined && filters.bedrooms !== null && !isNaN(Number(filters.bedrooms))) {
        query.bedrooms = { $gte: Number(filters.bedrooms) };
      }
    }

    const docs = await mongoDb.collection("properties").find(query).sort({ createdAt: -1 }).toArray();
    return docs.map(toProperty);
  }

  async getProperty(id: number): Promise<Property | undefined> {
    const doc = await mongoDb.collection("properties").findOne({ id: Number(id) });
    return doc ? toProperty(doc) : undefined;
  }

  async createProperty(property: InsertProperty): Promise<Property> {
    const id = await getNextSequence("properties");
    const now = new Date();
    const doc = {
      ...property,
      id,
      price: Number(property.price) || 0,
      area: Number(property.area) || 0,
      bedrooms: Number(property.bedrooms) || 0,
      bathrooms: Number(property.bathrooms) || 0,
      city: property.city || "Juazeiro",
      state: property.state || "BA",
      status: property.status || "available",
      imageUrls: Array.isArray(property.imageUrls) ? property.imageUrls : [],
      videoUrl: property.videoUrl || null,
      createdAt: now,
      updatedAt: now,
    };
    await mongoDb.collection("properties").insertOne(doc);
    return toProperty(doc);
  }

  async updateProperty(id: number, updates: UpdatePropertyRequest): Promise<Property> {
    const now = new Date();
    const cleanUpdates: any = { ...updates, updatedAt: now };
    if (cleanUpdates.price !== undefined) {
      cleanUpdates.price = Number(cleanUpdates.price) || 0;
    }
    if (cleanUpdates.area !== undefined) {
      cleanUpdates.area = Number(cleanUpdates.area) || 0;
    }
    if (cleanUpdates.bedrooms !== undefined) {
      cleanUpdates.bedrooms = Number(cleanUpdates.bedrooms) || 0;
    }
    if (cleanUpdates.bathrooms !== undefined) {
      cleanUpdates.bathrooms = Number(cleanUpdates.bathrooms) || 0;
    }

    await mongoDb.collection("properties").updateOne(
      { id: Number(id) },
      { $set: cleanUpdates }
    );
    const updated = await this.getProperty(Number(id));
    if (!updated) throw new Error("Property not found after update");
    return updated;
  }

  async deleteProperty(id: number): Promise<void> {
    const property = await this.getProperty(Number(id));
    if (property) {
      const keys = property.imageUrls
        .filter((u) => isMinioUrl(u))
        .map((u) => extractKeyFromUrl(u))
        .filter(Boolean);
      if (keys.length) {
        try {
          await deleteObjects(keys);
        } catch (err) {
          console.error("failed to delete images from object storage:", err);
        }
      }
    }

    await mongoDb.collection("property_advantages").deleteMany({ propertyId: Number(id) });
    await mongoDb.collection("properties").deleteOne({ id: Number(id) });
  }

  // Advantage methods
  async getAdvantages(): Promise<Advantage[]> {
    const docs = await mongoDb.collection("advantages").find().sort({ name: 1 }).toArray();
    return docs.map(toAdvantage);
  }

  async getAdvantage(id: number): Promise<Advantage | undefined> {
    const doc = await mongoDb.collection("advantages").findOne({ id: Number(id) });
    return doc ? toAdvantage(doc) : undefined;
  }

  async createAdvantage(advantage: InsertAdvantage): Promise<Advantage> {
    const id = await getNextSequence("advantages");
    const doc = {
      ...advantage,
      id,
      createdAt: new Date(),
    };
    await mongoDb.collection("advantages").insertOne(doc);
    return toAdvantage(doc);
  }

  async updateAdvantage(id: number, updates: Partial<InsertAdvantage>): Promise<Advantage> {
    await mongoDb.collection("advantages").updateOne(
      { id: Number(id) },
      { $set: updates }
    );
    const updated = await this.getAdvantage(Number(id));
    if (!updated) throw new Error("Advantage not found after update");
    return updated;
  }

  async deleteAdvantage(id: number): Promise<void> {
    await mongoDb.collection("property_advantages").deleteMany({ advantageId: Number(id) });
    await mongoDb.collection("advantages").deleteOne({ id: Number(id) });
  }

  // Property advantages methods
  async getPropertyAdvantages(propertyId: number): Promise<Advantage[]> {
    const links = await mongoDb
      .collection("property_advantages")
      .find({ propertyId: Number(propertyId) })
      .toArray();
    const advantageIds = links.map((l: any) => Number(l.advantageId));
    if (advantageIds.length === 0) return [];

    const docs = await mongoDb
      .collection("advantages")
      .find({ id: { $in: advantageIds } })
      .sort({ name: 1 })
      .toArray();
    return docs.map(toAdvantage);
  }

  async addPropertyAdvantage(propertyId: number, advantageId: number): Promise<PropertyAdvantage> {
    const existing = await mongoDb.collection("property_advantages").findOne({
      propertyId: Number(propertyId),
      advantageId: Number(advantageId),
    });
    if (existing) return toPropertyAdvantage(existing);

    const id = await getNextSequence("property_advantages");
    const doc = {
      id,
      propertyId: Number(propertyId),
      advantageId: Number(advantageId),
      createdAt: new Date(),
    };
    await mongoDb.collection("property_advantages").insertOne(doc);
    return toPropertyAdvantage(doc);
  }

  async removePropertyAdvantage(propertyId: number, advantageId: number): Promise<void> {
    await mongoDb.collection("property_advantages").deleteMany({
      propertyId: Number(propertyId),
      advantageId: Number(advantageId),
    });
  }

  // Contact methods
  async createContact(contact: InsertContact): Promise<Contact> {
    const id = await getNextSequence("contacts");
    const doc = {
      ...contact,
      id,
      propertyId: contact.propertyId ? Number(contact.propertyId) : null,
      createdAt: new Date(),
    };
    await mongoDb.collection("contacts").insertOne(doc);
    return toContact(doc);
  }

  // Crawler Storage Methods
  async createCrawlerJob(job: InsertCrawlerJob): Promise<CrawlerJob> {
    const id = await getNextSequence("crawler_jobs");
    const doc = {
      ...job,
      id,
      pagesCrawled: 0,
      leadsFound: 0,
      status: job.status || "running",
      createdAt: new Date(),
    };
    await mongoDb.collection("crawler_jobs").insertOne(doc);
    return toCrawlerJob(doc);
  }

  async updateCrawlerJob(id: number, updates: Partial<CrawlerJob>): Promise<CrawlerJob> {
    await mongoDb.collection("crawler_jobs").updateOne(
      { id: Number(id) },
      { $set: updates }
    );
    const doc = await mongoDb.collection("crawler_jobs").findOne({ id: Number(id) });
    if (!doc) throw new Error("Crawler job not found");
    return toCrawlerJob(doc);
  }

  async getCrawlerJobs(): Promise<CrawlerJob[]> {
    const docs = await mongoDb.collection("crawler_jobs").find().sort({ createdAt: -1 }).toArray();
    return docs.map(toCrawlerJob);
  }

  async createCrawlerLead(lead: InsertCrawlerLead): Promise<CrawlerLead> {
    const id = await getNextSequence("crawler_leads");
    const doc = {
      ...lead,
      id,
      isDirectOwner: lead.isDirectOwner ?? true,
      status: lead.status || "new",
      createdAt: new Date(),
    };
    await mongoDb.collection("crawler_leads").insertOne(doc);
    return toCrawlerLead(doc);
  }

  async getCrawlerLeads(filters?: { jobId?: number; isDirectOwner?: boolean; status?: string }): Promise<CrawlerLead[]> {
    const query: any = {};
    if (filters) {
      if (filters.jobId !== undefined) query.jobId = Number(filters.jobId);
      if (filters.isDirectOwner !== undefined) query.isDirectOwner = filters.isDirectOwner;
      if (filters.status) query.status = filters.status;
    }
    const docs = await mongoDb.collection("crawler_leads").find(query).sort({ createdAt: -1 }).toArray();
    return docs.map(toCrawlerLead);
  }

  async importCrawlerLead(leadId: number): Promise<Property> {
    const leadDoc = await mongoDb.collection("crawler_leads").findOne({ id: Number(leadId) });
    if (!leadDoc) {
      throw new Error("Crawler lead not found");
    }

    let category = "house";
    if (leadDoc.tipo) {
      const t = leadDoc.tipo.toLowerCase();
      if (t.includes("apartamento") || t.includes("ap")) {
        category = "apartment";
      } else if (t.includes("terreno") || t.includes("lote")) {
        category = "land";
      } else if (t.includes("comercial") || t.includes("sala") || t.includes("galpão")) {
        category = "commercial";
      }
    }

    const type = leadDoc.modalidade === "aluguel" ? "rent" : "sale";
    const description = `${leadDoc.snippet || "Lead Prospectado automaticamente."}\n\nLink Original: ${leadDoc.url}\nLocalização: ${leadDoc.cidade} - ${leadDoc.estado}\nVendedor: ${leadDoc.sellerName || "N/I"} (${leadDoc.sellerPhone || "Sem telefone"})`;

    const newProperty = await this.createProperty({
      title: leadDoc.title,
      description,
      type,
      category,
      price: leadDoc.price ? String(leadDoc.price) : "0",
      neighborhood: leadDoc.cidade || "Indefinido",
      bedrooms: 0,
      bathrooms: 0,
      area: 0,
      imageUrls: [],
      status: "available",
    });

    await mongoDb.collection("crawler_leads").updateOne(
      { id: Number(leadId) },
      { $set: { status: "imported", importedPropertyId: newProperty.id } }
    );

    return newProperty;
  }
}

export const storage = new DatabaseStorage();
