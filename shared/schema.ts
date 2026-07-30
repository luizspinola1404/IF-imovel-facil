import { pgTable, text, serial, integer, boolean, timestamp, jsonb, decimal, real } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";
export * from "./models/auth"; // Import auth models

export const properties = pgTable("properties", {
  id: serial("id").primaryKey(),
  title: text("title").notNull(),
  description: text("description").notNull(),
  type: text("type").notNull(), // 'sale' | 'rent'
  category: text("category").notNull(), // 'house', 'apartment', 'commercial', 'land'
  price: decimal("price").notNull(),
  neighborhood: text("neighborhood").notNull(),
  bedrooms: integer("bedrooms").notNull(),
  bathrooms: integer("bathrooms").notNull(),
  area: real("area").notNull(), // m² (permite decimais/ponto flutuante)
  imageUrls: text("image_urls").array().notNull(),
  videoUrl: text("video_url"), // Optional YouTube video URL
  status: text("status").notNull().default('available'), // 'available', 'sold', 'rented'
  createdAt: timestamp("created_at").defaultNow(),
});

export const advantages = pgTable("advantages", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  description: text("description"),
  icon: text("icon"), // Optional icon/emoji
  createdAt: timestamp("created_at").defaultNow(),
});

export const propertyAdvantages = pgTable("property_advantages", {
  id: serial("id").primaryKey(),
  propertyId: integer("property_id").notNull(),
  advantageId: integer("advantage_id").notNull(),
  createdAt: timestamp("created_at").defaultNow(),
});

export const contacts = pgTable("contacts", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  phone: text("phone").notNull(),
  email: text("email"),
  message: text("message").notNull(),
  propertyId: integer("property_id"), // Optional linkage
  createdAt: timestamp("created_at").defaultNow(),
});

export const crawlerJobs = pgTable("crawler_jobs", {
  id: serial("id").primaryKey(),
  cidade: text("cidade").notNull(),
  estado: text("estado").notNull(),
  tipo: text("tipo").notNull(),
  modalidade: text("modalidade").notNull(),
  depthPages: integer("depth_pages").notNull().default(3),
  status: text("status").notNull().default('running'), // 'running', 'completed', 'failed'
  pagesCrawled: integer("pages_crawled").notNull().default(0),
  leadsFound: integer("leads_found").notNull().default(0),
  errorMessage: text("error_message"),
  createdAt: timestamp("created_at").defaultNow(),
});

export const crawlerLeads = pgTable("crawler_leads", {
  id: serial("id").primaryKey(),
  jobId: integer("job_id"),
  url: text("url").notNull().unique(),
  title: text("title").notNull(),
  snippet: text("snippet"),
  source: text("source").notNull(),
  price: text("price"),
  sellerName: text("seller_name"),
  sellerPhone: text("seller_phone"),
  isDirectOwner: boolean("is_direct_owner").notNull().default(false),
  cidade: text("cidade").notNull(),
  estado: text("estado").notNull(),
  tipo: text("tipo").notNull(),
  modalidade: text("modalidade").notNull(),
  status: text("status").notNull().default('new'), // 'new', 'imported', 'discarded'
  importedPropertyId: integer("imported_property_id"),
  createdAt: timestamp("created_at").defaultNow(),
});

export const insertPropertySchema = createInsertSchema(properties).omit({ id: true, createdAt: true });
export const insertAdvantageSchema = createInsertSchema(advantages).omit({ id: true, createdAt: true });
export const insertPropertyAdvantageSchema = createInsertSchema(propertyAdvantages).omit({ id: true, createdAt: true });
export const insertContactSchema = createInsertSchema(contacts).omit({ id: true, createdAt: true });
export const insertCrawlerJobSchema = createInsertSchema(crawlerJobs).omit({ id: true, createdAt: true });
export const insertCrawlerLeadSchema = createInsertSchema(crawlerLeads).omit({ id: true, createdAt: true });

export type Property = typeof properties.$inferSelect;
export type InsertProperty = z.infer<typeof insertPropertySchema>;
export type Advantage = typeof advantages.$inferSelect;
export type InsertAdvantage = z.infer<typeof insertAdvantageSchema>;
export type PropertyAdvantage = typeof propertyAdvantages.$inferSelect;
export type InsertPropertyAdvantage = z.infer<typeof insertPropertyAdvantageSchema>;
export type Contact = typeof contacts.$inferSelect;
export type InsertContact = z.infer<typeof insertContactSchema>;

export type CrawlerJob = typeof crawlerJobs.$inferSelect;
export type InsertCrawlerJob = z.infer<typeof insertCrawlerJobSchema>;
export type CrawlerLead = typeof crawlerLeads.$inferSelect;
export type InsertCrawlerLead = z.infer<typeof insertCrawlerLeadSchema>;

export type CreatePropertyRequest = InsertProperty;
export type UpdatePropertyRequest = Partial<InsertProperty>;

