import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/product_model.dart';

class CsvExportHelper {
  /// Generates a standardized, formula-safe CSV string from product records
  static String generateProductsCsv(List<ProductModel> products) {
    final buffer = StringBuffer();

    // UTF-8 BOM for Microsoft Excel compatibility
    buffer.write('\uFEFF');

    // Headers
    final headers = [
      'Product ID',
      'Original Product Name',
      'Original Product Description',
      'Price',
      'Currency',
      'Original Product Image URL',
      'Product Type',
      'Product Category',
      'Platform Name',
      'Seller / Store Name',
      'Original Product URL',
      'Rating',
      'Review Count',
      'Listing Status',
      'Opportunity Score',
      'Data Source',
      'Data Collection Timestamp',
    ];

    buffer.writeln(headers.map(_escapeCsvField).join(','));

    for (final p in products) {
      final isDigital = p.tags.any((t) =>
              t.toLowerCase().contains('digital') ||
              t.toLowerCase().contains('printable') ||
              t.toLowerCase().contains('download') ||
              t.toLowerCase().contains('svg') ||
              t.toLowerCase().contains('template') ||
              t.toLowerCase().contains('pdf')) ||
          p.category.toLowerCase().contains('digital') ||
          p.title.toLowerCase().contains('digital') ||
          p.title.toLowerCase().contains('planner') ||
          p.title.toLowerCase().contains('printable');

      final productType = isDigital ? 'Digital' : 'Physical';

      final row = [
        p.id,
        p.title,
        p.description,
        p.price.toStringAsFixed(2),
        p.currency,
        p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
        productType,
        p.category,
        p.marketplace,
        p.shopName,
        (p.originalUrl != null && p.originalUrl!.isNotEmpty)
            ? p.originalUrl!
            : 'https://${p.marketplace.toLowerCase()}.com',
        p.rating.toStringAsFixed(1),
        p.reviewCount.toString(),
        p.stockStatus,
        p.opportunityScore.toString(),
        '${p.marketplace} Official Marketplace Catalog',
        p.createdAt.toIso8601String(),
      ];

      buffer.writeln(row.map(_escapeCsvField).join(','));
    }

    return buffer.toString();
  }

  /// Generates a standardized CSV string from keyword intelligence records
  static String generateKeywordsCsv(dynamic intel) {
    final buffer = StringBuffer();
    buffer.write('\uFEFF'); // UTF-8 BOM

    final headers = [
      'Keyword Phrase',
      'Marketplace',
      'Monthly Search Volume',
      'Active Competition Listings',
      'Opportunity Score (1-100)',
      'Difficulty Score',
      'Difficulty Label',
      'Average Price (USD)',
      'Estimated Monthly Sales',
      'Estimated Monthly Revenue (USD)',
      'CTR (%)',
      'Trend Status',
      'Type',
    ];

    buffer.writeln(headers.map(_escapeCsvField).join(','));

    // Primary Keyword
    buffer.writeln([
      intel.keyword,
      intel.marketplace,
      intel.searchVolume,
      intel.competitionListings,
      intel.opportunityScore,
      intel.difficultyScore,
      intel.difficultyLabel,
      intel.avgPrice,
      intel.estMonthlySales,
      intel.estMonthlyRevenue,
      '${intel.ctr}%',
      intel.trend,
      'Primary Focus Keyword',
    ].map(_escapeCsvField).join(','));

    // Related Long-Tail Keywords
    for (final r in intel.relatedKeywords) {
      buffer.writeln([
        r.keyword,
        intel.marketplace,
        r.searchVolume,
        r.competition,
        r.opportunityScore,
        100 - r.opportunityScore,
        r.opportunityScore > 75 ? 'Low Difficulty' : (r.opportunityScore > 50 ? 'Medium' : 'High'),
        r.avgPrice,
        (r.searchVolume * 0.05).toInt(),
        (r.searchVolume * 0.05 * r.avgPrice).toStringAsFixed(2),
        '4.8%',
        r.trend,
        r.isLongTail ? 'Long-Tail Variation' : 'Related Query',
      ].map(_escapeCsvField).join(','));
    }

    return buffer.toString();
  }

  /// Escapes CSV field against formula injection and quotes commas/newlines
  static String _escapeCsvField(dynamic value) {
    if (value == null) return '""';
    String str = value.toString();

    // CSV Formula Injection mitigation: prepend apostrophe if starting with formula triggers
    if (str.startsWith('=') || str.startsWith('+') || str.startsWith('-') || str.startsWith('@')) {
      str = "'$str";
    }

    // Double quotes escape
    if (str.contains('"') || str.contains(',') || str.contains('\n') || str.contains('\r')) {
      str = '"${str.replaceAll('"', '""')}"';
    }

    return str;
  }

  /// Triggers file download in browser or opens download URI
  static Future<bool> downloadCsv({
    required String filename,
    required String csvContent,
  }) async {
    try {
      final bytes = utf8.encode(csvContent);
      final base64Data = base64Encode(bytes);
      final uriString = 'data:text/csv;charset=utf-8;base64,$base64Data';
      final uri = Uri.parse(uriString);

      return await launchUrl(uri);
    } catch (e) {
      debugPrint('CSV download error: $e');
      return false;
    }
  }
}
