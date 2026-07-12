import { PrismaClient } from '@prisma/client';
import { Pool } from 'pg';
import { PrismaPg } from '@prisma/adapter-pg';
import dotenv from 'dotenv'; // 1. Çevresel değişken okuyucuyu dahil et

// 2. .env dosyasındaki verileri (DATABASE_URL) Node.js'e yükle
dotenv.config();

// Artık process.env.DATABASE_URL boş gelmeyecek
const connectionString = process.env.DATABASE_URL as string;

const pool = new Pool({ connectionString });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

export default prisma;