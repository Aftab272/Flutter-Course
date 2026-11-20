import fs from 'node:fs';
import path from 'node:path';

/**
 * Loads .env file into process.env without external dependencies.
 */
export function loadEnv(envPath = path.resolve(process.cwd(), '.env')) {
  if (!fs.existsSync(envPath)) return;
  const content = fs.readFileSync(envPath, 'utf8');
  for (const rawLine of content.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) continue;
    const eqIdx = line.indexOf('=');
    if (eqIdx === -1) continue;
    const key = line.slice(0, eqIdx).trim();
    const val = line.slice(eqIdx + 1).trim().replace(/^["']|["']$/g, '');
    if (key && !(key in process.env)) {
      process.env[key] = val;
    }
  }
}

/**
 * Simple in-memory TTL cache to reduce redundant marketplace API calls.
 */
class MemoryCache {
  constructor() {
    this.store = new Map();
  }

  get(key) {
    const entry = this.store.get(key);
    if (!entry) return null;
    if (Date.now() > entry.expiresAt) {
      this.store.delete(key);
      return null;
    }
    return entry.value;
  }

  set(key, value, ttlMs = 5 * 60 * 1000) {
    this.store.set(key, { value, expiresAt: Date.now() + ttlMs });
    if (this.store.size > 500) {
      const oldestKey = this.store.keys().next().value;
      this.store.delete(oldestKey);
    }
  }
}

export const cache = new MemoryCache();

/**
 * Per-IP token bucket rate limiter (60 requests / minute).
 */
const rateMap = new Map();
export function checkRateLimit(ip, limit = 60, windowMs = 60_000) {
  const now = Date.now();
  const rec = rateMap.get(ip) || { count: 0, resetAt: now + windowMs };
  if (now > rec.resetAt) {
    rec.count = 1;
    rec.resetAt = now + windowMs;
  } else {
    rec.count += 1;
  }
  rateMap.set(ip, rec);
  return {
    allowed: rec.count <= limit,
    remaining: Math.max(0, limit - rec.count),
    resetAt: rec.resetAt,
  };
}

/**
 * Fetch wrapper with timeout + exponential backoff retries on 429/5xx.
 */
export async function fetchWithRetry(url, options = {}, { retries = 2, timeoutMs = 8000 } = {}) {
  let lastError;
  for (let attempt = 0; attempt <= retries; attempt++) {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);
    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal,
        headers: {
          'User-Agent': 'LootifyScrap/1.0 (+https://lootifyscrap.app)',
          Accept: 'application/json',
          ...(options.headers || {}),
        },
      });
      clearTimeout(timer);

      if ((response.status === 429 || response.status >= 500) && attempt < retries) {
        const delayMs = 400 * Math.pow(2, attempt);
        await new Promise((r) => setTimeout(r, delayMs));
        continue;
      }
      return response;
    } catch (err) {
      clearTimeout(timer);
      lastError = err;
      if (attempt < retries) {
        await new Promise((r) => setTimeout(r, 300 * Math.pow(2, attempt)));
      }
    }
  }
  throw lastError || new Error(`Request failed: ${url}`);
}

export function stripHtml(html) {
  if (!html) return '';
  return String(html)
    .replace(/<[^>]+>/g, ' ')
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/\s+/g, ' ')
    .trim();
}
