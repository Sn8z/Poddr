import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NavItem {
  String label;
  IconData icon;
  IconData selectedIcon;
  String route;

  NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}

final List<NavItem> destinations = [
  NavItem(
    label: 'Podcasts',
    icon: LucideIcons.podcast,
    selectedIcon: LucideIcons.podcast,
    route: '/podcasts',
  ),
  NavItem(
    label: 'Library',
    icon: LucideIcons.library,
    selectedIcon: LucideIcons.library,
    route: '/library',
  ),
  NavItem(
    label: 'Search',
    icon: LucideIcons.search,
    selectedIcon: LucideIcons.search,
    route: '/search',
  ),
  NavItem(
    label: 'Settings',
    icon: LucideIcons.settings,
    selectedIcon: LucideIcons.settings,
    route: '/settings',
  ),
];

final List<NavItem> librarySubNav = [
  NavItem(
    label: 'Subscriptions',
    icon: LucideIcons.library,
    selectedIcon: LucideIcons.library,
    route: '/library/subscriptions',
  ),
  NavItem(
    label: 'Latest',
    icon: LucideIcons.clock,
    selectedIcon: LucideIcons.clock,
    route: '/library/latest',
  ),
  NavItem(
    label: 'Downloads',
    icon: LucideIcons.download,
    selectedIcon: LucideIcons.download,
    route: '/library/downloads',
  ),
];
