import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

class NavItem {
  String label;
  Widget icon;
  Widget selectedIcon;
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
    icon: const HugeIcon(
      icon: HugeIcons.strokeRoundedPodcast,
    ),
    selectedIcon: const HugeIcon(
      icon: HugeIcons.strokeRoundedPodcast,
    ),
    route: '/podcasts',
  ),
  NavItem(
    label: 'Library',
    icon: const HugeIcon(
      icon: HugeIcons.strokeRoundedLibrary,
    ),
    selectedIcon: const HugeIcon(
      icon: HugeIcons.strokeRoundedLibrary,
    ),
    route: '/library',
  ),
  NavItem(
    label: 'Search',
    icon: const HugeIcon(
      icon: HugeIcons.strokeRoundedSearch01,
    ),
    selectedIcon: const HugeIcon(
      icon: HugeIcons.strokeRoundedSearch01,
    ),
    route: '/search',
  ),
  NavItem(
    label: 'Settings',
    icon: const HugeIcon(
      icon: HugeIcons.strokeRoundedSettings01,
    ),
    selectedIcon: const HugeIcon(
      icon: HugeIcons.strokeRoundedSettings01,
    ),
    route: '/settings',
  ),
];

final List<NavItem> librarySubNav = [
  NavItem(
    label: 'Subscriptions',
    icon: const HugeIcon(
      icon: HugeIcons.strokeRoundedLibrary,
    ),
    selectedIcon: const HugeIcon(
      icon: HugeIcons.strokeRoundedLibrary,
    ),
    route: '/library/subscriptions',
  ),
  NavItem(
    label: 'Latest',
    icon: const HugeIcon(
      icon: HugeIcons.strokeRoundedClock01,
    ),
    selectedIcon: const HugeIcon(
      icon: HugeIcons.strokeRoundedClock01,
    ),
    route: '/library/latest',
  ),
  NavItem(
    label: 'Downloads',
    icon: const HugeIcon(
      icon: HugeIcons.strokeRoundedDownload01,
    ),
    selectedIcon: const HugeIcon(
      icon: HugeIcons.strokeRoundedDownload01,
    ),
    route: '/library/downloads',
  ),
];
