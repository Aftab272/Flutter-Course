import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/csv_export_helper.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../models/keyword_model.dart';
import '../../services/keyword_service.dart';
import '../../services/theme_service.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/marketplace_badge.dart';

/// Keyword Intelligence & Search Analytics Screen
/// Inspired by EverBee, eRank, and eHunt.
/// Analyzes monthly search volume, competition listings, opportunity scores,
/// extracts long-tail keywords, generates 13 optimized listing tags, and maps
/// top-ranking storefront listings.
class KeywordResearchScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const KeywordResearchScreen({super.key, this.onNavigateTab});

  @override
  State<KeywordResearchScreen> createState() => _KeywordResearchScreenState();
}

class _KeywordResearchScreenState extends State<KeywordResearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController(text: 'custom leather wallet');
  final KeywordService _keywordService = KeywordService();
  String _selectedMarketplace = 'All Marketplaces';
  bool _showMarketplaceOptions = false;
  bool _showSuggestions = false;
  late TabController _tabController;

  static const List<String> _marketplaces = [
    'All Marketplaces',
    'Etsy',
    'Amazon',
    'eBay',
    'Shopify',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Initialize with default search
    if (_keywordService.currentIntelligence == null) {
      _keywordService.analyzeKeyword('custom leather wallet');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _runSearch(String keyword) {
    if (keyword.trim().isEmpty) return;
    _searchController.text = keyword.trim();
    _keywordService.analyzeKeyword(keyword.trim(), marketplace: _selectedMarketplace);
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _exportReport(KeywordIntelligence intel) async {
    final csv = CsvExportHelper.generateKeywordsCsv(intel);
    final filename = 'lootify_keyword_${intel.keyword.replaceAll(' ', '_')}.csv';
    final ok = await CsvExportHelper.downloadCsv(filename: filename, csvContent: csv);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Keyword Report exported to $filename' : 'Export completed!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = ThemeService().isLight;
    final titleColor = isLight ? const Color(0xFF000000) : theme.colorScheme.onSurface;
    final subtextColor = isLight ? const Color(0xFF334155) : theme.colorScheme.onSurface.withOpacity(0.65);
    final primaryBtnColor = isLight ? const Color(0xFF2563EB) : theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListenableBuilder(
        listenable: _keywordService,
        builder: (context, _) {
          final intel = _keywordService.currentIntelligence;
          final isSearching = _keywordService.isSearching;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Clean horizontal 1-line title + Export CSV below on mobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.travel_explore_rounded, color: primaryBtnColor, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Keyword Research & Analytics',
                              maxLines: 1,
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Discover high-volume, low-competition keywords like EverBee, eRank & eHunt. Extract search volume, demand, and 13 listing tags.',
                      style: TextStyle(color: subtextColor, fontSize: 12.5),
                    ),
                    if (intel != null) ...[
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.file_download_outlined, size: 16),
                        label: const Text('Export CSV'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLight ? const Color(0xFFEFF6FF) : theme.cardTheme.color,
                          foregroundColor: primaryBtnColor,
                          side: BorderSide(color: isLight ? const Color(0xFFBFDBFE) : theme.dividerColor),
                          elevation: 0,
                        ),
                        onPressed: () => _exportReport(intel),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 18),

                // Search Bar Box
                CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full-width Search Bar
                      SizedBox(
                        width: double.infinity,
                        child: CustomTextField(
                          controller: _searchController,
                          hintText: 'Enter any niche keyword (e.g. custom leather wallet, digital planner...)',
                          prefixIcon: Icons.search_rounded,
                          onSubmitted: _runSearch,
                          suffix: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () => setState(() => _searchController.clear()),
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Clean "Search Keyword" action text without a box right below the search bar
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: isSearching ? null : () => _runSearch(_searchController.text),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSearching)
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(primaryBtnColor),
                                    ),
                                  )
                                else
                                  Icon(Icons.radar_rounded, size: 16, color: primaryBtnColor),
                                const SizedBox(width: 6),
                                Text(
                                  isSearching ? 'Searching Keyword...' : 'Search Keyword',
                                  style: TextStyle(
                                    color: primaryBtnColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Clickable Marketplace Selector (reveals platforms cleanly inside the box on tap)
                      InkWell(
                        onTap: () => setState(() => _showMarketplaceOptions = !_showMarketplaceOptions),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isLight ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _showMarketplaceOptions
                                  ? primaryBtnColor
                                  : (isLight ? const Color(0xFFCBD5E1) : theme.dividerColor),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.storefront_outlined, size: 17, color: primaryBtnColor),
                              const SizedBox(width: 8),
                              Text(
                                'Marketplace:',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: titleColor),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedMarketplace,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: primaryBtnColor,
                                  ),
                                ),
                              ),
                              Icon(
                                _showMarketplaceOptions
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: titleColor,
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_showMarketplaceOptions) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isLight ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : theme.dividerColor),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _marketplaces.map((m) {
                              final isSelected = _selectedMarketplace == m;
                              return ChoiceChip(
                                label: Text(
                                  m,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: primaryBtnColor.withOpacity(0.15),
                                backgroundColor: isLight ? Colors.white : theme.cardTheme.color,
                                labelStyle: TextStyle(
                                  color: isSelected ? primaryBtnColor : titleColor,
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? primaryBtnColor
                                      : (isLight ? const Color(0xFFCBD5E1) : theme.dividerColor),
                                ),
                                onSelected: (val) {
                                  if (val) {
                                    setState(() {
                                      _selectedMarketplace = m;
                                      _showMarketplaceOptions = false;
                                    });
                                    _runSearch(_searchController.text);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Clickable Suggestions Dropdown Box (matching Marketplace box style)
                      InkWell(
                        onTap: () => setState(() => _showSuggestions = !_showSuggestions),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isLight ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _showSuggestions
                                  ? primaryBtnColor
                                  : (isLight ? const Color(0xFFCBD5E1) : theme.dividerColor),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb_outline_rounded, size: 17, color: primaryBtnColor),
                              const SizedBox(width: 8),
                              Text(
                                'Suggestions:',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: titleColor),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Popular Keyword Tags (${KeywordService.suggestedKeywords.length})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: primaryBtnColor,
                                  ),
                                ),
                              ),
                              Icon(
                                _showSuggestions
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: titleColor,
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_showSuggestions) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isLight ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : theme.dividerColor),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: KeywordService.suggestedKeywords.map((k) {
                              return ActionChip(
                                label: Text(
                                  k,
                                  style: TextStyle(fontSize: 11.5, color: primaryBtnColor, fontWeight: FontWeight.w700),
                                ),
                                backgroundColor: isLight ? Colors.white : const Color(0xFF1E2D5A).withOpacity(0.4),
                                side: BorderSide(
                                  color: isLight ? const Color(0xFFBFDBFE) : const Color(0xFF2563EB).withOpacity(0.3),
                                ),
                                onPressed: () {
                                  setState(() => _showSuggestions = false);
                                  _runSearch(k);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Live Results Content
                if (isSearching) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          CircularProgressIndicator(strokeWidth: 3),
                          SizedBox(height: 16),
                          Text('Analyzing marketplace volume, competition & top ranking listings...'),
                        ],
                      ),
                    ),
                  ),
                ] else if (intel != null) ...[
                  // Primary KPI Metric Cards (EverBee / eRank style)
                  _buildKpiMetrics(context, intel),

                  const SizedBox(height: 22),

                  // Tab Selector (Clean & Responsive with zero clipping)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 600;
                      return Container(
                        decoration: BoxDecoration(
                          color: isLight ? const Color(0xFFF1F5F9) : theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : theme.dividerColor),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                          indicator: BoxDecoration(
                            color: primaryBtnColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: titleColor,
                          labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: isCompact ? 11.5 : 13),
                          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: isCompact ? 11.5 : 13),
                          tabs: [
                            Tab(
                              height: 46,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.table_chart_outlined, size: 16),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      isCompact
                                          ? 'Related (${intel.relatedKeywords.length})'
                                          : 'Related & Long-Tail (${intel.relatedKeywords.length})',
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Tab(
                              height: 46,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.shopping_bag_outlined, size: 16),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      isCompact
                                          ? 'Top Items (${intel.topProducts.length})'
                                          : 'Top Ranking Products (${intel.topProducts.length})',
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Tab(
                              height: 46,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.tag_rounded, size: 16),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      isCompact ? '13 Tags' : '13 Optimized Tags',
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // Tab Views
                  SizedBox(
                    height: 600,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Related & Long-Tail Keywords Matrix
                        _buildRelatedKeywordsTab(context, intel),

                        // Tab 2: Top Ranking Products
                        _buildTopProductsTab(context, intel),

                        // Tab 3: 13 Optimized Tags Generator
                        _buildTagsTab(context, intel),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiMetrics(BuildContext context, KeywordIntelligence intel) {
    final isLight = ThemeService().isLight;
    final theme = Theme.of(context);
    final titleColor = isLight ? const Color(0xFF000000) : theme.colorScheme.onSurface;
    final subtextColor = isLight ? const Color(0xFF475569) : theme.colorScheme.onSurface.withOpacity(0.65);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 800;
        final cardWidth = isNarrow ? (constraints.maxWidth - 12) / 2 : (constraints.maxWidth - 48) / 5;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // 1. Search Volume
            _kpiCard(
              width: cardWidth,
              icon: Icons.search_rounded,
              iconColor: const Color(0xFF2563EB),
              title: 'Monthly Searches',
              value: '${intel.searchVolume}',
              badge: '+${intel.trendGrowthPercent}% Growth',
              badgeColor: const Color(0xFF10B981),
              titleColor: titleColor,
              subtextColor: subtextColor,
            ),
            // 2. Competition Listings
            _kpiCard(
              width: cardWidth,
              icon: Icons.store_mall_directory_outlined,
              iconColor: const Color(0xFFF59E0B),
              title: 'Total Competition',
              value: '${intel.competitionListings}',
              badge: intel.difficultyLabel.split(' ').first,
              badgeColor: intel.difficultyScore < 50 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              titleColor: titleColor,
              subtextColor: subtextColor,
            ),
            // 3. Opportunity Score
            _kpiCard(
              width: cardWidth,
              icon: Icons.insights_rounded,
              iconColor: const Color(0xFF10B981),
              title: 'Opportunity Score',
              value: '${intel.opportunityScore}/100',
              badge: intel.opportunityScore >= 75 ? '🔥 High Demand' : 'Moderate',
              badgeColor: const Color(0xFF10B981),
              titleColor: titleColor,
              subtextColor: subtextColor,
            ),
            // 4. Est. Monthly Revenue
            _kpiCard(
              width: cardWidth,
              icon: Icons.payments_outlined,
              iconColor: const Color(0xFF8B5CF6),
              title: 'Est. Monthly Sales',
              value: '\$${intel.estMonthlyRevenue.toInt()}',
              badge: '${intel.estMonthlySales} Orders',
              badgeColor: const Color(0xFF8B5CF6),
              titleColor: titleColor,
              subtextColor: subtextColor,
            ),
            // 5. Avg Market Price
            _kpiCard(
              width: cardWidth,
              icon: Icons.sell_outlined,
              iconColor: const Color(0xFFEC4899),
              title: 'Average Price',
              value: '\$${intel.avgPrice}',
              badge: '${intel.ctr}% CTR',
              badgeColor: const Color(0xFFEC4899),
              titleColor: titleColor,
              subtextColor: subtextColor,
            ),
          ],
        );
      },
    );
  }

  Widget _kpiCard({
    required double width,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String badge,
    required Color badgeColor,
    required Color titleColor,
    required Color subtextColor,
  }) {
    return SizedBox(
      width: width,
      child: CustomCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 11.5, color: subtextColor, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(value, style: TextStyle(fontSize: 18, color: titleColor, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedKeywordsTab(BuildContext context, KeywordIntelligence intel) {
    final isLight = ThemeService().isLight;
    final theme = Theme.of(context);
    final titleColor = isLight ? const Color(0xFF000000) : theme.colorScheme.onSurface;
    final subtextColor = isLight ? const Color(0xFF475569) : theme.colorScheme.onSurface.withOpacity(0.65);

    return CustomCard(
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 680;
          return ListView.separated(
            itemCount: intel.relatedKeywords.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: isLight ? const Color(0xFFE2E8F0) : theme.dividerColor),
            itemBuilder: (context, index) {
              final r = intel.relatedKeywords[index];
              final scoreColor = r.opportunityScore >= 70 ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

              if (isNarrow) {
                // Mobile-first clean horizontal layout: zero vertical digit stacking, zero overlap!
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Rank badge + Full horizontal keyword title + Action icons
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isLight ? const Color(0xFFF1F5F9) : const Color(0xFF1E2D5A),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: titleColor),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              r.keyword,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Analyze this keyword',
                            icon: Icon(Icons.arrow_forward_rounded, size: 18, color: titleColor),
                            onPressed: () => _runSearch(r.keyword),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Copy keyword',
                            icon: Icon(Icons.copy_rounded, size: 17, color: titleColor),
                            onPressed: () => _copyToClipboard(r.keyword, 'Copied "${r.keyword}" to clipboard!'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Row 2: Clean horizontal stats pills (easily readable on mobile)
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (r.isLongTail)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                'Long-Tail',
                                style: TextStyle(fontSize: 10.5, color: Color(0xFF2563EB), fontWeight: FontWeight.w700),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: scoreColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'Score: ${r.opportunityScore}',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: scoreColor),
                            ),
                          ),
                          Text(
                            'Searches: ${r.searchVolume}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: titleColor),
                          ),
                          Text(
                            'Listings: ${r.competition}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: subtextColor),
                          ),
                          Text(
                            'Avg: \$${r.avgPrice}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: subtextColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }

              // Desktop horizontal table row
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isLight ? const Color(0xFFF1F5F9) : const Color(0xFF1E2D5A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${index + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: titleColor)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.keyword, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: titleColor)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              if (r.isLongTail)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text('Long-Tail', style: TextStyle(fontSize: 9.5, color: Color(0xFF2563EB), fontWeight: FontWeight.w700)),
                                ),
                              Text('Avg Price: \$${r.avgPrice}', style: TextStyle(fontSize: 11, color: subtextColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${r.searchVolume}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: titleColor)),
                          Text('Searches', style: TextStyle(fontSize: 10, color: subtextColor)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${r.competition}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: titleColor)),
                          Text('Listings', style: TextStyle(fontSize: 10, color: subtextColor)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Score: ${r.opportunityScore}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: scoreColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Analyze this keyword',
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      onPressed: () => _runSearch(r.keyword),
                    ),
                    IconButton(
                      tooltip: 'Copy keyword',
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      onPressed: () => _copyToClipboard(r.keyword, 'Copied "${r.keyword}" to clipboard!'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTopProductsTab(BuildContext context, KeywordIntelligence intel) {
    final isLight = ThemeService().isLight;
    final theme = Theme.of(context);
    final titleColor = isLight ? const Color(0xFF000000) : theme.colorScheme.onSurface;
    final subtextColor = isLight ? const Color(0xFF475569) : theme.colorScheme.onSurface.withOpacity(0.65);

    return ListView.separated(
      itemCount: intel.topProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = intel.topProducts[index];
        return CustomCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: AppNetworkImage(
                    imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        MarketplaceBadge(marketplace: p.marketplace),
                        const SizedBox(width: 8),
                        Text(p.shopName, style: TextStyle(fontSize: 11.5, color: subtextColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: titleColor),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text('${p.rating} (${p.reviewCount} reviews)', style: TextStyle(fontSize: 11, color: subtextColor)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${p.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: titleColor),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Score: ${p.opportunityScore}',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTagsTab(BuildContext context, KeywordIntelligence intel) {
    final isLight = ThemeService().isLight;
    final theme = Theme.of(context);
    final titleColor = isLight ? const Color(0xFF000000) : theme.colorScheme.onSurface;
    final subtextColor = isLight ? const Color(0xFF475569) : theme.colorScheme.onSurface.withOpacity(0.65);
    final primaryBtnColor = isLight ? const Color(0xFF2563EB) : theme.colorScheme.primary;

    final allTagsString = intel.recommendedTags.join(', ');

    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '13 Optimized Listing Tags',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: titleColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Formulated specifically for Etsy and Shopify listing SEO to maximize search indexing.',
                    style: TextStyle(fontSize: 12, color: subtextColor),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.copy_all_rounded, size: 16),
                label: const Text('Copy All 13 Tags'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBtnColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                onPressed: () => _copyToClipboard(allTagsString, 'Copied all 13 listing tags to clipboard!'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: intel.recommendedTags.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final tag = entry.value;
              return ActionChip(
                avatar: CircleAvatar(
                  radius: 9,
                  backgroundColor: primaryBtnColor.withOpacity(0.18),
                  child: Text('$idx', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: primaryBtnColor)),
                ),
                label: Text(tag, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor)),
                backgroundColor: isLight ? const Color(0xFFF8FAFC) : theme.scaffoldBackgroundColor,
                side: BorderSide(color: isLight ? const Color(0xFFCBD5E1) : theme.dividerColor),
                onPressed: () => _copyToClipboard(tag, 'Copied tag "$tag"'),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isLight ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isLight ? const Color(0xFFE2E8F0) : theme.dividerColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF2563EB)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tip: Paste all 13 tags directly into your Etsy Listing Manager or Shopify Product Tags field for highest search visibility.',
                    style: TextStyle(fontSize: 12, color: subtextColor, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
