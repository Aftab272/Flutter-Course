import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {
  /// Open external URL safely in new browser tab / external app
  static Future<bool> openUrl(String url) async {
    if (url.trim().isEmpty) return false;
    String targetUrl = url.trim();
    if (!targetUrl.startsWith('http://') && !targetUrl.startsWith('https://')) {
      targetUrl = 'https://$targetUrl';
    }
    try {
      final uri = Uri.parse(targetUrl);
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('[UrlLauncherHelper] Failed to open $url: $e');
      return false;
    }
  }

  /// Get direct platform URL or platform search
  static String getMarketplaceUrl(String marketplace, {String? query}) {
    final m = marketplace.toLowerCase();
    if (m.contains('etsy')) {
      return query != null && query.isNotEmpty
          ? 'https://www.etsy.com/search?q=${Uri.encodeComponent(query)}'
          : 'https://www.etsy.com';
    } else if (m.contains('amazon')) {
      return query != null && query.isNotEmpty
          ? 'https://www.amazon.com/s?k=${Uri.encodeComponent(query)}'
          : 'https://www.amazon.com';
    } else if (m.contains('ebay')) {
      return query != null && query.isNotEmpty
          ? 'https://www.ebay.com/sch/i.html?_nkw=${Uri.encodeComponent(query)}'
          : 'https://www.ebay.com';
    } else if (m.contains('shopify')) {
      return query != null && query.isNotEmpty
          ? 'https://www.google.com/search?q=site:myshopify.com+${Uri.encodeComponent(query)}'
          : 'https://www.shopify.com';
    }
    return 'https://www.google.com';
  }
}

