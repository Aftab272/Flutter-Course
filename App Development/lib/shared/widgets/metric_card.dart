import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_card.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final String? trend;
  final bool isTrendPositive;
  final Color? valueColor;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.trend,
    this.isTrendPositive = true,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final textColor = isLight ? const Color(0xFF000000) : theme.colorScheme.onSurface;

    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isLight ? const Color(0xFF000000) : textColor.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: isLight ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? (isLight ? const Color(0xFF000000) : secondaryColor),
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null || trend != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (trend != null) ...[
                  Icon(
                    isTrendPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    size: 14,
                    color: isTrendPositive ? (isLight ? const Color(0xFF059669) : secondaryColor) : AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trend!,
                    style: TextStyle(
                      color: isTrendPositive ? (isLight ? const Color(0xFF059669) : secondaryColor) : AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (subtitle != null)
                  Expanded(
                    child: Text(
                      subtitle!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isLight ? const Color(0xFF000000) : textColor.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: isLight ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

