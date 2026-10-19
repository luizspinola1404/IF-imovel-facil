import { type User, type UpsertUser } from "@shared/models/auth";
import { mongoDb } from "../../db";
import { randomUUID } from "crypto";

function toUser(doc: any): User {
  return {
    id: doc.id || String(doc._id),
    username: doc.username || null,
    email: doc.email || null,
    passwordHash: doc.passwordHash || doc.password_hash || null,
    firstName: doc.firstName || doc.first_name || null,
    lastName: doc.lastName || doc.last_name || null,
    role: doc.role || "user",
    profileImageUrl: doc.profileImageUrl || doc.profile_image_url || null,
    createdAt: doc.createdAt ? new Date(doc.createdAt) : doc.created_at ? new Date(doc.created_at) : new Date(),
    updatedAt: doc.updatedAt ? new Date(doc.updatedAt) : doc.updated_at ? new Date(doc.updated_at) : new Date(),
  };
}

// Interface for auth storage operations
export interface IAuthStorage {
  getUser(id: string): Promise<User | undefined>;
  upsertUser(user: UpsertUser): Promise<User>;
  getUserByIdentifier(identifier: string): Promise<User | undefined>;
  listUsers(): Promise<User[]>;
  updateUser(id: string, updates: Partial<User>): Promise<User | undefined>;
  deleteUser(id: string): Promise<void>;
}

class AuthStorage implements IAuthStorage {
  private col() {
    return mongoDb.collection("users");
  }

  async getUser(id: string): Promise<User | undefined> {
    const doc = await this.col().findOne({ $or: [{ id }, { _id: id as any }] });
    return doc ? toUser(doc) : undefined;
  }

  async upsertUser(userData: UpsertUser): Promise<User> {
    const id = userData.id || randomUUID();
    const now = new Date();
    const cleanDoc = {
      ...userData,
      id,
      _id: id,
      updatedAt: now,
    };

    await this.col().updateOne(
      { $or: [{ id }, { _id: id as any }] },
      {
        $set: cleanDoc,
        $setOnInsert: { createdAt: now },
      },
      { upsert: true }
    );

    const updated = await this.getUser(id);
    return updated!;
  }

  async getUserByIdentifier(identifier: string): Promise<User | undefined> {
    const doc = await this.col().findOne({
      $or: [{ username: identifier }, { email: identifier }],
    });
    return doc ? toUser(doc) : undefined;
  }

  async listUsers(): Promise<User[]> {
    const docs = await this.col().find().sort({ createdAt: 1 }).toArray();
    return docs.map(toUser);
  }

  async updateUser(id: string, updates: Partial<User>): Promise<User | undefined> {
    const cleanUpdates = {
      ...updates,
      updatedAt: new Date(),
    };
    await this.col().updateOne(
      { $or: [{ id }, { _id: id as any }] },
      { $set: cleanUpdates }
    );
    return this.getUser(id);
  }

  async deleteUser(id: string): Promise<void> {
    await this.col().deleteOne({ $or: [{ id }, { _id: id as any }] });
  }
}

export const authStorage = new AuthStorage();
