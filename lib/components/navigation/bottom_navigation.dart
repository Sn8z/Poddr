import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/components/navigation/destinations.dart';

class PoddrBottomNav extends StatelessWidget {
  const PoddrBottomNav({super.key, required this.shell});
  final StatefulNavigationShell shell;

  void _goBranch(int index) {
    shell.goBranch(
      index,
      initialLocation: index == shell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      animationDuration: const Duration(milliseconds: 200),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      indicatorColor: Theme.of(context).colorScheme.primary,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      selectedIndex: shell.currentIndex,
      destinations: destinations
          .map(
            (e) => NavigationDestination(
              label: e.label,
              icon: Icon(e.icon),
              selectedIcon: Icon(e.selectedIcon),
            ),
          )
          .toList(),
      onDestinationSelected: _goBranch,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    );
  }
}
