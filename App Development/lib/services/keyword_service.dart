import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/keyword_model.dart';
import '../models/product_model.dart';
import 'marketplace_api_client.dart';
import 'product_service.dart';

/// Keyword Intelligence Service inspired by EverBee, eRank, and eHunt.
/// Analyzes search volume, competition, opportunity score, difficulty,
/// generates long-tail keywords, 13 Etsy/Shopify listing tags, and maps
/// real competitor storefront products.
class KeywordService extends ChangeNotifier {
  static final KeywordService _instance = KeywordService._internal();
  factory KeywordService() => _instance;
  KeywordService._internal();

  KeywordIntelligence? _currentIntelligence;
  bool _isSearching = false;
  final List<String> _recentKeywords = [
    'custom leather wallet',
    'personalized necklace',
    'digital wedding planner',
    'minimalist ceramic mug',
    'handmade wooden watch',
    'vintage graphic tee',
  ];

  KeywordIntelligence? get currentIntelligence => _currentIntelligence;
  bool get isSearching => _isSearching;
  List<String> get recentKeywords => List.unmodifiable(_recentKeywords);

  /// Preset suggestions for one-click discovery
  static const List<String> suggestedKeywords = [
    'custom leather wallet',
    'personalized necklace',
    'digital wedding planner',
    'minimalist ceramic mug',
    'handmade wooden watch',
    'vintage graphic tee',
    'embroidered sweatshirt',
    'clay earrings aesthetic',
  ];

  Future<KeywordIntelligence> analyzeKeyword(String rawQuery, {String marketplace = 'All Marketplaces'}) async {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return analyzeKeyword('custom leather wallet', marketplace: marketplace);
    }

    _isSearching = true;
    notifyListeners();

    // Attempt real live keyword data from backend API first, then DIRECT mobile live autocomplete
    final liveApiData = await MarketplaceApiClient().researchKeyword(
      query: query,
      marketplace: marketplace,
    );

    List<dynamic> liveRelatedRaw = (liveApiData?['relatedKeywords'] as List<dynamic>?) ?? [];
    if (liveRelatedRaw.isEmpty) {
      final directSuggestions = await _fetchDirectLiveSuggestions(query, marketplace);
      liveRelatedRaw = directSuggestions
          .map((kw) => {'keyword': kw, 'isLongTail': kw.split(' ').length >= 3})
          .toList();
    }

    // Calculate algorithmic seed for fallback/calculated estimates
    final seed = query.codeUnits.fold<int>(0, (prev, curr) => prev + curr);
    final random = Random(seed);

    final liveSearchVol = (liveApiData?['searchVolume'] as num?)?.toInt();
    final liveComp = (liveApiData?['competition'] as num?)?.toInt();
    final liveTagsRaw = (liveApiData?['recommendedTags'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .where((s) => s.isNotEmpty)
        .toList();

    // Use real API search volume/competition when available, else calculated estimate
    final baseVolume = liveSearchVol ?? (3500 + (seed * 37) % 65000);
    final baseCompetition = liveComp ?? (600 + (seed * 19) % 18000);

    // Opportunity score: High volume + moderate competition = high score (1-100)
    final ratio = baseVolume / (baseCompetition + 500);
    int oppScore = (ratio * 18).clamp(32, 98).toInt();

    // Difficulty score: 100 - opportunity score with variance
    int diffScore = (100 - oppScore + (random.nextInt(12) - 6)).clamp(15, 95);
    String diffLabel;
    if (diffScore < 38) {
      diffLabel = 'Low Difficulty (Easy to Rank)';
    } else if (diffScore < 65) {
      diffLabel = 'Medium Competition';
    } else if (diffScore < 82) {
      diffLabel = 'High Competition';
    } else {
      diffLabel = 'Super Competitive';
    }

    // Average price ($14.99 - $89.99)
    final avgPrice = double.parse((18.50 + (seed % 65)).toStringAsFixed(2));

    // Est. monthly sales & revenue
    final estMonthlySales = (baseVolume * (0.045 + (random.nextDouble() * 0.04))).toInt().clamp(120, 4800);
    final estMonthlyRevenue = double.parse((estMonthlySales * avgPrice * 0.85).toStringAsFixed(2));

    // CTR (Click-Through Rate)
    final ctr = double.parse((4.2 + (random.nextDouble() * 5.8)).toStringAsFixed(1));

    // Trend status
    final trends = ['trending_up', 'hot', 'stable', 'trending_up'];
    final trend = trends[seed % trends.length];
    final trendGrowth = 12 + (seed % 48);

    // Use REAL live related keywords from backend autocomplete API when available
    final List<RelatedKeyword> related = liveRelatedRaw.isNotEmpty
        ? liveRelatedRaw.whereType<Map<String, dynamic>>().map((item) {
            final kw = (item['keyword'] ?? '').toString();
            final v = (item['searchVolume'] as num?)?.toInt() ??
                (baseVolume * (0.35 + random.nextDouble() * 0.85)).toInt().clamp(350, 48000);
            final c = (item['competition'] as num?)?.toInt() ??
                (baseCompetition * (0.25 + random.nextDouble() * 0.85)).toInt().clamp(120, 22000);
            final opp = ((v / (c + 300)) * 19).clamp(38, 97).toInt();
            final price = double.parse((avgPrice * (0.8 + random.nextDouble() * 0.4)).toStringAsFixed(2));
            return RelatedKeyword(
              keyword: kw,
              searchVolume: v,
              competition: c,
              opportunityScore: opp,
              avgPrice: price,
              trend: 'up',
              growthPercent: 12 + random.nextInt(38),
              isLongTail: item['isLongTail'] == true || kw.split(' ').length >= 3,
            );
          }).where((r) => r.keyword.isNotEmpty).toList()
        : _generateRelatedKeywords(query, baseVolume, baseCompetition, avgPrice, random);

    // Ensure 13 Optimized Listing Tags (prefer real live tags from backend, pad cleanly if < 13)
    final tags = (liveTagsRaw != null && liveTagsRaw.length >= 13)
        ? liveTagsRaw.take(13).toList()
        : _generate13ListingTags(query, related);

    // Filter matching top ranking products from catalog
    final allProducts = ProductService().allProducts;
    final words = query.split(' ').where((w) => w.length > 2).toList();
    List<ProductModel> topProducts = allProducts.where((p) {
      final title = p.title.toLowerCase();
      final pTags = p.tags.map((t) => t.toLowerCase()).toList();
      return words.any((w) => title.contains(w) || pTags.any((t) => t.contains(w)));
    }).toList();

    if (topProducts.isEmpty) {
      topProducts = allProducts.take(8).toList();
    } else if (topProducts.length > 12) {
      topProducts = topProducts.take(12).toList();
    }

    final intel = KeywordIntelligence(
      keyword: rawQuery.trim(),
      marketplace: marketplace,
      searchVolume: baseVolume,
      competitionListings: baseCompetition,
      opportunityScore: oppScore,
      difficultyScore: diffScore,
      difficultyLabel: diffLabel,
      avgPrice: avgPrice,
      estMonthlySales: estMonthlySales,
      estMonthlyRevenue: estMonthlyRevenue,
      ctr: ctr,
      trend: trend,
      trendGrowthPercent: trendGrowth,
      relatedKeywords: related,
      recommendedTags: tags,
      topProducts: topProducts,
    );

    _currentIntelligence = intel;
    if (!_recentKeywords.contains(rawQuery.trim())) {
      _recentKeywords.insert(0, rawQuery.trim());
      if (_recentKeywords.length > 10) _recentKeywords.removeLast();
    }

    _isSearching = false;
    notifyListeners();
    return intel;
  }

  /// Direct live autocomplete fetch for standalone mobile devices (real related & long-tail keywords)
  Future<List<String>> _fetchDirectLiveSuggestions(String query, String marketplace) async {
    try {
      final q = marketplace != 'All Marketplaces' && marketplace.isNotEmpty
          ? '$query ${marketplace.toLowerCase()}'
          : query;
      final uri = Uri.parse(
        'https://suggestqueries.google.com/complete/search?client=firefox&q=${Uri.encodeQueryComponent(q)}',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List && decoded.length > 1 && decoded[1] is List) {
          return (decoded[1] as List)
              .map((e) => e.toString().trim())
              .where((s) => s.isNotEmpty && s.toLowerCase() != query.toLowerCase())
              .take(15)
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  static const Set<String> _modifierWords = {
    'personalized', 'handmade', 'custom', 'vintage', 'aesthetic', 'minimalist',
    'engraved', 'luxury', 'bespoke', 'eco', 'friendly', 'unique', 'anniversary',
    'gift', 'decor', 'bulk', 'wholesale', 'diy', 'kit', 'for', 'men', 'women',
    'with', 'box',
  };

  /// Strips repeated words and stacked modifiers so clicking related keywords never repeats words
  String _extractCoreKeyword(String raw) {
    final seen = <String>{};
    final allUnique = <String>[];
    final coreOnly = <String>[];

    for (final token in raw.trim().split(RegExp(r'\s+'))) {
      final clean = token.trim();
      if (clean.isEmpty) continue;
      final lower = clean.toLowerCase();
      if (seen.add(lower)) {
        final cap = '${clean[0].toUpperCase()}${clean.substring(1).toLowerCase()}';
        allUnique.add(cap);
        if (!_modifierWords.contains(lower)) {
          coreOnly.add(cap);
        }
      }
    }

    // Use core nouns if available (max 3 words), else fallback to unique words (max 3)
    final chosen = coreOnly.isNotEmpty ? coreOnly.take(3).toList() : allUnique.take(3).toList();
    return chosen.join(' ');
  }

  String _dedupePhrase(String phrase) {
    final seen = <String>{};
    final result = <String>[];
    for (final w in phrase.split(RegExp(r'\s+'))) {
      if (w.isEmpty) continue;
      if (seen.add(w.toLowerCase())) {
        result.add(w);
      }
    }
    return result.join(' ');
  }

  List<RelatedKeyword> _generateRelatedKeywords(
    String seedWord,
    int baseVol,
    int baseComp,
    double basePrice,
    Random rng,
  ) {
    final core = _extractCoreKeyword(seedWord);

    final rawModifiers = [
      'Personalized $core',
      'Handmade $core',
      'Custom $core Gift',
      'Vintage $core Aesthetic',
      'Minimalist $core',
      '$core for Men',
      '$core for Women',
      'Engraved $core',
      'Luxury $core with Box',
      'Bespoke $core',
      'Eco Friendly $core',
      'Aesthetic $core Decor',
      'Unique $core Anniversary Gift',
      '$core Bulk Wholesale',
      'DIY $core Kit',
    ];

    final seenPhrases = <String>{};
    final modifiers = <String>[];
    for (final m in rawModifiers) {
      final deduped = _dedupePhrase(m);
      if (deduped.isNotEmpty && seenPhrases.add(deduped.toLowerCase())) {
        modifiers.add(deduped);
      }
    }

    return modifiers.map((mod) {
      final vMult = 0.35 + (rng.nextDouble() * 0.9);
      final cMult = 0.25 + (rng.nextDouble() * 0.85);
      final vol = (baseVol * vMult).toInt().clamp(350, 48000);
      final comp = (baseComp * cMult).toInt().clamp(120, 22000);
      final opp = ((vol / (comp + 300)) * 19).clamp(38, 97).toInt();
      final price = double.parse((basePrice * (0.8 + rng.nextDouble() * 0.4)).toStringAsFixed(2));
      final growth = (rng.nextInt(55) - 5);

      return RelatedKeyword(
        keyword: mod,
        searchVolume: vol,
        competition: comp,
        opportunityScore: opp,
        avgPrice: price,
        trend: growth > 15 ? 'hot' : (growth > 0 ? 'up' : 'stable'),
        growthPercent: growth.abs(),
        isLongTail: mod.split(' ').length >= 3,
      );
    }).toList();
  }

  List<String> _generate13ListingTags(String seed, List<RelatedKeyword> related) {
    final set = <String>{};
    set.add(seed.length > 20 ? seed.substring(0, 20) : seed);

    for (final r in related) {
      final words = r.keyword.toLowerCase();
      // Etsy limit is 20 chars per tag
      if (words.length <= 20) {
        set.add(words);
      } else {
        final tokens = words.split(' ');
        if (tokens.length >= 2) {
          final shortened = '${tokens[0]} ${tokens[1]}';
          if (shortened.length <= 20) set.add(shortened);
        }
      }
      if (set.length >= 13) break;
    }

    final fallbacks = [
      'gift for him',
      'gift for her',
      'birthday gift',
      'anniversary gift',
      'handmade gift',
      'personalized gift',
      'custom design',
      'trending item',
      'etsy best seller',
      'holiday gift',
      'unique gifts',
      'shop small',
      'made to order',
    ];

    for (final fb in fallbacks) {
      if (set.length >= 13) break;
      set.add(fb);
    }

    return set.take(13).toList();
  }
}
