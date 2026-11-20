import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../services/research_service.dart';
import '../../services/theme_service.dart';
import '../../services/product_service.dart';
import '../../services/shop_service.dart';
import '../../services/supabase_service.dart';
import '../../shared/widgets/brand_icon.dart';
import '../../shared/widgets/lootify_logo.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ResearchService _researchService = ResearchService();
  final ThemeService _themeService = ThemeService();
  final ProductService _productService = ProductService();
  final ShopService _shopService = ShopService();

  bool _autoSaveScrapes = true;
  bool _realTimeAlerts = true;
  String _defaultMarketplace = 'Etsy';
  String _currency = 'USD (\$)';

  @override
  void initState() {
    super.initState();
    final user = _researchService.user;
    _currency = user.currency.isNotEmpty ? user.currency : 'USD (\$)';
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  void _saveSettings() {
    final user = _researchService.user;
    _researchService.updateUser(
      user.copyWith(
        currency: _currency,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Workspace settings saved successfully!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color ?? AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error),
            SizedBox(width: 10),
            Text('Log Out of Workspace', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out of ${_researchService.user.email.isNotEmpty ? _researchService.user.email : 'your account'}?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              SupabaseService().signOut();
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final totalWatchlist = _productService.savedProducts.length + _shopService.savedShops.length;
    final userEmail = _researchService.user.email.isNotEmpty ? _researchService.user.email : 'Signed-in account';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Workspace Settings'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32.0 : 16.0,
          vertical: 20.0,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title
              Text(
                'Application Configuration',
                style: TextStyle(
                  color: _themeService.isLight ? const Color(0xFF000000) : AppColors.primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage color themes, typography, cloud backend, and research preferences.',
                style: TextStyle(
                  color: _themeService.isLight ? const Color(0xFF475569) : AppColors.secondaryText,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 1: Exact UI from user screenshot (media_1794642872151_4cde4ecc.png)
              _buildWorkspaceQuickLinksCard(totalWatchlist, userEmail),
              const SizedBox(height: 24),

              // SECTION 2: Color Theme & Typography
              _buildThemeAndTypographyCard(),
              const SizedBox(height: 24),

              // SECTION 3: Research & Scraper Preferences
              _buildPreferencesCard(),
              const SizedBox(height: 24),

              // SECTION 4: About & Licensing Card
              _buildAboutCard(),
              const SizedBox(height: 24),

              // Save Button
              CustomButton(
                text: 'Save Workspace Settings',
                icon: Icons.check_rounded,
                type: ButtonType.primary,
                isFullWidth: true,
                onPressed: _saveSettings,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Clean workspace quick actions card (Supabase Cloud & Security removed per user request)
  Widget _buildWorkspaceQuickLinksCard(int totalWatchlist, String userEmail) {
    final isLight = _themeService.isLight;
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // 1. Saved Research Bookmarks
          _buildQuickActionTile(
            icon: Icons.bookmark_outline_rounded,
            iconColor: const Color(0xFF2563EB),
            iconBg: const Color(0xFF2563EB).withOpacity(0.12),
            title: 'Saved Research Bookmarks',
            subtitle: '$totalWatchlist items in watchlist',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Watchlist contains $totalWatchlist saved products & shops. Open Saved Research tab to view.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          Divider(height: 1, color: isLight ? Colors.black.withOpacity(0.12) : AppColors.borderColor),

          // 2. Log Out of Workspace
          _buildQuickActionTile(
            icon: Icons.logout_rounded,
            iconColor: const Color(0xFFDC2626),
            iconBg: const Color(0xFFDC2626).withOpacity(0.12),
            title: 'Log Out of Workspace',
            titleColor: const Color(0xFFDC2626),
            subtitle: 'Sign out of $userEmail',
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    Color? titleColor,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isLight = _themeService.isLight;
    final effectiveTitle = titleColor ?? (isLight ? const Color(0xFF000000) : AppColors.primaryText);
    final effectiveSub = isLight ? const Color(0xFF334155) : AppColors.secondaryText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: effectiveTitle,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: effectiveSub,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: effectiveSub, size: 20),
          ],
        ),
      ),
    );
  }

  /// Theme and Typography configuration card
  Widget _buildThemeAndTypographyCard() {
    final currentPreset = _themeService.currentPreset;
    final currentFont = _themeService.fontFamily;
    final currentFontSize = _themeService.fontSize;

    return CustomCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentLime.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.palette_outlined, color: AppColors.accentLime, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Color Theme & Typography Appearance',
                      style: TextStyle(
                        color: _themeService.isLight ? const Color(0xFF000000) : AppColors.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Choose from 3 primary themes and configure typography settings',
                      style: TextStyle(
                        color: _themeService.isLight ? const Color(0xFF475569) : AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Theme Selection
          Text(
            'Select Color Theme (White Color Theme & Dark Blue Theme)',
            style: TextStyle(
              color: _themeService.isLight ? const Color(0xFF000000) : AppColors.primaryText,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ThemePreset.values.map((preset) {
              final isSelected = currentPreset == preset;
              final palette = ThemeService.presets[preset];
              final label = palette?.shortName ?? preset.name;

              Color accentDot;
              Color bgDot;
              switch (preset) {
                case ThemePreset.cleanWhite:
                  accentDot = const Color(0xFF2563EB); // Royal Blue
                  bgDot = const Color(0xFFFFFFFF);     // Pure White
                  break;
                case ThemePreset.darkBlue:
                  accentDot = const Color(0xFFF97316); // Radiant Orange
                  bgDot = const Color(0xFF0A1128);     // Deep Navy Blue
                  break;
                case ThemePreset.emeraldLime:
                  accentDot = const Color(0xFFD4E79E);
                  bgDot = const Color(0xFF0F1412);
                  break;
                case ThemePreset.cyberCyan:
                  accentDot = const Color(0xFF00E5FF);
                  bgDot = const Color(0xFF0B132B);
                  break;
                case ThemePreset.violetObsidian:
                  accentDot = const Color(0xFFC084FC);
                  bgDot = const Color(0xFF090611);
                  break;
                case ThemePreset.adsicClean:
                  accentDot = const Color(0xFF6366F1);
                  bgDot = const Color(0xFF0A0F1D);
                  break;
                case ThemePreset.etsyCleanLight:
                  accentDot = const Color(0xFFF1641E);
                  bgDot = const Color(0xFFFFFFFF);
                  break;
              }

              return InkWell(
                onTap: () => _themeService.setTheme(preset),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (_themeService.isLight
                            ? const Color(0xFF2563EB).withOpacity(0.12)
                            : AppColors.primaryGreen.withOpacity(0.18))
                        : (_themeService.isLight ? const Color(0xFFF8FAFC) : AppColors.secondaryBackground),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? (_themeService.isLight ? const Color(0xFF2563EB) : AppColors.accentLime)
                          : (_themeService.isLight ? const Color(0xFFE2E8F0) : AppColors.borderColor),
                      width: isSelected ? 1.6 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: bgDot,
                          shape: BoxShape.circle,
                          border: Border.all(color: accentDot, width: 2.5),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? (_themeService.isLight ? const Color(0xFF2563EB) : AppColors.accentLime)
                              : (_themeService.isLight ? const Color(0xFF000000) : AppColors.primaryText),
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: _themeService.isLight ? const Color(0xFF2563EB) : AppColors.accentLime,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const Divider(height: 32, color: AppColors.borderColor),

          // Typography: Font Family (Full-width dropdown strictly inside box)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Text Font Family',
                style: TextStyle(
                  color: _themeService.isLight ? const Color(0xFF000000) : AppColors.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'App-wide typography typeface rendering',
                style: TextStyle(
                  color: _themeService.isLight ? const Color(0xFF334155) : AppColors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _themeService.isLight ? Colors.white : AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _themeService.isLight ? Colors.black.withOpacity(0.22) : AppColors.borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currentFont,
                    isExpanded: true,
                    dropdownColor: _themeService.isLight ? Colors.white : AppColors.secondaryBackground,
                    style: TextStyle(
                      color: _themeService.isLight ? const Color(0xFF000000) : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'Roboto',
                        child: Text(
                          'Roboto (Clean Pro)',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: _themeService.isLight ? const Color(0xFF000000) : Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'sans-serif',
                        child: Text(
                          'Modern Sans (Humanist)',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: _themeService.isLight ? const Color(0xFF000000) : Colors.white),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) _themeService.setFontFamily(val);
                    },
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 26, color: _themeService.isLight ? const Color(0xFFE2E8F0) : AppColors.borderColor),

          // Typography: Font Scale (Full-width dropdown strictly inside box)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Display Text Size Scale',
                style: TextStyle(
                  color: _themeService.isLight ? const Color(0xFF000000) : AppColors.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Adjust overall interface text density',
                style: TextStyle(
                  color: _themeService.isLight ? const Color(0xFF334155) : AppColors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _themeService.isLight ? Colors.white : AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _themeService.isLight ? Colors.black.withOpacity(0.22) : AppColors.borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AppFontSize>(
                    value: currentFontSize,
                    isExpanded: true,
                    dropdownColor: _themeService.isLight ? Colors.white : AppColors.secondaryBackground,
                    style: TextStyle(
                      color: _themeService.isLight ? const Color(0xFF000000) : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: AppFontSize.compact,
                        child: Text(
                          'Compact (92%)',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: _themeService.isLight ? const Color(0xFF000000) : Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: AppFontSize.normal,
                        child: Text(
                          'Normal (100%)',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: _themeService.isLight ? const Color(0xFF000000) : Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: AppFontSize.comfortable,
                        child: Text(
                          'Comfortable (110%)',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: _themeService.isLight ? const Color(0xFF000000) : Colors.white),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) _themeService.setFontSize(val);
                    },
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 26, color: _themeService.isLight ? const Color(0xFFE2E8F0) : AppColors.borderColor),

          // Layout Style Setting (Full-width dropdown strictly inside box)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Display Layout (Etsy / SaaS)',
                style: TextStyle(
                  color: _themeService.isLight ? const Color(0xFF000000) : AppColors.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Choose between high-density SaaS or Etsy-style cards',
                style: TextStyle(
                  color: _themeService.isLight ? const Color(0xFF334155) : AppColors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _themeService.isLight ? Colors.white : AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _themeService.isLight ? Colors.black.withOpacity(0.22) : AppColors.borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ProductLayoutMode>(
                    value: _themeService.productLayoutMode,
                    isExpanded: true,
                    dropdownColor: _themeService.isLight ? Colors.white : AppColors.secondaryBackground,
                    style: TextStyle(
                      color: _themeService.isLight ? const Color(0xFF000000) : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: ProductLayoutMode.standardSaaS,
                        child: Text(
                          'SaaS Matrix Grid',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: _themeService.isLight ? const Color(0xFF000000) : Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ProductLayoutMode.etsyInspired,
                        child: Text(
                          'Etsy-Inspired Layout',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: _themeService.isLight ? const Color(0xFF000000) : Colors.white),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _themeService.setProductLayoutMode(val));
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getOfficialBrandColor(String marketplace) {
    switch (marketplace.toLowerCase()) {
      case 'etsy':
        return const Color(0xFFF1641E); // Official Etsy Orange
      case 'amazon':
        return const Color(0xFFFF9900); // Official Amazon Amber
      case 'ebay':
        return const Color(0xFF0064D2); // Official eBay Blue
      case 'shopify':
        return const Color(0xFF5E8E3E); // Official Shopify Green
      default:
        return const Color(0xFF000000);
    }
  }

  Widget _buildPreferencesCard() {
    final isLight = _themeService.isLight;
    final titleColor = isLight ? const Color(0xFF000000) : AppColors.primaryText;
    final subColor = isLight ? const Color(0xFF334155) : AppColors.secondaryText;
    final borderColor = isLight ? Colors.black.withOpacity(0.22) : AppColors.borderColor;

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Research & Scraper Preferences',
            style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),

          // Default marketplace (Official brand icon & color, strictly inside box)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Default Market Platform', style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('Pre-selected platform in scraper tools', style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _defaultMarketplace,
                    isExpanded: true,
                    dropdownColor: isLight ? Colors.white : AppColors.secondaryBackground,
                    items: ['Etsy', 'Amazon', 'eBay', 'Shopify'].map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Row(
                          children: [
                            BrandIcon(brand: m.toLowerCase(), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              m,
                              style: TextStyle(
                                color: _getOfficialBrandColor(m),
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _defaultMarketplace = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          Divider(color: isLight ? const Color(0xFFE2E8F0) : AppColors.borderColor, height: 26),

          // Currency (Solid Black text, strictly inside box)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Display Currency', style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('Unit pricing and revenue metric formatting', style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currency,
                    isExpanded: true,
                    dropdownColor: isLight ? Colors.white : AppColors.secondaryBackground,
                    style: TextStyle(
                      color: isLight ? const Color(0xFF000000) : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                    items: ['USD (\$)', 'EUR (€)', 'GBP (£)', 'CAD (\$)'].map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(
                          c,
                          style: TextStyle(
                            color: isLight ? const Color(0xFF000000) : Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _currency = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          Divider(color: isLight ? const Color(0xFFE2E8F0) : AppColors.borderColor, height: 26),

          // Auto-save
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Auto-Save Scraped Stores', style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.w800)),
            subtitle: Text('Automatically bookmark newly scraped storefronts into your database', style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w600)),
            value: _autoSaveScrapes,
            activeColor: const Color(0xFF2563EB),
            onChanged: (v) => setState(() => _autoSaveScrapes = v),
          ),
          Divider(color: isLight ? const Color(0xFFE2E8F0) : AppColors.borderColor, height: 24),

          // Alerts
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Real-Time Price Shift Notifications', style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.w800)),
            subtitle: Text('Alert when competitors change prices by > 5%', style: TextStyle(color: subColor, fontSize: 12, fontWeight: FontWeight.w600)),
            value: _realTimeAlerts,
            activeColor: const Color(0xFF2563EB),
            onChanged: (v) => setState(() => _realTimeAlerts = v),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return CustomCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LootifyLogo(
            iconSize: 36,
            fontSize: 20,
            text: 'Lootify Scrap',
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          const SizedBox(height: 6),
          Text(
            '${AppStrings.appName} • ${AppStrings.appVersion}',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Text(
            'Lootify Scrap is a modular, high-performance e-commerce research & storefront scraper suite designed with Flutter, Material 3, and a dedicated Supabase cloud backend.',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.help_outline_rounded, size: 16),
                label: const Text('SaaS Docs'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening documentation portal...')),
                  );
                },
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                icon: const Icon(Icons.privacy_tip_outlined, size: 16),
                label: const Text('Privacy & Security'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy protocol compliant.')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
