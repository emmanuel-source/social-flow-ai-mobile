import 'package:flutter/material.dart';

import '../../core/theme/app_sizes.dart';

class AppNavigationDestination {
  const AppNavigationDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.tooltip,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String? tooltip;
}

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    super.key,
  }) : assert(destinations.length >= 2);

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AppNavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.72),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations
              .map(
                (destination) => NavigationDestination(
                  label: destination.label,
                  tooltip: destination.tooltip ?? destination.label,
                  icon: Semantics(
                    label: destination.label,
                    child: Icon(destination.icon, size: AppSizes.iconMedium),
                  ),
                  selectedIcon: Semantics(
                    label: '${destination.label}, sélectionné',
                    child: Icon(
                      destination.selectedIcon,
                      size: AppSizes.iconMedium,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}
