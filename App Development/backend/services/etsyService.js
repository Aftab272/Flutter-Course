import { cache, fetchWithRetry, stripHtml } from '../utils/httpClient.js';

const ETSY_BASE = 'https://openapi.etsy.com/v3/application';

export function isEtsyConfigured() {
  return Boolean(process.env.ETSY_API_KEY && process.env.ETSY_API_KEY.trim().length > 5);
}

function etsyHeaders() {
  return {
    'x-api-key': process.env.ETSY_API_KEY.trim(),
    Accept: 'application/json',
  };
}

function normalizeEtsyListing(item, shopNameFallback = 'Etsy Shop') {
  const priceAmount = item.price?.amount ?? 0;
  const divisor = item.price?.divisor || 100;
  const price = Number((priceAmount / divisor).toFixed(2));
  const currency = item.price?.currency_code || 'USD';
  const images = Array.isArray(item.images)
    ? item.images.map((i) => i.url_570xN || i.url_fullxfull).filter(Boolean)
    : [];

  return {
    id: `etsy_${item.listing_id}`,
    listingId: String(item.listing_id),
    marketplace: 'Etsy',
    title: item.title || 'Etsy Listing',
    price,
    originalPrice: null,
    currency,
    brand: shopNameFallback,
    shopName: item.shop?.shop_name || shopNameFallback,
    shopId: `etsy_${item.shop_id || 'shop'}`,
    category: (Array.isArray(item.taxonomy_path) && item.taxonomy_path.join(' > ')) || 'Handmade & Crafts',
    description: stripHtml(item.description || ''),
    tags: Array.isArray(item.tags) ? item.tags.slice(0, 13) : [],
    imageUrls: images,
    productUrl: item.url || `https://www.etsy.com/listing/${item.listing_id}`,
    variations: [],
    stockStatus: (item.quantity ?? 1) > 0 ? `In Stock (${item.quantity})` : 'Out of Stock',
    rating: null,
    reviewCount: item.num_favorers ?? null,
    shippingInfo: item.is_digital ? 'Instant Digital Download' : 'Ships from seller',
    createdAt: item.original_creation_timestamp
      ? new Date(item.original_creation_timestamp * 1000).toISOString()
      : new Date().toISOString(),
    isLiveData: true,
  };
}

export async function searchEtsyProducts(query, { page = 1, limit = 20 } = {}) {
  if (!isEtsyConfigured()) {
    return {
      marketplace: 'Etsy',
      status: 'credentials_required',
      error: 'ETSY_API_KEY is not configured in backend/.env. Add your Etsy Open API v3 key to fetch live Etsy listings.',
      total: 0,
      page,
      limit,
      products: [],
    };
  }

  const offset = (page - 1) * limit;
  const cacheKey = `etsy:search:${query}:p${page}:l${limit}`;
  const cached = cache.get(cacheKey);
  if (cached) return cached;

  const url = `${ETSY_BASE}/listings/active?keywords=${encodeURIComponent(query)}&limit=${Math.min(limit, 100)}&offset=${offset}&includes=Images,Shop`;
  const res = await fetchWithRetry(url, { headers: etsyHeaders() });
  if (!res.ok) {
    throw new Error(`Etsy Open API error HTTP ${res.status}`);
  }
  const data = await res.json();
  const products = (data.results || []).map((item) => normalizeEtsyListing(item));

  const out = {
    marketplace: 'Etsy',
    status: 'live',
    total: data.count || products.length,
    page,
    limit,
    products,
  };
  cache.set(cacheKey, out, 5 * 60 * 1000);
  return out;
}

/**
 * Fetch ALL original images for a specific Etsy listing via official Etsy Open API v3:
 * GET https://openapi.etsy.com/v3/application/listings/{listing_id}/images
 */
export async function getEtsyListingImages(listingId) {
  if (!isEtsyConfigured()) {
    return {
      status: 'credentials_required',
      error: 'ETSY_API_KEY is not configured in backend/.env.',
      images: [],
    };
  }

  const cacheKey = `etsy:listing:images:${listingId}`;
  const cached = cache.get(cacheKey);
  if (cached) return cached;

  const url = `${ETSY_BASE}/listings/${encodeURIComponent(listingId)}/images`;
  const res = await fetchWithRetry(url, { headers: etsyHeaders() });
  if (!res.ok) throw new Error(`Etsy Listing Images API error (HTTP ${res.status})`);
  const data = await res.json();
  const images = (data.results || []).map((img) => ({
    listingImageId: img.listing_image_id,
    rank: img.rank,
    urlFull: img.url_fullxfull || img.url_570xN,
    urlMedium: img.url_570xN || img.url_fullxfull,
    urlThumb: img.url_170x135 || img.url_75x75,
    altText: img.alt_text || '',
  }));

  const out = { status: 'live', count: data.count || images.length, images };
  cache.set(cacheKey, out, 10 * 60 * 1000);
  return out;
}

/**
 * Fetch a single specific image for an Etsy listing via official Etsy Open API v3:
 * GET https://openapi.etsy.com/v3/application/listings/{listing_id}/images/{listing_image_id}
 */
export async function getEtsyListingImage(listingId, listingImageId) {
  if (!isEtsyConfigured()) {
    return {
      status: 'credentials_required',
      error: 'ETSY_API_KEY is not configured in backend/.env.',
      image: null,
    };
  }

  const url = `${ETSY_BASE}/listings/${encodeURIComponent(listingId)}/images/${encodeURIComponent(listingImageId)}`;
  const res = await fetchWithRetry(url, { headers: etsyHeaders() });
  if (!res.ok) throw new Error(`Etsy Single Image API error (HTTP ${res.status})`);
  const img = await res.json();
  return {
    status: 'live',
    image: {
      listingImageId: img.listing_image_id,
      rank: img.rank,
      urlFull: img.url_fullxfull || img.url_570xN,
      urlMedium: img.url_570xN || img.url_fullxfull,
      urlThumb: img.url_170x135 || img.url_75x75,
      altText: img.alt_text || '',
    },
  };
}

/**
 * Fetch complete original Etsy listing + all its original images by listing URL or listing ID
 */
export async function getEtsyListingByUrl(urlOrId) {
  if (!isEtsyConfigured()) {
    return {
      marketplace: 'Etsy',
      status: 'credentials_required',
      error: 'ETSY_API_KEY is not configured in backend/.env. Add your Etsy Open API v3 key to fetch original Etsy listing details & images.',
      shop: null,
      product: null,
      products: [],
    };
  }

  const idMatch = String(urlOrId).match(/\/listing\/(\d+)/i) || String(urlOrId).match(/^(\d+)$/);
  if (!idMatch) throw new Error('Invalid Etsy listing URL or listing_id');
  const listingId = idMatch[1];

  const [listingRes, imagesRes] = await Promise.all([
    fetchWithRetry(`${ETSY_BASE}/listings/${listingId}`, { headers: etsyHeaders() }),
    getEtsyListingImages(listingId),
  ]);

  if (!listingRes.ok) throw new Error(`Etsy Listing API error (HTTP ${listingRes.status})`);
  const rawListing = await listingRes.json();

  let shopName = 'Etsy Shop';
  let shopObj = null;
  if (rawListing.shop_id) {
    try {
      const sRes = await fetchWithRetry(`${ETSY_BASE}/shops/${rawListing.shop_id}`, { headers: etsyHeaders() });
      if (sRes.ok) {
        const s = await sRes.json();
        shopName = s.shop_name || shopName;
        shopObj = {
          id: `etsy_${s.shop_id}`,
          name: shopName,
          marketplace: 'Etsy',
          url: s.url || `https://www.etsy.com/shop/${shopName}`,
          logoUrl: s.icon_url_fullxfull || '',
          description: s.title || '',
          totalListings: s.listing_active_count ?? 1,
          totalSales: s.transaction_sold_count ?? null,
          rating: s.review_average ?? null,
          reviewCount: s.review_count ?? null,
          monthlyRevenueEst: null,
          isLiveData: true,
        };
      }
    } catch (_) {}
  }

  const normalized = normalizeEtsyListing(rawListing, shopName);
  const fullImageUrls = (imagesRes.images || []).map((i) => i.urlFull).filter(Boolean);
  if (fullImageUrls.length > 0) {
    normalized.imageUrls = fullImageUrls;
  }

  return {
    marketplace: 'Etsy',
    status: 'live',
    shop: shopObj,
    product: normalized,
    products: [normalized],
  };
}

export async function analyzeEtsyShop(shopUrlOrName) {
  // If user passed an Etsy product listing URL (/listing/{id}), fetch that exact listing + its official images!
  if (/\/listing\/\d+/i.test(String(shopUrlOrName))) {
    return getEtsyListingByUrl(shopUrlOrName);
  }
  if (!isEtsyConfigured()) {
    return {
      marketplace: 'Etsy',
      status: 'credentials_required',
      error: 'ETSY_API_KEY is not configured in backend/.env. Add your Etsy Open API v3 key to analyze live Etsy shops.',
      shop: null,
      products: [],
    };
  }

  const match = String(shopUrlOrName).match(/etsy\.com\/shop\/([^/?#]+)/i);
  const shopName = match ? match[1] : String(shopUrlOrName).trim();

  const searchRes = await fetchWithRetry(
    `${ETSY_BASE}/shops?shop_name=${encodeURIComponent(shopName)}`,
    { headers: etsyHeaders() },
  );
  if (!searchRes.ok) throw new Error(`Etsy shop lookup failed (HTTP ${searchRes.status})`);
  const searchData = await searchRes.json();
  const rawShop = searchData.results?.[0];
  if (!rawShop) throw new Error(`Etsy shop "${shopName}" not found`);

  const listingsRes = await fetchWithRetry(
    `${ETSY_BASE}/shops/${rawShop.shop_id}/listings/active?limit=50&includes=Images`,
    { headers: etsyHeaders() },
  );
  const listingsData = listingsRes.ok ? await listingsRes.json() : { results: [] };
  const products = (listingsData.results || []).map((item) => normalizeEtsyListing(item, rawShop.shop_name));

  return {
    marketplace: 'Etsy',
    status: 'live',
    shop: {
      id: `etsy_${rawShop.shop_id}`,
      name: rawShop.shop_name,
      marketplace: 'Etsy',
      url: rawShop.url || `https://www.etsy.com/shop/${rawShop.shop_name}`,
      logoUrl: rawShop.icon_url_fullxfull || '',
      description: rawShop.title || rawShop.announcement || '',
      totalListings: rawShop.listing_active_count ?? products.length,
      totalSales: rawShop.transaction_sold_count ?? null,
      rating: rawShop.review_average ?? null,
      reviewCount: rawShop.review_count ?? null,
      monthlyRevenueEst: null,
      salesNote: 'Revenue requires private Etsy OAuth seller authorization.',
      isLiveData: true,
    },
    products,
  };
}
