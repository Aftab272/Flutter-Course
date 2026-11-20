import { cache, fetchWithRetry } from '../utils/httpClient.js';

const EBAY_TOKEN_URL = 'https://api.ebay.com/identity/v1/oauth2/token';
const EBAY_BROWSE_URL = 'https://api.ebay.com/buy/browse/v1/item_summary/search';

export function isEbayConfigured() {
  return Boolean(process.env.EBAY_CLIENT_ID && process.env.EBAY_CLIENT_SECRET);
}

async function getEbayAccessToken() {
  const cached = cache.get('ebay:oauth:token');
  if (cached) return cached;

  const basic = Buffer.from(`${process.env.EBAY_CLIENT_ID}:${process.env.EBAY_CLIENT_SECRET}`).toString('base64');
  const res = await fetchWithRetry(EBAY_TOKEN_URL, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${basic}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: 'grant_type=client_credentials&scope=https%3A%2F%2Fapi.ebay.com%2Foauth%2Fapi_scope',
  });
  if (!res.ok) throw new Error(`eBay OAuth failed (HTTP ${res.status})`);
  const data = await res.json();
  cache.set('ebay:oauth:token', data.access_token, Math.max(60_000, (data.expires_in - 120) * 1000));
  return data.access_token;
}

export async function searchEbayProducts(query, { page = 1, limit = 20 } = {}) {
  if (!isEbayConfigured()) {
    return {
      marketplace: 'eBay',
      status: 'credentials_required',
      error: 'EBAY_CLIENT_ID and EBAY_CLIENT_SECRET are not configured in backend/.env.',
      total: 0,
      page,
      limit,
      products: [],
    };
  }

  const offset = (page - 1) * limit;
  const cacheKey = `ebay:search:${query}:p${page}:l${limit}`;
  const cached = cache.get(cacheKey);
  if (cached) return cached;

  const token = await getEbayAccessToken();
  const url = `${EBAY_BROWSE_URL}?q=${encodeURIComponent(query)}&limit=${Math.min(limit, 50)}&offset=${offset}`;
  const res = await fetchWithRetry(url, {
    headers: {
      Authorization: `Bearer ${token}`,
      'X-EBAY-C-MARKETPLACE-ID': process.env.EBAY_MARKETPLACE_ID || 'EBAY_US',
    },
  });
  if (!res.ok) throw new Error(`eBay Browse API error (HTTP ${res.status})`);
  const data = await res.json();

  const products = (data.itemSummaries || []).map((item) => ({
    id: `ebay_${item.itemId}`,
    listingId: String(item.itemId),
    marketplace: 'eBay',
    title: item.title || 'eBay Listing',
    price: parseFloat(item.price?.value) || 0,
    originalPrice: null,
    currency: item.price?.currency || 'USD',
    brand: item.seller?.username || 'eBay Seller',
    shopName: item.seller?.username || 'eBay Seller',
    shopId: `ebay_${item.seller?.username || 'seller'}`,
    category: item.categories?.[0]?.categoryName || 'Marketplace',
    description: item.shortDescription || `${item.condition || 'Listed'} item on eBay`,
    tags: (item.categories || []).map((c) => c.categoryName).filter(Boolean),
    imageUrls: [item.image?.imageUrl, ...(item.additionalImages || []).map((i) => i.imageUrl)].filter(Boolean),
    productUrl: item.itemWebUrl || `https://www.ebay.com/itm/${item.itemId}`,
    variations: [],
    stockStatus: item.condition || 'Available',
    rating: item.seller?.feedbackPercentage ? Number((parseFloat(item.seller.feedbackPercentage) / 20).toFixed(1)) : null,
    reviewCount: item.seller?.feedbackScore ?? null,
    shippingInfo: item.shippingOptions?.[0]?.shippingCost?.value
      ? `Shipping: ${item.shippingOptions[0].shippingCost.value} ${item.shippingOptions[0].shippingCost.currency}`
      : 'See listing for shipping',
    createdAt: item.itemCreationDate || new Date().toISOString(),
    isLiveData: true,
  }));

  const out = {
    marketplace: 'eBay',
    status: 'live',
    total: data.total || products.length,
    page,
    limit,
    products,
  };
  cache.set(cacheKey, out, 5 * 60 * 1000);
  return out;
}

export async function analyzeEbayShop(sellerUrlOrName) {
  if (!isEbayConfigured()) {
    return {
      marketplace: 'eBay',
      status: 'credentials_required',
      error: 'EBAY_CLIENT_ID and EBAY_CLIENT_SECRET are not configured in backend/.env.',
      shop: null,
      products: [],
    };
  }
  const match = String(sellerUrlOrName).match(/ebay\.[^/]+\/(?:usr|str)\/([^/?#]+)/i);
  const seller = match ? match[1] : String(sellerUrlOrName).trim();
  const res = await searchEbayProducts(`seller:${seller}`, { limit: 40, page: 1 });
  return {
    marketplace: 'eBay',
    status: 'live',
    shop: {
      id: `ebay_${seller}`,
      name: seller,
      marketplace: 'eBay',
      url: `https://www.ebay.com/usr/${seller}`,
      logoUrl: res.products[0]?.imageUrls[0] || '',
      description: `Live eBay seller store: ${seller}`,
      totalListings: res.total,
      rating: res.products[0]?.rating ?? null,
      reviewCount: res.products[0]?.reviewCount ?? null,
      totalSales: null,
      monthlyRevenueEst: null,
      salesNote: 'Private eBay order revenue requires eBay Sell OAuth authorization.',
      isLiveData: true,
    },
    products: res.products,
  };
}
