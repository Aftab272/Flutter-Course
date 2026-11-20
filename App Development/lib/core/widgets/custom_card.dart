import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool hasGlow;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 12,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final effectiveBg = backgroundColor ?? theme.cardTheme.color ?? AppColors.cardBackground;
    final effectiveBorder = borderColor ?? (isLight ? Colors.black.withOpacity(0.22) : theme.dividerColor);

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorder,
          width: 1.1,
        ),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ]
            : (isLight
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          splashColor: AppColors.primaryGreen.withOpacity(0.08),
          highlightColor: AppColors.cardHover,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    return card;
  }
}

