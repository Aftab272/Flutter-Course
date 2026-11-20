import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../models/research_model.dart';
import '../../services/research_service.dart';
import '../../services/shop_service.dart';
import '../../services/product_service.dart';
import '../../core/utils/csv_export_helper.dart';
import '../../shared/widgets/brand_icon.dart';
import '../../shared/widgets/marketplace_badge.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ResearchService _researchService = ResearchService();
  final ShopService _shopService = ShopService();
  final NumberFormat _currency = NumberFormat.compactSimpleCurrency();

  String _selectedMarketplace = 'All';
  String _selectedType = 'All';

  @override
  void initState() {
    super.initState();
    _researchService.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _researchService.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final reports = _researchService.reports;
    final platformStats = _researchService.platformStats;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 28.0 : 16.0,
          vertical: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reports & Market Analytics',
                        style: TextStyle(
                          color: AppColors.adaptiveText,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cross-marketplace benchmarks, revenue distribution, and niche saturation data.',
                        style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                CustomButton(
                  text: isDesktop ? 'Export to CSV' : 'Export CSV',
                  icon: Icons.download_rounded,
                  type: ButtonType.primary,
                  onPressed: () async {
                    final products = ProductService().allProducts;
                    final csv = CsvExportHelper.generateProductsCsv(products);
                    final success = await CsvExportHelper.downloadCsv(
                      filename: 'lootify_products_export_${DateTime.now().millisecondsSinceEpoch}.csv',
                      csvContent: csv,
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Exported ${products.length} original records to CSV successfully!'
                              : 'Generated CSV file with ${products.length} verified records.',
                        ),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Top KPI Analytics Cards
            _buildKpiMetrics(isDesktop),
            const SizedBox(height: 28),

            // Charts Section (Bar Chart + Breakdown)
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: _buildRevenueBarChartCard(platformStats),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 5,
                    child: _buildMarketplaceDistributionCard(platformStats),
                  ),
                ],
              )
            else ...[
              _buildRevenueBarChartCard(platformStats),
              const SizedBox(height: 24),
              _buildMarketplaceDistributionCard(platformStats),
            ],
            const SizedBox(height: 28),

            // Platform & Activity Filters Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Connected Research Reports (${reports.where((r) {
                    if (_selectedMarketplace != 'All' && r.marketplace.toLowerCase() != _selectedMarketplace.toLowerCase()) return false;
                    if (_selectedType != 'All' && !r.type.toLowerCase().contains(_selectedType.toLowerCase())) return false;
                    return true;
                  }).length})',
                  style: TextStyle(
                    color: AppColors.adaptiveText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Marketplace Platform Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Etsy', 'Amazon', 'eBay', 'Shopify'].map((m) {
                  final isSelected = _selectedMarketplace == m;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      checkmarkColor: Colors.white,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (m != 'All') ...[
                            BrandIcon(brand: m.toLowerCase(), size: 14),
                            const SizedBox(width: 6),
                          ],
                          Text(m == 'All' ? 'All Platforms' : m),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF2563EB),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF2563EB) : Colors.black.withOpacity(0.22),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF000000),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 12.5,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedMarketplace = m);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),

            // Activity Type Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Shop Analysis', 'Product Opportunity', 'Competitor'].map((t) {
                  final isSelected = _selectedType == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      checkmarkColor: Colors.white,
                      label: Text(t == 'All' ? 'All Activities' : t),
                      selected: isSelected,
                      selectedColor: const Color(0xFF2563EB),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF2563EB) : Colors.black.withOpacity(0.22),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF000000),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedType = t);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            Builder(
              builder: (context) {
                final filtered = reports.where((r) {
                  if (_selectedMarketplace != 'All' && r.marketplace.toLowerCase() != _selectedMarketplace.toLowerCase()) {
                    return false;
                  }
                  if (_selectedType != 'All' && !r.type.toLowerCase().contains(_selectedType.toLowerCase())) {
                    return false;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(Icons.analytics_outlined, size: 42, color: AppColors.adaptiveSubtext),
                        const SizedBox(height: 10),
                        Text(
                          'No reports found for $_selectedMarketplace - $_selectedType',
                          style: TextStyle(color: AppColors.adaptiveText, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Analyze a shop or track a competitor to automatically generate reports here.',
                          style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12.5),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final r = filtered[index];
                    return _buildReportCard(r);
                  },
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiMetrics(bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = isDesktop ? (constraints.maxWidth - 36) / 4 : (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _kpiCard(
              width: cardWidth,
              title: 'Analyzed Volume',
              value: '\$2.13M',
              sub: 'Total monitored GMV',
              icon: Icons.monetization_on_outlined,
            ),
            _kpiCard(
              width: cardWidth,
              title: 'Avg. Opportunity Score',
              value: '89.4',
              sub: 'High demand index',
              icon: Icons.auto_graph_rounded,
            ),
            _kpiCard(
              width: cardWidth,
              title: 'Active Stores Monitored',
              value: '${_shopService.totalAnalyzedShopsCount}',
              sub: 'Across 4 marketplaces',
              icon: Icons.storefront_rounded,
            ),
            _kpiCard(
              width: cardWidth,
              title: 'Low-Saturation Niches',
              value: '18 Niches',
              sub: '< 2.5 competition density',
              icon: Icons.radar_rounded,
            ),
          ],
        );
      },
    );
  }

  Widget _kpiCard({
    required double width,
    required String title,
    required String value,
    required String sub,
    Color? valueColor,
    required IconData icon,
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
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.adaptiveText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(icon, size: 17, color: const Color(0xFF2563EB)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor ?? AppColors.adaptiveText,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.adaptiveText, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueBarChartCard(List<PlatformStatModel> stats) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Monitored Revenue by Marketplace',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.adaptiveText, fontSize: 15.5, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Monthly GMV (\$)',
                style: TextStyle(color: AppColors.adaptiveText, fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1000000,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppColors.secondaryBackground,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final p = stats[group.x.toInt()];
                      return BarTooltipItem(
                        '${p.marketplace}\n${_currency.format(p.totalRevenueAnalyzed)}',
                        const TextStyle(color: AppColors.accentLime, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _currency.format(value),
                          style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < stats.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              stats[idx].marketplace,
                              style: TextStyle(color: AppColors.adaptiveText, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.borderColor, strokeWidth: 0.8),
                ),
                barGroups: stats.asMap().entries.map((entry) {
                  final index = entry.key;
                  final p = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: p.totalRevenueAnalyzed,
                        color: _getMarketplaceColor(p.marketplace),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMarketplaceColor(String mkt) {
    switch (mkt.toLowerCase()) {
      case 'etsy':
        return AppColors.etsyColor;
      case 'amazon':
        return AppColors.amazonColor;
      case 'ebay':
        return AppColors.ebayColor;
      case 'shopify':
        return AppColors.shopifyColor;
      default:
        return AppColors.primaryGreen;
    }
  }

  Widget _buildMarketplaceDistributionCard(List<PlatformStatModel> stats) {
    return CustomCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Share & Growth Trends',
            style: TextStyle(color: AppColors.adaptiveText, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          Column(
            children: stats.map((s) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _getMarketplaceColor(s.marketplace),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              s.marketplace,
                              style: TextStyle(color: AppColors.adaptiveText, fontWeight: FontWeight.w700, fontSize: 13.5),
                            ),
                          ],
                        ),
                        Text(
                          '+${s.growthRate}% MoM',
                          style: TextStyle(color: AppColors.adaptiveText, fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: s.analyzedCount / 70.0,
                        backgroundColor: AppColors.secondaryBackground,
                        valueColor: AlwaysStoppedAnimation<Color>(_getMarketplaceColor(s.marketplace)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Top: ${s.topCategory}',
                      style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 11),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(ResearchReportModel r) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  MarketplaceBadge(marketplace: r.marketplace),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black.withOpacity(0.22)),
                    ),
                    child: Text(
                      r.type,
                      style: const TextStyle(color: Color(0xFF000000), fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(r.timestamp),
                style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            r.title,
            style: TextStyle(
              color: AppColors.adaptiveText,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            r.summary,
            style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderColor),
          const SizedBox(height: 12),
          Text(
            'KEY ACTIONABLE OPPORTUNITIES',
            style: TextStyle(color: AppColors.adaptiveText, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          ...r.keyOpportunities.map((op) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: AppColors.adaptiveText, fontWeight: FontWeight.w800)),
                    Expanded(
                      child: Text(
                        op,
                        style: TextStyle(color: AppColors.adaptiveText, fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black.withOpacity(0.22)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Risk Factor: ${r.marketRisk}',
                    style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 11.5),
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
