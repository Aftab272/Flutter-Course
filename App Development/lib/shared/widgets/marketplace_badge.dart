import 'package:flutter/material.dart';
import '../../core/utils/url_launcher_helper.dart';
import 'brand_icon.dart';

class MarketplaceBadge extends StatelessWidget {
  final String marketplace;
  final bool isCompact;
  final String? targetUrl;
  final String? searchQuery;
  final bool isClickable;

  const MarketplaceBadge({
    super.key,
    required this.marketplace,
    this.isCompact = false,
    this.targetUrl,
    this.searchQuery,
    this.isClickable = true,
  });

  void _handleClick(BuildContext context) {
    if (!isClickable) return;
    final url = targetUrl ?? UrlLauncherHelper.getMarketplaceUrl(marketplace, query: searchQuery);
    UrlLauncherHelper.openUrl(url);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $marketplace platform ($url)...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = marketplace.toLowerCase();

    final badgeWidget = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 7 : 9,
        vertical: isCompact ? 3 : 4.5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(isCompact ? 5 : 6),
        border: Border.all(color: const Color(0xFF1D4ED8), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BrandIcon(brand: brand, size: isCompact ? 12 : 15),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              isCompact ? marketplace.toUpperCase() : marketplace,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: isCompact ? 9.5 : 11,
                fontWeight: FontWeight.w700,
                letterSpacing: isCompact ? 0.4 : 0,
              ),
            ),
          ),
          if (isClickable) ...[
            const SizedBox(width: 3),
            const Icon(
              Icons.open_in_new_rounded,
              size: 10,
              color: Colors.white,
            ),
          ],
        ],
      ),
    );

    if (!isClickable) return badgeWidget;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _handleClick(context),
        child: Tooltip(
          message: 'Direct link: Open $marketplace in browser',
          child: badgeWidget,
        ),
      ),
    );
  }
}
