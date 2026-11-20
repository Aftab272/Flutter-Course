import { cache, fetchWithRetry } from '../utils/httpClient.js';

export function isKeywordProviderConfigured() {
  return Boolean(process.env.DATAFORSEO_LOGIN && process.env.DATAFORSEO_PASSWORD);
}

/**
 * Fetches REAL live autocomplete related & long-tail keywords from public search suggest endpoints.
 * Never fabricates search volume, CPC, or CTR when a paid keyword provider is not configured.
 */
async function fetchLiveAutocompleteSuggestions(query, marketplace) {
  const clean = String(query || '').trim();
  if (!clean) return [];

  const cacheKey = `kw:suggest:${marketplace}:${clean.toLowerCase()}`;
  const cached = cache.get(cacheKey);
  if (cached) return cached;

  const queriesToProbe = [
    clean,
    marketplace && marketplace !== 'All Marketplaces' ? `${clean} ${marketplace.toLowerCase()}` : `${clean} gift`,
    `best ${clean}`,
  ];

  const found = new Set();
  await Promise.all(
    queriesToProbe.map(async (q) => {
      try {
        const url = `https://suggestqueries.google.com/complete/search?client=firefox&q=${encodeURIComponent(q)}`;
        const res = await fetchWithRetry(url, {}, { retries: 1, timeoutMs: 4500 });
        if (res.ok) {
          const json = await res.json();
          const suggestions = Array.isArray(json[1]) ? json[1] : [];
          for (const s of suggestions) {
            const text = String(s).trim();
            if (text && text.toLowerCase() !== clean.toLowerCase()) {
              found.add(text);
            }
          }
        }
      } catch (_) {}
    }),
  );

  const list = Array.from(found).slice(0, 15);
  cache.set(cacheKey, list, 10 * 60 * 1000);
  return list;
}

export async function researchKeyword(query, { marketplace = 'All Marketplaces' } = {}) {
  const clean = String(query || '').trim();
  if (!clean) throw new Error('Keyword query is required');

  // 1. Always fetch REAL live related & long-tail keywords
  const liveRelated = await fetchLiveAutocompleteSuggestions(clean, marketplace);

  // 2. If DataForSEO credentials exist, fetch real Search Volume, Competition, CPC & Monthly Trends
  if (isKeywordProviderConfigured()) {
    const auth = Buffer.from(`${process.env.DATAFORSEO_LOGIN}:${process.env.DATAFORSEO_PASSWORD}`).toString('base64');
    const res = await fetchWithRetry(
      'https://api.dataforseo.com/v3/keywords_data/google_ads/search_volume/live',
      {
        method: 'POST',
        headers: {
          Authorization: `Basic ${auth}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify([{ keywords: [clean, ...liveRelated.slice(0, 10)], language_code: 'en', location_code: 2840 }]),
      },
    );
    if (res.ok) {
      const data = await res.json();
      const items = data.tasks?.[0]?.result || [];
      const primary = items[0] || {};
      return {
        keyword: clean,
        marketplace,
        dataSource: 'DataForSEO Live API + Live Autocomplete',
        metricsAvailable: true,
        searchVolume: primary.search_volume ?? null,
        competition: primary.competition_index ?? null,
        competitionLevel: primary.competition ?? 'Data Unavailable',
        cpc: primary.cpc ?? null,
        ctr: null,
        monthlyTrends: primary.monthly_searches || [],
        relatedKeywords: items.slice(1).map((it) => ({
          keyword: it.keyword,
          searchVolume: it.search_volume ?? null,
          competition: it.competition_index ?? null,
          cpc: it.cpc ?? null,
          isLongTail: String(it.keyword || '').split(/\s+/).length >= 3,
        })),
        recommendedTags: liveRelated.map((k) => (k.length > 20 ? k.slice(0, 20).trim() : k)).slice(0, 13),
      };
    }
  }

  // 3. Honest response when paid volume provider is not configured:
  // Return REAL live related/long-tail keywords + tags, and mark paid metrics as Data Unavailable!
  return {
    keyword: clean,
    marketplace,
    dataSource: 'Live Search Autocomplete (Real Related & Long-Tail Keywords)',
    metricsAvailable: false,
    metricsNote: 'Exact monthly search volume, CPC, and historical trends require DATAFORSEO_LOGIN & DATAFORSEO_PASSWORD in backend/.env.',
    searchVolume: null,
    competition: null,
    competitionLevel: 'Data Unavailable',
    cpc: null,
    ctr: null,
    monthlyTrends: [],
    relatedKeywords: liveRelated.map((kw) => ({
      keyword: kw,
      searchVolume: null,
      competition: null,
      cpc: null,
      isLongTail: kw.split(/\s+/).length >= 3,
    })),
    recommendedTags: [clean, ...liveRelated]
      .map((k) => (k.length > 20 ? k.slice(0, 20).trim() : k))
      .filter((v, i, a) => v && a.indexOf(v) === i)
      .slice(0, 13),
  };
}
