import { pgTable, text, serial, integer, boolean, timestamp, jsonb, decimal } from "drizzle-orm/pg-core";
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
  area: integer("area").notNull(), // m²
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

export const insertPropertySchema = createInsertSchema(properties).omit({ id: true, createdAt: true });
export const insertAdvantageSchema = createInsertSchema(advantages).omit({ id: true, createdAt: true });
export const insertPropertyAdvantageSchema = createInsertSchema(propertyAdvantages).omit({ id: true, createdAt: true });
export const insertContactSchema = createInsertSchema(contacts).omit({ id: true, createdAt: true });

export type Property = typeof properties.$inferSelect;
export type InsertProperty = z.infer<typeof insertPropertySchema>;
export type Advantage = typeof advantages.$inferSelect;
export type InsertAdvantage = z.infer<typeof insertAdvantageSchema>;
export type PropertyAdvantage = typeof propertyAdvantages.$inferSelect;
export type InsertPropertyAdvantage = z.infer<typeof insertPropertyAdvantageSchema>;
export type Contact = typeof contacts.$inferSelect;
export type InsertContact = z.infer<typeof insertContactSchema>;

export type CreatePropertyRequest = InsertProperty;
export type UpdatePropertyRequest = Partial<InsertProperty>;
