import 'package:flutter/material.dart';

enum ThemePreset {
  cleanWhite,       // 1. White Color Theme: Pure white background with deep dark high-contrast typography
  darkBlue,         // 2. Dark Blue Color Theme: Deep navy/dark blue background with cobalt blue & radiant orange accents
  emeraldLime,      // 3. Dark SaaS: Emerald Green & Lime
  cyberCyan,        // 4. Dark Cyber: Neon Cyan & Aqua
  violetObsidian,   // 5. Dark Luxury: Obsidian Violet & Amethyst
  adsicClean,       // 6. Adsic-Inspired: Slate & Electric Indigo
  etsyCleanLight,   // 7. Etsy-Inspired: Clean White Marketplace
}

enum ProductLayoutMode {
  standardSaaS,     // Clean compact SaaS matrix grid
  etsyInspired,     // Warm, card-centric e-commerce grid inspired by Etsy
}

enum AppFontSize {
  compact,  // 0.9x scale
  normal,   // 1.0x scale
  comfortable, // 1.1x scale
}

class ThemePalette {
  final String id;
  final String name;
  final String shortName;
  final String description;
  final Color primary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color border;
  final Color primaryText;
  final Color secondaryText;
  final bool isLight;

  const ThemePalette({
    required this.id,
    required this.name,
    required this.shortName,
    required this.description,
    required this.primary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.border,
    this.primaryText = const Color(0xFFFFFFFF),
    this.secondaryText = const Color(0xFFA7A7A7),
    this.isLight = false,
  });
}

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  /// Themes including 2 Primary Themes (White Color & Dark Blue Color) + Compatibility Palettes
  static const Map<ThemePreset, ThemePalette> presets = {
    // 1. Clean White Theme (Pure white background with high-contrast full black text)
    ThemePreset.cleanWhite: ThemePalette(
      id: 'clean_white',
      name: 'Clean White Theme',
      shortName: 'White Theme',
      description: 'Pure white background with crystal-clear full black typography',
      primary: Color(0xFF2563EB),
      accent: Color(0xFFF97316),
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      border: Color(0xFFCBD5E1),
      primaryText: Color(0xFF000000),
      secondaryText: Color(0xFF000000),
      isLight: true,
    ),

    // 2. Dark Blue Theme (Deep navy blue background with cobalt blue & radiant orange accents)
    ThemePreset.darkBlue: ThemePalette(
      id: 'dark_blue',
      name: 'Dark Blue Theme',
      shortName: 'Dark Blue',
      description: 'Deep navy blue background with cobalt blue and radiant orange accents',
      primary: Color(0xFF3B82F6),
      accent: Color(0xFFF97316),
      background: Color(0xFF0A1128),
      surface: Color(0xFF111D42),
      border: Color(0xFF1E2D5A),
      primaryText: Color(0xFFFFFFFF),
      secondaryText: Color(0xFF94A3B8),
      isLight: false,
    ),

    // 3. Emerald & Lime (Dark SaaS)
    ThemePreset.emeraldLime: ThemePalette(
      id: 'emerald_lime',
      name: 'Emerald & Lime (Dark)',
      shortName: 'Emerald Dark',
      description: 'Default Premium SaaS Black & Green Theme',
      primary: Color(0xFF00A878),
      accent: Color(0xFFB7F34A),
      background: Color(0xFF000000),
      surface: Color(0xFF171717),
      border: Color(0xFF303030),
      primaryText: Color(0xFFFFFFFF),
      secondaryText: Color(0xFFA7A7A7),
      isLight: false,
    ),

    // 2. Cyber Cyan & Aqua (Dark Neon)
    ThemePreset.cyberCyan: ThemePalette(
      id: 'cyber_cyan',
      name: 'Cyber Cyan & Aqua (Dark)',
      shortName: 'Cyber Cyan',
      description: 'Futuristic High-Contrast Neon Tech Palette',
      primary: Color(0xFF00D2FF),
      accent: Color(0xFF00F5D4),
      background: Color(0xFF06090E),
      surface: Color(0xFF0E1420),
      border: Color(0xFF1F293D),
      primaryText: Color(0xFFFFFFFF),
      secondaryText: Color(0xFF94A3B8),
      isLight: false,
    ),

    // 3. Violet Obsidian (Dark Luxury)
    ThemePreset.violetObsidian: ThemePalette(
      id: 'violet_obsidian',
      name: 'Violet & Obsidian (Dark)',
      shortName: 'Violet Dark',
      description: 'Deep Obsidian & Neon Amethyst Luxury Dark Theme',
      primary: Color(0xFF8B5CF6),
      accent: Color(0xFFC084FC),
      background: Color(0xFF090611),
      surface: Color(0xFF130D24),
      border: Color(0xFF281C46),
      primaryText: Color(0xFFFFFFFF),
      secondaryText: Color(0xFFA5B4FC),
      isLight: false,
    ),

    // 4. Adsic-Inspired Modern Slate & Indigo (Section 20)
    ThemePreset.adsicClean: ThemePalette(
      id: 'adsic_clean',
      name: 'Adsic Modern Slate & Indigo',
      shortName: 'Adsic Slate',
      description: 'Clean, professional app layout inspired by Adsic',
      primary: Color(0xFF6366F1),
      accent: Color(0xFFA855F7),
      background: Color(0xFF0A0F1D),
      surface: Color(0xFF141E33),
      border: Color(0xFF233354),
      primaryText: Color(0xFFFFFFFF),
      secondaryText: Color(0xFF94A3B8),
      isLight: false,
    ),

    // 5. Etsy-Inspired Clean White Marketplace (Screenshot 2 Sample)
    ThemePreset.etsyCleanLight: ThemePalette(
      id: 'etsy_clean_light',
      name: 'Etsy Clean White Marketplace',
      shortName: 'Etsy White',
      description: 'Pure white background with crisp high-contrast dark typography inspired by Etsy',
      primary: Color(0xFF000000),
      accent: Color(0xFFF1641E), // Authentic warm Etsy accent
      background: Color(0xFFFFFFFF), // 100% Pure white backdrop
      surface: Color(0xFFFFFFFF),
      border: Color(0xFFCBD5E1),
      primaryText: Color(0xFF000000), // Deep dark crisp full black text
      secondaryText: Color(0xFF000000), // High-legibility full black text
      isLight: true,
    ),
  };

  ThemePreset _currentPreset = ThemePreset.cleanWhite;
  ProductLayoutMode _productLayoutMode = ProductLayoutMode.standardSaaS;
  String _fontFamily = 'Roboto';
  AppFontSize _fontSize = AppFontSize.normal;

  ThemePreset get currentPreset => _currentPreset;
  ProductLayoutMode get productLayoutMode => _productLayoutMode;
  ThemePalette get currentPalette => presets[_currentPreset]!;
  String get fontFamily => _fontFamily;
  AppFontSize get fontSize => _fontSize;

  double get fontScaleFactor {
    switch (_fontSize) {
      case AppFontSize.compact:
        return 0.92;
      case AppFontSize.normal:
        return 1.0;
      case AppFontSize.comfortable:
        return 1.1;
    }
  }

  bool get isLight => currentPalette.isLight;
  Color get primary => currentPalette.primary;
  Color get accent => currentPalette.accent;
  Color get background => currentPalette.background;
  Color get surface => currentPalette.surface;
  Color get border => currentPalette.border;
  Color get primaryText => currentPalette.primaryText;
  Color get secondaryText => currentPalette.secondaryText;

  void setTheme(ThemePreset preset) {
    if (_currentPreset != preset) {
      _currentPreset = preset;
      notifyListeners();
    }
  }

  /// Toggle directly between the 2 primary themes: White Theme & Dark Blue Theme
  void togglePrimaryTheme() {
    if (_currentPreset == ThemePreset.cleanWhite || _currentPreset == ThemePreset.etsyCleanLight) {
      setTheme(ThemePreset.darkBlue);
    } else {
      setTheme(ThemePreset.cleanWhite);
    }
  }

  void setProductLayoutMode(ProductLayoutMode mode) {
    if (_productLayoutMode != mode) {
      _productLayoutMode = mode;
      notifyListeners();
    }
  }

  void cycleTheme() {
    const values = ThemePreset.values;
    final nextIndex = (_currentPreset.index + 1) % values.length;
    setTheme(values[nextIndex]);
  }

  void setFontFamily(String font) {
    if (_fontFamily != font) {
      _fontFamily = font;
      notifyListeners();
    }
  }

  void setFontSize(AppFontSize size) {
    if (_fontSize != size) {
      _fontSize = size;
      notifyListeners();
    }
  }

  /// Theme-adaptive primary text color: 100% full black in light mode, crisp white in dark mode.
  Color get textColor => isLight ? const Color(0xFF000000) : const Color(0xFFFFFFFF);

  /// Theme-adaptive secondary text color: 100% full black in light mode to prevent blur, high-contrast grey in dark mode.
  Color get subtextColor => isLight ? const Color(0xFF000000) : const Color(0xFFA7A7A7);
}
