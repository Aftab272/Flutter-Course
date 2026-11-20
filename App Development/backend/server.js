import http from 'node:http';
import { URL } from 'node:url';
import { checkRateLimit, loadEnv } from './utils/httpClient.js';
import { fetchShopifyStoreProducts, searchShopifyProducts } from './services/shopifyService.js';
import {
  analyzeEtsyShop,
  getEtsyListingImage,
  getEtsyListingImages,
  isEtsyConfigured,
  searchEtsyProducts,
} from './services/etsyService.js';
import { analyzeEbayShop, isEbayConfigured, searchEbayProducts } from './services/ebayService.js';
import { analyzeAmazonShop, isAmazonConfigured, searchAmazonProducts } from './services/amazonService.js';
import { isKeywordProviderConfigured, researchKeyword } from './services/keywordService.js';

loadEnv();

const PORT = Number(process.env.PORT || 8000);

function sendJson(res, status, payload) {
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  });
  res.end(JSON.stringify(payload, null, 2));
}

function detectPlatform(urlOrInput, fallback = '') {
  const s = String(urlOrInput || '').toLowerCase();
  if (s.includes('etsy.com')) return 'Etsy';
  if (s.includes('amazon.') || s.includes('amzn.')) return 'Amazon';
  if (s.includes('ebay.')) return 'eBay';
  if (s.includes('shopify') || s.includes('.com') || s.includes('.co') || s.includes('.store')) return 'Shopify';
  return fallback || 'Shopify';
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    });
    res.end();
    return;
  }

  const ip = req.socket.remoteAddress || 'unknown';
  const rl = checkRateLimit(ip);
  if (!rl.allowed) {
    sendJson(res, 429, { error: 'Rate limit exceeded. Please retry shortly.' });
    return;
  }

  const reqUrl = new URL(req.url, `http://localhost:${PORT}`);
  const pathname = reqUrl.pathname;
  const start = Date.now();

  try {
    // 1. Health & Provider Status
    if (pathname === '/api/v1/health') {
      sendJson(res, 200, {
        status: 'ok',
        service: 'LootifyScrap Marketplace API Gateway',
        providers: {
          shopify: 'live (public /products.json + optional Storefront token)',
          etsy: isEtsyConfigured() ? 'live' : 'credentials_required (ETSY_API_KEY)',
          ebay: isEbayConfigured() ? 'live' : 'credentials_required (EBAY_CLIENT_ID, EBAY_CLIENT_SECRET)',
          amazon: isAmazonConfigured() ? 'live' : 'credentials_required (RAINFOREST_API_KEY or PA-API 5.0)',
          keywords: isKeywordProviderConfigured()
            ? 'live (DataForSEO + Autocomplete)'
            : 'partial_live (Live Autocomplete active; DataForSEO credentials optional for volume/CPC)',
        },
        timestamp: new Date().toISOString(),
      });
      return;
    }

    // 2. Product Research Endpoint
    if (pathname === '/api/v1/products/search') {
      const q = (reqUrl.searchParams.get('q') || '').trim();
      const marketplace = (reqUrl.searchParams.get('marketplace') || 'All Marketplaces').trim();
      const page = Math.max(1, parseInt(reqUrl.searchParams.get('page') || '1', 10));
      const limit = Math.min(50, Math.max(1, parseInt(reqUrl.searchParams.get('limit') || '20', 10)));
      const minPrice = parseFloat(reqUrl.searchParams.get('minPrice') || '0');
      const maxPrice = parseFloat(reqUrl.searchParams.get('maxPrice') || '999999');
      const sort = reqUrl.searchParams.get('sort') || 'relevance';

      const targets =
        marketplace === 'All Marketplaces' || marketplace === 'All'
          ? ['Shopify', 'Etsy', 'eBay', 'Amazon']
          : [marketplace];

      const results = await Promise.all(
        targets.map(async (m) => {
          try {
            if (m.toLowerCase() === 'shopify') return await searchShopifyProducts(q, { page, limit });
            if (m.toLowerCase() === 'etsy') return await searchEtsyProducts(q, { page, limit });
            if (m.toLowerCase() === 'ebay') return await searchEbayProducts(q, { page, limit });
            if (m.toLowerCase() === 'amazon') return await searchAmazonProducts(q, { page, limit });
            return { marketplace: m, status: 'unsupported', products: [] };
          } catch (err) {
            return { marketplace: m, status: 'error', error: err.message, products: [] };
          }
        }),
      );

      let products = results.flatMap((r) => r.products || []);
      products = products.filter((p) => p.price >= minPrice && p.price <= maxPrice);

      if (sort === 'price_asc') products.sort((a, b) => a.price - b.price);
      if (sort === 'price_desc') products.sort((a, b) => b.price - a.price);

      const providerStatuses = results.map((r) => ({
        marketplace: r.marketplace,
        status: r.status,
        count: (r.products || []).length,
        error: r.error || null,
      }));

      console.log(`[Products] q="${q}" m="${marketplace}" -> ${products.length} live items (${Date.now() - start}ms)`);
      sendJson(res, 200, {
        query: q,
        marketplace,
        page,
        limit,
        total: products.length,
        providerStatuses,
        products,
      });
      return;
    }

    // 3. Keyword Research Endpoint
    if (pathname === '/api/v1/keywords/research') {
      const q = (reqUrl.searchParams.get('q') || '').trim();
      const marketplace = (reqUrl.searchParams.get('marketplace') || 'All Marketplaces').trim();
      if (!q) {
        sendJson(res, 400, { error: 'Query parameter "q" is required.' });
        return;
      }
      const data = await researchKeyword(q, { marketplace });
      console.log(`[Keywords] q="${q}" -> ${data.relatedKeywords.length} live related (${Date.now() - start}ms)`);
      sendJson(res, 200, data);
      return;
    }

    // 4. Shop Analyzer Endpoint
    if (pathname === '/api/v1/shops/analyze') {
      const targetUrl = (reqUrl.searchParams.get('url') || '').trim();
      const explicitMarketplace = (reqUrl.searchParams.get('marketplace') || '').trim();
      if (!targetUrl) {
        sendJson(res, 400, { error: 'Query parameter "url" is required.' });
        return;
      }

      const detected = detectPlatform(targetUrl, explicitMarketplace);
      let payload;
      if (detected === 'Shopify') {
        const resShop = await fetchShopifyStoreProducts(targetUrl, { limit: 50, page: 1 });
        payload = { marketplace: 'Shopify', status: 'live', ...resShop };
      } else if (detected === 'Etsy') {
        payload = await analyzeEtsyShop(targetUrl);
      } else if (detected === 'eBay') {
        payload = await analyzeEbayShop(targetUrl);
      } else if (detected === 'Amazon') {
        payload = await analyzeAmazonShop(targetUrl);
      } else {
        sendJson(res, 400, { error: `Unsupported marketplace: ${detected}` });
        return;
      }

      console.log(`[ShopAnalyze] url="${targetUrl}" platform=${detected} status=${payload.status} (${Date.now() - start}ms)`);
      sendJson(res, 200, payload);
      return;
    }

    // 5. Official Etsy Listing Images Proxy Endpoints
    // GET /api/v1/etsy/listings/:listingId/images
    // GET /api/v1/etsy/listings/:listingId/images/:listingImageId
    const singleImgMatch = pathname.match(/^\/api\/v1\/etsy\/listings\/(\d+)\/images\/(\d+)$/);
    if (singleImgMatch) {
      const payload = await getEtsyListingImage(singleImgMatch[1], singleImgMatch[2]);
      sendJson(res, 200, payload);
      return;
    }

    const allImgsMatch = pathname.match(/^\/api\/v1\/etsy\/listings\/(\d+)\/images$/);
    if (allImgsMatch) {
      const payload = await getEtsyListingImages(allImgsMatch[1]);
      sendJson(res, 200, payload);
      return;
    }

    sendJson(res, 404, { error: 'Endpoint not found. Use /api/v1/health, /api/v1/products/search, /api/v1/keywords/research, /api/v1/shops/analyze, or /api/v1/etsy/listings/{listing_id}/images.' });
  } catch (err) {
    console.error(`[API Error] ${pathname}:`, err.message);
    sendJson(res, 502, { error: err.message || 'Upstream marketplace API failure' });
  }
});

server.listen(PORT, () => {
  console.log(`LootifyScrap Backend API listening on http://localhost:${PORT}/api/v1`);
});
