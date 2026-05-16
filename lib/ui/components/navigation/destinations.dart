import 'package:flutter/material.dart';

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
    icon: Icons.podcasts_outlined,
    selectedIcon: Icons.podcasts_rounded,
    route: '/podcasts',
  ),
  NavItem(
    label: 'Library',
    icon: Icons.library_music_outlined,
    selectedIcon: Icons.library_music_rounded,
    route: '/library',
  ),
  NavItem(
    label: 'Search',
    icon: Icons.search_outlined,
    selectedIcon: Icons.search_rounded,
    route: '/search',
  ),
  NavItem(
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    route: '/settings',
  ),
];
