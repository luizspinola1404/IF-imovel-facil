import { db } from "./db";
import {
  properties,
  contacts,
  users,
  advantages,
  propertyAdvantages,
  crawlerJobs,
  crawlerLeads,
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
  type InsertPropertyAdvantage,
  type CrawlerJob,
  type InsertCrawlerJob,
  type CrawlerLead,
  type InsertCrawlerLead,
} from "@shared/schema";
import { eq, desc, and, gte, lte, or } from "drizzle-orm";
import { IAuthStorage } from "./replit_integrations/auth/storage";
import { isMinioUrl, extractKeyFromUrl, deleteObjects } from "./minio";

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
    const [user] = await db.select().from(users).where(eq(users.id, id));
    return user;
  }

  async upsertUser(userData: UpsertUser): Promise<User> {
    const [user] = await db
      .insert(users)
      .values(userData)
      .onConflictDoUpdate({
        target: users.id,
        set: {
          ...userData,
          updatedAt: new Date(),
        },
      })
      .returning();
    return user;
  }

  async getUserByIdentifier(identifier: string): Promise<User | undefined> {
    const [user] = await db
      .select()
      .from(users)
      .where(or(eq(users.username, identifier), eq(users.email, identifier)));
    return user;
  }

  // Property methods
  async getProperties(filters?: any): Promise<Property[]> {
    let query = db.select().from(properties);
    const conditions = [];

    if (filters) {
      if (filters.type) conditions.push(eq(properties.type, filters.type));
      if (filters.category) conditions.push(eq(properties.category, filters.category));
      if (filters.neighborhood) conditions.push(eq(properties.neighborhood, filters.neighborhood));
      if (filters.minPrice) conditions.push(gte(properties.price, filters.minPrice));
      if (filters.maxPrice) conditions.push(lte(properties.price, filters.maxPrice));
      if (filters.bedrooms) conditions.push(gte(properties.bedrooms, filters.bedrooms));
    }

    if (conditions.length > 0) {
      return await query.where(and(...conditions)).orderBy(desc(properties.createdAt));
    }

    return await query.orderBy(desc(properties.createdAt));
  }

  async getProperty(id: number): Promise<Property | undefined> {
    const [property] = await db.select().from(properties).where(eq(properties.id, id));
    return property;
  }

  async createProperty(property: InsertProperty): Promise<Property> {
    const [newProperty] = await db.insert(properties).values(property).returning();
    return newProperty;
  }

  async updateProperty(id: number, updates: UpdatePropertyRequest): Promise<Property> {
    const [updated] = await db
      .update(properties)
      .set(updates)
      .where(eq(properties.id, id))
      .returning();
    return updated;
  }

  async deleteProperty(id: number): Promise<void> {
    const property = await this.getProperty(id);
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

    await db.delete(properties).where(eq(properties.id, id));
  }

  // Advantage methods
  async getAdvantages(): Promise<Advantage[]> {
    return await db.select().from(advantages).orderBy(advantages.name);
  }

  async getAdvantage(id: number): Promise<Advantage | undefined> {
    const [advantage] = await db.select().from(advantages).where(eq(advantages.id, id));
    return advantage;
  }

  async createAdvantage(advantage: InsertAdvantage): Promise<Advantage> {
    const [newAdvantage] = await db.insert(advantages).values(advantage).returning();
    return newAdvantage;
  }

  async updateAdvantage(id: number, updates: Partial<InsertAdvantage>): Promise<Advantage> {
    const [updated] = await db
      .update(advantages)
      .set(updates)
      .where(eq(advantages.id, id))
      .returning();
    return updated;
  }

  async deleteAdvantage(id: number): Promise<void> {
    // Delete all property-advantage associations
    await db.delete(propertyAdvantages).where(eq(propertyAdvantages.advantageId, id));
    // Delete the advantage itself
    await db.delete(advantages).where(eq(advantages.id, id));
  }

  // Property advantages methods
  async getPropertyAdvantages(propertyId: number): Promise<Advantage[]> {
    const results = await db
      .select({ advantage: advantages })
      .from(propertyAdvantages)
      .innerJoin(advantages, eq(propertyAdvantages.advantageId, advantages.id))
      .where(eq(propertyAdvantages.propertyId, propertyId));
    return results.map(r => r.advantage);
  }

  async addPropertyAdvantage(propertyId: number, advantageId: number): Promise<PropertyAdvantage> {
    const [result] = await db
      .insert(propertyAdvantages)
      .values({ propertyId, advantageId })
      .returning();
    return result;
  }

  async removePropertyAdvantage(propertyId: number, advantageId: number): Promise<void> {
    await db
      .delete(propertyAdvantages)
      .where(and(eq(propertyAdvantages.propertyId, propertyId), eq(propertyAdvantages.advantageId, advantageId)));
  }

  // Contact methods
  async createContact(contact: InsertContact): Promise<Contact> {
    const [newContact] = await db.insert(contacts).values(contact).returning();
    return newContact;
  }
}

export const storage = new DatabaseStorage();
