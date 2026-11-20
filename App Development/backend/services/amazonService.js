import { cache, fetchWithRetry } from '../utils/httpClient.js';

export function isAmazonConfigured() {
  return Boolean(
    process.env.RAINFOREST_API_KEY ||
      (process.env.AMAZON_ACCESS_KEY && process.env.AMAZON_SECRET_KEY && process.env.AMAZON_PARTNER_TAG),
  );
}

export async function searchAmazonProducts(query, { page = 1, limit = 20 } = {}) {
  if (!isAmazonConfigured()) {
    return {
      marketplace: 'Amazon',
      status: 'credentials_required',
      error:
        'Amazon API credentials (RAINFOREST_API_KEY or AMAZON_ACCESS_KEY + AMAZON_SECRET_KEY + AMAZON_PARTNER_TAG) are not configured in backend/.env.',
      total: 0,
      page,
      limit,
      products: [],
    };
  }

  if (process.env.RAINFOREST_API_KEY) {
    const cacheKey = `amazon:rf:${query}:p${page}`;
    const cached = cache.get(cacheKey);
    if (cached) return cached;

    const url = `https://api.rainforestapi.com/request?api_key=${encodeURIComponent(process.env.RAINFOREST_API_KEY)}&type=search&amazon_domain=amazon.com&search_term=${encodeURIComponent(query)}&page=${page}`;
    const res = await fetchWithRetry(url);
    if (!res.ok) throw new Error(`Amazon provider error (HTTP ${res.status})`);
    const data = await res.json();

    const products = (data.search_results || []).slice(0, limit).map((item) => ({
      id: `amazon_${item.asin}`,
      listingId: String(item.asin || ''),
      marketplace: 'Amazon',
      title: item.title || 'Amazon Product',
      price: item.price?.value ?? 0,
      originalPrice: item.prices?.[1]?.value ?? null,
      currency: item.price?.currency || 'USD',
      brand: item.brand || 'Amazon Seller',
      shopName: item.brand || 'Amazon Store',
      shopId: `amazon_${(item.brand || 'store').toLowerCase().replace(/\s+/g, '_')}`,
      category: item.categories?.[0]?.name || 'Amazon Marketplace',
      description: item.title || '',
      tags: (item.categories || []).map((c) => c.name).filter(Boolean),
      imageUrls: item.image ? [item.image] : [],
      productUrl: item.link || `https://www.amazon.com/dp/${item.asin}`,
      variations: [],
      stockStatus: item.availability?.raw || 'See Amazon listing',
      rating: item.rating ?? null,
      reviewCount: item.ratings_total ?? null,
      shippingInfo: item.is_prime ? 'Amazon Prime Eligible' : 'Standard Shipping',
      createdAt: new Date().toISOString(),
      isLiveData: true,
    }));

    const out = {
      marketplace: 'Amazon',
      status: 'live',
      total: data.pagination?.total_results || products.length,
      page,
      limit,
      products,
    };
    cache.set(cacheKey, out, 5 * 60 * 1000);
    return out;
  }

  return {
    marketplace: 'Amazon',
    status: 'credentials_required',
    error: 'Configure RAINFOREST_API_KEY (recommended) or signed PA-API 5.0 credentials in backend/.env.',
    total: 0,
    page,
    limit,
    products: [],
  };
}

export async function analyzeAmazonShop(urlOrSeller) {
  if (!isAmazonConfigured()) {
    return {
      marketplace: 'Amazon',
      status: 'credentials_required',
      error: 'Amazon API credentials are not configured in backend/.env.',
      shop: null,
      products: [],
    };
  }
  const match = String(urlOrSeller).match(/amazon\.[^/]+\/(?:shops|stores)\/([^/?#]+)/i);
  const storeName = match ? match[1] : String(urlOrSeller).trim();
  const res = await searchAmazonProducts(storeName, { limit: 25, page: 1 });
  return {
    marketplace: 'Amazon',
    status: 'live',
    shop: {
      id: `amazon_${storeName.toLowerCase()}`,
      name: storeName,
      marketplace: 'Amazon',
      url: `https://www.amazon.com/s?k=${encodeURIComponent(storeName)}`,
      logoUrl: res.products[0]?.imageUrls[0] || '',
      description: `Live Amazon seller storefront lookup: ${storeName}`,
      totalListings: res.total,
      rating: res.products[0]?.rating ?? null,
      reviewCount: res.products[0]?.reviewCount ?? null,
      totalSales: null,
      monthlyRevenueEst: null,
      salesNote: 'Private Amazon seller revenue requires Amazon SP-API OAuth authorization.',
      isLiveData: true,
    },
    products: res.products,
  };
}
