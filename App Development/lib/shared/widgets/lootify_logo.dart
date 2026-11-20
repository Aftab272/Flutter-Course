import 'package:flutter/material.dart';

/// Professional LootifyScrap Brand Logo Widget
/// Renders the authentic circular LootifyScrap emblem alongside crisp,
/// theme-adaptive typography (full black in light mode, crisp white in dark mode,
/// with signature radiant orange 'Scrap' accent, and absolutely no clutter or subtitle text).
class LootifyLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final bool showText;
  final String text;
  final MainAxisAlignment mainAxisAlignment;
  final bool preferOfficialArtwork;

  const LootifyLogo({
    super.key,
    this.iconSize = 40,
    this.fontSize = 22,
    this.showText = true,
    this.text = 'LootifyScrap',
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.preferOfficialArtwork = true,
  });

  @override
  Widget build(BuildContext context) {
    // If only the brand icon is requested (e.g. mobile bar, badges)
    if (!showText) {
      return Image.asset(
        'assets/logos/lootify_official.png',
        height: iconSize,
        width: iconSize,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/logos/lootify_logo.png',
          height: iconSize,
          width: iconSize,
          fit: BoxFit.contain,
        ),
      );
    }

    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryTextColor = isLight ? const Color(0xFF000000) : Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Official Circular LootifyScrap LS Emblem
        Image.asset(
          'assets/logos/lootify_official.png',
          height: iconSize,
          width: iconSize,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/logos/lootify_logo.png',
            height: iconSize,
            width: iconSize,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 10),
        // Clean high-contrast typography (No subtitle text)
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Lootify',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.6,
                  color: primaryTextColor,
                  shadows: isLight
                      ? null
                      : [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 1),
                          ),
                        ],
                ),
              ),
              TextSpan(
                text: 'Scrap',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.6,
                  color: const Color(0xFFF97316), // Radiant Orange
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
