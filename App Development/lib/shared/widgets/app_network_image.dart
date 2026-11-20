import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final IconData fallbackIcon;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8,
    this.fallbackIcon = Icons.inventory_2_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: AppColors.secondaryBackground,
        child: imageUrl.isEmpty
            ? _buildFallback()
            : Image.network(
                imageUrl,
                width: width,
                height: height,
                fit: fit,
                cacheWidth: (width != null && width!.isFinite && width! > 0)
                    ? (width! * 2).clamp(120, 600).toInt()
                    : 480,
                gaplessPlayback: true,
                filterQuality: FilterQuality.low,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallback();
                },
              ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.secondaryBackground,
      child: Center(
        child: Icon(
          fallbackIcon,
          size: (height != null && height! < 50) ? 20 : 36,
          color: AppColors.secondaryText.withOpacity(0.5),
        ),
      ),
    );
  }
}

