import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ResponsiveDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const ResponsiveDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

class ResponsiveScaffold extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget body;
  final List<ResponsiveDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.title,
    this.titleWidget,
    this.actions,
    required this.body,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 650;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        if (isTablet && destinations.isNotEmpty) {
          // Tablet Layout with Navigation Rail
          return Scaffold(
            appBar: AppBar(
              title: titleWidget ?? Text(title),
              actions: actions,
            ),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                  indicatorColor: AppColors.royalBlue.withValues(alpha: 0.15),
                  selectedIconTheme: const IconThemeData(color: AppColors.royalBlue),
                  selectedLabelTextStyle: const TextStyle(
                    color: AppColors.royalBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  unselectedLabelTextStyle: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                  destinations: destinations.map((d) {
                    return NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon ?? d.icon),
                      label: Text(d.label),
                    );
                  }).toList(),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: SafeArea(child: body)),
              ],
            ),
            floatingActionButton: floatingActionButton,
          );
        }

        // Phone Layout with Bottom Navigation Bar
        return Scaffold(
          appBar: AppBar(
            title: titleWidget ?? Text(title),
            actions: actions,
          ),
          body: SafeArea(child: body),
          bottomNavigationBar: destinations.isNotEmpty
              ? NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                  indicatorColor: AppColors.royalBlue.withValues(alpha: 0.15),
                  destinations: destinations.map((d) {
                    return NavigationDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon ?? d.icon, color: AppColors.royalBlue),
                      label: d.label,
                    );
                  }).toList(),
                )
              : null,
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}
