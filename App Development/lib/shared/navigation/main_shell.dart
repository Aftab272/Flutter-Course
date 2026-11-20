import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/shop_analyzer/shop_scraper_screen.dart';
import '../../features/product_research/product_research_screen.dart';
import '../../features/keyword_research/keyword_research_screen.dart';
import '../../features/competitor_analysis/competitor_analysis_screen.dart';
import '../../features/saved_research/saved_research_tab_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/profile/user_profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../services/research_service.dart';
import '../../services/theme_service.dart';
import '../../services/supabase_service.dart';
import '../../shared/widgets/lootify_logo.dart';
import '../../shared/widgets/app_avatar.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  late int _currentIndex;
  bool _isSidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _syncGoogleUser();
  }

  void _syncGoogleUser() {
    final supaUser = SupabaseService().currentUser;
    if (supaUser != null) {
      final meta = supaUser.userMetadata;
      String? gName = meta?['full_name'] ?? meta?['name'];
      final gEmail = supaUser.email;
      final gAvatar = (meta?['avatar_url'] as String?) ?? (meta?['picture'] as String?);
      if (gName == null || gName.isEmpty) {
        if (gEmail != null && gEmail.isNotEmpty) {
          final handle = gEmail.split('@').first.replaceAll(RegExp(r'[\._\-]'), ' ');
          gName = handle.split(' ').where((w) => w.isNotEmpty).map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
        }
      }
      if (gName != null && gName.isNotEmpty) {
        final existingUser = ResearchService().user;
        ResearchService().updateUser(existingUser.copyWith(
          name: gName,
          email: gEmail ?? existingUser.email,
          avatarUrl: gAvatar ?? existingUser.avatarUrl,
        ));
      }
    }
  }

  void switchTab(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return DashboardScreen(onNavigateTab: switchTab);
      case 1:
        return ShopScraperScreen(onNavigateTab: switchTab);
      case 2:
        return ProductResearchScreen(onNavigateTab: switchTab);
      case 3:
        return KeywordResearchScreen(onNavigateTab: switchTab);
      case 4:
        return CompetitorAnalysisScreen(onNavigateTab: switchTab);
      case 5:
        return const SavedResearchTabScreen();
      case 6:
        return const ReportsScreen();
      case 7:
        return const UserProfileScreen();
      case 8:
        return const SettingsScreen();
      default:
        return DashboardScreen(onNavigateTab: switchTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    final activePage = KeyedSubtree(
      key: ValueKey<int>(_currentIndex),
      child: _buildPage(_currentIndex),
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Row(
          children: [
            // Left Desktop Sidebar
            _buildSidebar(context),
            // Main content area
            Expanded(
              child: Column(
                children: [
                  _buildDesktopTopBar(context),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  Expanded(child: activePage),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile & Tablet Layout (Clean 4-tab Footer: Home, Shops, Reports, Profile)
    final isLight = ThemeService().isLight;
    final int mobileFooterIndex = _currentIndex == 0
        ? 0
        : (_currentIndex == 1 || _currentIndex == 2 || _currentIndex == 3)
            ? 1
            : (_currentIndex == 4 || _currentIndex == 5 || _currentIndex == 6)
                ? 2
                : 3;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildMobileAppBar(context),
      body: _buildMobileBody(isLight),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: isLight ? Colors.white : AppColors.secondaryBackground,
        selectedItemColor: isLight ? const Color(0xFF2563EB) : AppColors.accentLime,
        unselectedItemColor: isLight ? const Color(0xFF000000) : AppColors.secondaryText,
        selectedFontSize: 11.5,
        unselectedFontSize: 11,
        iconSize: 22,
        currentIndex: mobileFooterIndex,
        onTap: (footerIdx) {
          if (footerIdx == 0) {
            switchTab(0); // Home
          } else if (footerIdx == 1) {
            // Shops Hub (Shops / Products / Keywords)
            if (_currentIndex != 1 && _currentIndex != 2 && _currentIndex != 3) {
              switchTab(1);
            }
          } else if (footerIdx == 2) {
            // Reports & Analysis Hub (Reports / Competitors / Saved)
            if (_currentIndex != 4 && _currentIndex != 5 && _currentIndex != 6) {
              switchTab(6);
            }
          } else {
            switchTab(7); // Profile
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Shops',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBody(bool isLight) {
    // Shops Hub: Shops (1), Products (2), Keywords (3)
    if (_currentIndex == 1 || _currentIndex == 2 || _currentIndex == 3) {
      return Column(
        children: [
          _buildSubSectionBar(
            isLight: isLight,
            items: const [
              (index: 1, label: 'Shops', icon: Icons.storefront_rounded),
              (index: 2, label: 'Products', icon: Icons.search_rounded),
              (index: 3, label: 'Keywords', icon: Icons.travel_explore_rounded),
            ],
          ),
          Expanded(
            child: KeyedSubtree(
              key: ValueKey<int>(_currentIndex),
              child: _buildPage(_currentIndex),
            ),
          ),
        ],
      );
    }

    // Reports & Analytics Hub: Reports (6), Competitors (4), Saved (5)
    if (_currentIndex == 4 || _currentIndex == 5 || _currentIndex == 6) {
      return Column(
        children: [
          _buildSubSectionBar(
            isLight: isLight,
            items: const [
              (index: 6, label: 'Reports', icon: Icons.bar_chart_rounded),
              (index: 4, label: 'Competitors', icon: Icons.compare_arrows_rounded),
              (index: 5, label: 'Saved', icon: Icons.bookmark_rounded),
            ],
          ),
          Expanded(
            child: KeyedSubtree(
              key: ValueKey<int>(_currentIndex),
              child: _buildPage(_currentIndex),
            ),
          ),
        ],
      );
    }

    return KeyedSubtree(
      key: ValueKey<int>(_currentIndex),
      child: _buildPage(_currentIndex),
    );
  }

  Widget _buildSubSectionBar({
    required bool isLight,
    required List<({int index, String label, IconData icon})> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.secondaryBackground,
        border: Border(
          bottom: BorderSide(
            color: isLight ? Colors.black.withOpacity(0.12) : AppColors.borderColor,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isLight ? const Color(0xFFF1F5F9) : AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isLight ? Colors.black.withOpacity(0.16) : AppColors.borderColor,
          ),
        ),
        child: Row(
          children: items.map((item) {
            final isSelected = _currentIndex == item.index;
            return Expanded(
              child: InkWell(
                onTap: () => switchTab(item.index),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 15,
                        color: isSelected
                            ? Colors.white
                            : (isLight ? const Color(0xFF000000) : AppColors.secondaryText),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.label,
                            maxLines: 1,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isLight ? const Color(0xFF000000) : AppColors.primaryText),
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    final titles = [
      AppStrings.navDashboard,
      AppStrings.navShopAnalyzer,
      AppStrings.navProductResearch,
      AppStrings.navKeywordResearch,
      AppStrings.navCompetitors,
      AppStrings.navSavedResearch,
      AppStrings.navReports,
      AppStrings.navProfile,
      'Settings',
    ];

    final theme = Theme.of(context);
    return AppBar(
      title: Row(
        children: [
          Image.asset(
            'assets/logos/lootify_official.png',
            height: 28,
            width: 28,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            titles[_currentIndex],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Reports, Competitors & Saved',
          icon: Icon(
            Icons.bar_chart_rounded,
            size: 21,
            color: (_currentIndex == 4 || _currentIndex == 5 || _currentIndex == 6)
                ? const Color(0xFF2563EB)
                : null,
          ),
          onPressed: () => switchTab(6),
        ),
        IconButton(
          tooltip: ThemeService().isLight ? 'Switch to Dark Blue Theme' : 'Switch to White Theme',
          icon: Icon(
            ThemeService().isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            size: 20,
          ),
          onPressed: () => ThemeService().togglePrimaryTheme(),
        ),
        IconButton(
          tooltip: 'Marketplace Directory',
          icon: const Icon(Icons.category_outlined, size: 20),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.marketplaceSelection),
        ),
        IconButton(
          tooltip: 'Sign In / Account',
          icon: const Icon(Icons.login_rounded, size: 20),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
        ),
      ],
    );
  }

  Widget _buildDesktopTopBar(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = ThemeService().isLight;
    final topBarTextColor = isLight ? const Color(0xFF000000) : theme.colorScheme.onSurface;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isSidebarCollapsed ? Icons.menu_open_rounded : Icons.menu_rounded,
              color: topBarTextColor,
            ),
            onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
          ),
          const SizedBox(width: 12),
          Text(
            _getDesktopTitle(),
            style: TextStyle(
              color: topBarTextColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          // Quick Marketplace Shortcuts
          TextButton.icon(
            icon: Icon(Icons.grid_view_rounded, size: 16, color: isLight ? const Color(0xFF000000) : theme.colorScheme.primary),
            label: Text('Marketplaces', style: TextStyle(color: topBarTextColor, fontWeight: FontWeight.w700)),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.marketplaceSelection),
          ),
          const SizedBox(width: 8),
          // White Theme / Dark Blue Theme Toggle Button
          IconButton(
            tooltip: isLight ? 'Switch to Dark Blue Theme' : 'Switch to White Theme',
            icon: Icon(
              isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: topBarTextColor,
              size: 20,
            ),
            onPressed: () {
              ThemeService().togglePrimaryTheme();
            },
          ),
          const SizedBox(width: 8),
          // Header Sign In Action Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: topBarTextColor,
              side: BorderSide(color: isLight ? const Color(0xFF000000) : theme.colorScheme.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: Icon(Icons.login_rounded, size: 16, color: isLight ? const Color(0xFF000000) : theme.colorScheme.primary),
            label: Text('Sign In', style: TextStyle(color: topBarTextColor, fontWeight: FontWeight.w800, fontSize: 13)),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
          ),
          const SizedBox(width: 12),
          // Live Logged In User Badge with Photo / Avatar
          ListenableBuilder(
            listenable: ResearchService(),
            builder: (context, _) {
              final user = ResearchService().user;
              return InkWell(
                onTap: () => switchTab(7),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color ?? AppColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isLight ? const Color(0xFFCBD5E1) : theme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      AppAvatar(
                        avatarUrl: user.avatarUrl,
                        name: user.name,
                        radius: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.name,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: topBarTextColor),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final sidebarWidth = _isSidebarCollapsed ? 76.0 : 250.0;
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: sidebarWidth,
      color: theme.cardTheme.color ?? AppColors.secondaryBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal Lootify Brand Logo
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.centerLeft,
            child: LootifyLogo(
              iconSize: 36,
              fontSize: 20,
              showText: !_isSidebarCollapsed,
              text: 'Lootify Scrap',
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          const SizedBox(height: 12),
          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _sidebarItem(0, Icons.dashboard_outlined, Icons.dashboard, AppStrings.navDashboard),
                _sidebarItem(1, Icons.storefront_outlined, Icons.storefront, AppStrings.navShopAnalyzer),
                _sidebarItem(2, Icons.search_outlined, Icons.search, AppStrings.navProductResearch),
                _sidebarItem(3, Icons.travel_explore_rounded, Icons.travel_explore, AppStrings.navKeywordResearch),
                _sidebarItem(4, Icons.compare_arrows_outlined, Icons.compare_arrows, AppStrings.navCompetitors),
                _sidebarItem(5, Icons.bookmark_border_outlined, Icons.bookmark, AppStrings.navSavedResearch),
                _sidebarItem(6, Icons.bar_chart_outlined, Icons.bar_chart, AppStrings.navReports),
                const SizedBox(height: 16),
                if (!_isSidebarCollapsed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'PREFERENCES',
                      style: TextStyle(
                        color: ThemeService().isLight ? const Color(0xFF000000) : AppColors.secondaryText,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                _sidebarItem(7, Icons.person_outline, Icons.person, AppStrings.navProfile),
                _sidebarItem(8, Icons.settings_outlined, Icons.settings, 'Settings'),
                _actionSidebarItem(
                  icon: Icons.login_rounded,
                  label: 'Sign In / Account',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                ),
              ],
            ),
          ),
          // Backend Status indicator
          if (!_isSidebarCollapsed)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Supabase Cloud DB',
                      style: TextStyle(
                        fontSize: 11,
                        color: ThemeService().isLight ? const Color(0xFF000000) : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final isLight = ThemeService().isLight;

    final itemTextColor = isLight
        ? const Color(0xFF000000)
        : (isSelected ? theme.colorScheme.onSurface : AppColors.secondaryText);
    final itemIconColor = isLight
        ? (isSelected ? const Color(0xFF2563EB) : const Color(0xFF000000))
        : (isSelected ? theme.colorScheme.secondary : AppColors.secondaryText);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? (isLight ? const Color(0xFFEFF6FF) : theme.colorScheme.primary.withOpacity(0.14))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(
                color: isLight ? const Color(0xFF2563EB) : theme.colorScheme.primary.withOpacity(0.3),
                width: 1.2,
              )
            : null,
      ),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: _isSidebarCollapsed ? 16 : 14),
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: itemIconColor,
          size: 20,
        ),
        title: _isSidebarCollapsed
            ? null
            : Text(
                label,
                style: TextStyle(
                  color: itemTextColor,
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
        onTap: () => switchTab(index),
      ),
    );
  }

  Widget _actionSidebarItem({required IconData icon, required String label, required VoidCallback onTap}) {
    final isLight = ThemeService().isLight;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: _isSidebarCollapsed ? 16 : 14),
        leading: Icon(
          icon,
          color: isLight ? const Color(0xFF000000) : AppColors.secondaryText,
          size: 20,
        ),
        title: _isSidebarCollapsed
            ? null
            : Text(
                label,
                style: TextStyle(
                  color: isLight ? const Color(0xFF000000) : AppColors.secondaryText,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
        onTap: onTap,
      ),
    );
  }

  String _getDesktopTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Executive Overview';
      case 1:
        return 'Shop Scraper & Analyzer';
      case 2:
        return 'Product Opportunity Research';
      case 3:
        return 'Keyword Intelligence & Search Analytics';
      case 4:
        return 'Competitor Intelligence Matrix';
      case 5:
        return 'Saved Research & Bookmarks';
      case 6:
        return 'Analytical Reports & Trends';
      case 7:
        return 'Account & Profile';
      case 8:
        return 'App & Workspace Settings';
      default:
        return 'Lootify Scrap Workspace';
    }
  }
}

