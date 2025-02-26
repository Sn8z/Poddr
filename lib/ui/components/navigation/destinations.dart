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
    icon: Icons.podcasts_rounded,
    selectedIcon: Icons.multitrack_audio_rounded,
    route: '/',
  ),
  NavItem(
    label: 'Radio',
    icon: Icons.radio_rounded,
    selectedIcon: Icons.multitrack_audio_rounded,
    route: '/radio',
  ),
  NavItem(
    label: 'Library',
    icon: Icons.library_music_outlined,
    selectedIcon: Icons.library_music_rounded,
    route: '/library',
  ),
  NavItem(
    label: 'Search',
    icon: Icons.search_rounded,
    selectedIcon: Icons.manage_search_rounded,
    route: '/search',
  ),
  NavItem(
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    route: '/settings',
  ),
];
