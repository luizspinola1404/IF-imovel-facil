import { S3Client, PutObjectCommand, DeleteObjectsCommand, CreateBucketCommand, HeadBucketCommand, PutBucketPolicyCommand } from "@aws-sdk/client-s3";
import { Storage as GoogleStorage } from "@google-cloud/storage";
import { randomBytes } from "crypto";

const GCS_BUCKET = process.env.GCS_BUCKET || process.env.FIREBASE_STORAGE_BUCKET || "imoviu-storage";
const MINIO_BUCKET = process.env.MINIO_BUCKET || "imovel-facil";
const PUBLIC_URL = process.env.MINIO_PUBLIC_URL || "http://localhost:9000";

// GCS / Firebase Storage Client (ativo se GCS_BUCKET estiver configurado)
let gcsClient: GoogleStorage | null = null;
if (GCS_BUCKET) {
  gcsClient = new GoogleStorage();
}

// MinIO / S3 Client (fallback para desenvolvimento local e ambiente legado)
const s3 = new S3Client({
  endpoint: process.env.MINIO_ENDPOINT || "http://localhost:9000",
  region: process.env.MINIO_REGION || "us-east-1",
  credentials: {
    accessKeyId: process.env.MINIO_ACCESS_KEY || "minio",
    secretAccessKey: process.env.MINIO_SECRET_KEY || "minio12345",
  },
  forcePathStyle: true,
});

function extFromMime(mime?: string) {
  if (!mime) return "";
  if (mime === "image/jpeg") return ".jpg";
  if (mime === "image/png") return ".png";
  if (mime === "image/webp") return ".webp";
  if (mime === "image/gif") return ".gif";
  return "";
}

export async function ensureBucketExists(bucket = GCS_BUCKET || MINIO_BUCKET) {
  if (GCS_BUCKET && gcsClient) {
    try {
      const [exists] = await gcsClient.bucket(GCS_BUCKET).exists();
      if (!exists) {
        console.warn(`[GCS] Atenção: Bucket ${GCS_BUCKET} não foi encontrado.`);
      }
    } catch (err: any) {
      console.warn(`[GCS] Verificação de bucket:`, err.message);
    }
    return;
  }

  let bucketExists = true;
  try {
    await s3.send(new HeadBucketCommand({ Bucket: bucket }));
  } catch (err: any) {
    bucketExists = false;
    await s3.send(new CreateBucketCommand({ Bucket: bucket }));
  }

  if (!bucketExists) {
    const policy = {
      Version: "2012-10-17",
      Statement: [
        {
          Effect: "Allow",
          Principal: "*",
          Action: ["s3:GetObject"],
          Resource: [`arn:aws:s3:::${bucket}/*`],
        },
      ],
    };

    try {
      await s3.send(
        new PutBucketPolicyCommand({
          Bucket: bucket,
          Policy: JSON.stringify(policy),
        }),
      );
      console.log(`Bucket ${bucket} policy set to public read`);
    } catch (err: any) {
      console.error("Failed to set bucket policy:", err.message);
    }
  }
}

export async function uploadImage(buffer: Buffer, contentType?: string, bucket = GCS_BUCKET || MINIO_BUCKET): Promise<string> {
  const key = `${Date.now()}-${randomBytes(6).toString("hex")}${extFromMime(contentType)}`;

  // Modo Google Cloud Storage (Firebase Storage)
  if (GCS_BUCKET && gcsClient) {
    const file = gcsClient.bucket(GCS_BUCKET).file(`imoveis/${key}`);
    await file.save(buffer, {
      contentType: contentType || "image/jpeg",
      public: true,
      metadata: {
        cacheControl: "public, max-age=31536000, immutable",
      },
    });
    return `https://storage.googleapis.com/${GCS_BUCKET}/imoveis/${key}`;
  }

  // Modo MinIO (Legado / Dev local)
  await s3.send(new PutObjectCommand({ Bucket: bucket, Key: key, Body: buffer, ContentType: contentType }));
  return `${PUBLIC_URL}/${bucket}/${key}`;
}

export async function deleteObjects(keys: string[], bucket = GCS_BUCKET || MINIO_BUCKET) {
  if (!keys || !keys.length) return;

  if (GCS_BUCKET && gcsClient) {
    const gcsBucket = gcsClient.bucket(GCS_BUCKET);
    await Promise.all(
      keys.map(async (k) => {
        try {
          const filePath = k.startsWith("imoveis/") ? k : `imoveis/${k}`;
          await gcsBucket.file(filePath).delete({ ignoreNotFound: true });
        } catch (e: any) {
          console.error(`Erro ao excluir ${k} do GCS:`, e.message);
        }
      }),
    );
    return;
  }

  const Objects = keys.map((Key) => ({ Key }));
  await s3.send(new DeleteObjectsCommand({ Bucket: bucket, Delete: { Objects } }));
}

export function isMinioUrl(url?: string): boolean {
  if (!url) return false;
  if (url.startsWith(`${PUBLIC_URL}/${MINIO_BUCKET}/`)) return true;
  if (GCS_BUCKET && url.startsWith(`https://storage.googleapis.com/${GCS_BUCKET}/`)) return true;
  if (url.includes("storage.googleapis.com")) return true;
  if (url.includes("/imovel-facil/")) return true;
  return false;
}

export function extractKeyFromUrl(url: string): string {
  if (!isMinioUrl(url)) return url;
  if (url.startsWith(`${PUBLIC_URL}/${MINIO_BUCKET}/`)) {
    return url.replace(`${PUBLIC_URL}/${MINIO_BUCKET}/`, "");
  }
  if (GCS_BUCKET && url.startsWith(`https://storage.googleapis.com/${GCS_BUCKET}/`)) {
    return url.replace(`https://storage.googleapis.com/${GCS_BUCKET}/`, "");
  }
  const parts = url.split("/");
  return parts[parts.length - 1];
}
