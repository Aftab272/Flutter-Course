import { cache, fetchWithRetry, stripHtml } from '../utils/httpClient.js';

const DEFAULT_STORES = (process.env.SHOPIFY_DEFAULT_STORES || 'allbirds.com,ridge.com,fellowproducts.com')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);

function normalizeDomain(input) {
  let clean = String(input || '').trim().toLowerCase();
  clean = clean.replace(/^https?:\/\//, '').replace(/^www\./, '');
  const host = clean.split('/')[0].split('?')[0];
  return host;
}

function normalizeShopifyProduct(raw, domain, shopName, currency = 'USD') {
  const variants = Array.isArray(raw.variants) ? raw.variants : [];
  const firstVariant = variants[0] || {};
  const price = parseFloat(firstVariant.price) || 0;
  const compareAt = parseFloat(firstVariant.compare_at_price);
  const images = Array.isArray(raw.images)
    ? raw.images.map((img) => img.src).filter((s) => typeof s === 'string' && s.startsWith('http'))
    : [];
  const tags = Array.isArray(raw.tags)
    ? raw.tags.map((t) => String(t).trim()).filter(Boolean)
    : typeof raw.tags === 'string'
      ? raw.tags.split(',').map((t) => t.trim()).filter(Boolean)
      : [];
  const available = variants.some((v) => v.available === true);

  return {
    id: `shopify_${domain}_${raw.id}`,
    listingId: String(raw.id),
    marketplace: 'Shopify',
    title: raw.title || 'Untitled Shopify Product',
    price,
    originalPrice: Number.isFinite(compareAt) && compareAt > price ? compareAt : null,
    currency,
    brand: raw.vendor || shopName,
    shopName: shopName || raw.vendor || domain,
    shopId: `shopify_${domain}`,
    category: raw.product_type || 'General',
    description: stripHtml(raw.body_html) || 'No description provided by store.',
    tags: tags.slice(0, 13),
    imageUrls: images,
    productUrl: `https://${domain}/products/${raw.handle}`,
    variations: variants.slice(0, 12).map((v) => ({
      id: String(v.id),
      title: v.title || 'Default',
      price: parseFloat(v.price) || price,
      available: Boolean(v.available),
    })),
    stockStatus: available ? 'In Stock' : 'Out of Stock',
    rating: null,
    reviewCount: null,
    shippingInfo: 'Calculated at store checkout',
    createdAt: raw.created_at || raw.published_at || new Date().toISOString(),
    isLiveData: true,
  };
}

/**
 * Fetch genuine real products from a public Shopify store via /products.json
 */
export async function fetchShopifyStoreProducts(domainOrUrl, { limit = 50, page = 1 } = {}) {
  const domain = normalizeDomain(domainOrUrl);
  if (!domain) throw new Error('Invalid Shopify store domain');

  const cacheKey = `shopify:store:${domain}:p${page}:l${limit}`;
  const cached = cache.get(cacheKey);
  if (cached) return cached;

  const url = `https://${domain}/products.json?limit=${Math.min(limit, 250)}&page=${page}`;
  const res = await fetchWithRetry(url);
  if (!res.ok) {
    throw new Error(`Shopify store "${domain}" returned HTTP ${res.status}`);
  }
  const data = await res.json();
  const rawProducts = Array.isArray(data.products) ? data.products : [];

  // Optional store metadata from /meta.json
  let shopName = domain.split('.')[0];
  let currency = 'USD';
  let shopDescription = '';
  try {
    const metaRes = await fetchWithRetry(`https://${domain}/meta.json`, {}, { retries: 0, timeoutMs: 4000 });
    if (metaRes.ok) {
      const meta = await metaRes.json();
      if (meta.name) shopName = meta.name;
      if (meta.currency) currency = meta.currency;
      if (meta.description) shopDescription = stripHtml(meta.description);
    }
  } catch (_) {}

  const products = rawProducts.map((p) => normalizeShopifyProduct(p, domain, shopName, currency));
  const result = {
    shop: {
      id: `shopify_${domain}`,
      name: shopName,
      marketplace: 'Shopify',
      url: `https://${domain}`,
      logoUrl: products[0]?.imageUrls[0] || '',
      description: shopDescription || `Live Shopify storefront at https://${domain}`,
      totalListings: products.length,
      avgPrice: products.length
        ? Number((products.reduce((acc, p) => acc + p.price, 0) / products.length).toFixed(2))
        : 0,
      currency,
      rating: null,
      reviewCount: null,
      totalSales: null,
      monthlyRevenueEst: null,
      salesNote: 'Private sales & revenue are not exposed by public Shopify storefront endpoints without Admin OAuth.',
      isLiveData: true,
    },
    products,
  };

  cache.set(cacheKey, result, 5 * 60 * 1000);
  return result;
}

/**
 * Search real products across authorized/public Shopify storefronts
 */
export async function searchShopifyProducts(query, { page = 1, limit = 20 } = {}) {
  const q = String(query || '').trim().toLowerCase();
  const tokens = q.split(/\s+/).filter((t) => t.length >= 2);
  const allMatches = [];

  await Promise.all(
    DEFAULT_STORES.map(async (domain) => {
      try {
        const { products } = await fetchShopifyStoreProducts(domain, { limit: 100, page: 1 });
        for (const p of products) {
          if (!q) {
            allMatches.push(p);
            continue;
          }
          const hay = `${p.title} ${p.category} ${p.brand} ${p.tags.join(' ')}`.toLowerCase();
          if (hay.includes(q) || (tokens.length > 0 && tokens.every((t) => hay.includes(t)))) {
            allMatches.push(p);
          }
        }
      } catch (err) {
        console.warn(`[ShopifyService] Skipping ${domain}: ${err.message}`);
      }
    }),
  );

  const start = (page - 1) * limit;
  return {
    marketplace: 'Shopify',
    status: 'live',
    total: allMatches.length,
    page,
    limit,
    products: allMatches.slice(start, start + limit),
  };
}
