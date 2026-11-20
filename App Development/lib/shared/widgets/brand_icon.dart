import 'package:flutter/material.dart';

class BrandIcon extends StatelessWidget {
  final String brand; // 'google', 'etsy', 'amazon', 'ebay', 'shopify'
  final double size;
  final double? width;
  final double? height;
  final BoxFit fit;

  const BrandIcon({
    super.key,
    required this.brand,
    this.size = 20,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  String? _getAssetPath() {
    switch (brand.toLowerCase().trim()) {
      case 'google':
        return 'assets/logos/google.png';
      case 'shopify':
        return 'assets/logos/shopify.png';
      case 'etsy':
        return 'assets/logos/etsy.png';
      case 'ebay':
        return 'assets/logos/ebay.png';
      case 'amazon':
        return 'assets/logos/amazon.jpg';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _getAssetPath();
    final effectiveWidth = width ?? size;
    final effectiveHeight = height ?? size;

    if (assetPath == null) {
      return Icon(Icons.storefront_rounded, size: size);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.asset(
        assetPath,
        width: effectiveWidth,
        height: effectiveHeight,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.storefront_rounded, size: size);
        },
      ),
    );
  }
}

