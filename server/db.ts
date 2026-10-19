import { MongoClient, Db } from "mongodb";

const DEFAULT_MONGO_URI =
  "mongodb://appuser:lV-F4mbCZBh8L7j0_8bA9y5hsiOcctWbdzA7Y_QkPNwWE77v@9281e287-2dbb-4d5a-91c5-b7c1c64a75e3.southamerica-east1.firestore.goog:443/imoviu-db?loadBalanced=true&tls=true&retryWrites=false";

export const MONGODB_URI = process.env.MONGODB_URI || DEFAULT_MONGO_URI;
export const MONGODB_DB_NAME = process.env.MONGODB_DB_NAME || "imoviu-db";

let client: MongoClient | null = null;
let dbInstance: Db | null = null;

export function getMongoClient(): MongoClient {
  if (!client) {
    client = new MongoClient(MONGODB_URI, {
      maxPoolSize: 20,
      minPoolSize: 1,
      serverSelectionTimeoutMS: 10000,
      connectTimeoutMS: 30000,
    });
  }
  return client;
}

export function getMongoDb(): Db {
  if (!dbInstance) {
    const c = getMongoClient();
    dbInstance = c.db(MONGODB_DB_NAME);
  }
  return dbInstance;
}

export const mongoDb = getMongoDb();

/**
 * Retorna o próximo ID sequencial para coleções que necessitam de IDs numéricos
 * (garante compatibilidade perfeita com APIs REST existentes).
 */
export async function getNextSequence(sequenceName: string): Promise<number> {
  const db = getMongoDb();
  const res = await db.collection("counters").findOneAndUpdate(
    { _id: sequenceName as any },
    { $inc: { seq: 1 } },
    { upsert: true, returnDocument: "after" }
  );
  return (res as any)?.seq ?? 1;
}

// Compatibilidade para módulos legados
export const pool = {
  query: async () => ({ rows: [] }),
};
export const db = {} as any;
