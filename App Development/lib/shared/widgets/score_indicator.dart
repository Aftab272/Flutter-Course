import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ScoreIndicator extends StatelessWidget {
  final int score; // 1 - 100
  final double size;
  final bool showLabel;

  const ScoreIndicator({
    super.key,
    required this.score,
    this.size = 46,
    this.showLabel = true,
  });

  Color _getScoreColor(BuildContext context) {
    final theme = Theme.of(context);
    if (score >= 85) return theme.colorScheme.secondary;
    if (score >= 70) return theme.colorScheme.primary;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor(context);
    final theme = Theme.of(context);
    final indicator = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100.0,
            strokeWidth: size > 40 ? 4 : 3,
            backgroundColor: theme.dividerColor.withOpacity(0.4),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            '$score',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: size * 0.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (!showLabel) return indicator;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'OPPORTUNITY',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              score >= 85 ? 'High Demand' : (score >= 70 ? 'Promising' : 'Moderate'),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

