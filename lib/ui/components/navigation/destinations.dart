import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NavItem {
  String label;
  FaIconData icon;
  FaIconData selectedIcon;
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
    icon: FontAwesomeIcons.podcast,
    selectedIcon: FontAwesomeIcons.podcast,
    route: '/podcasts',
  ),
  NavItem(
    label: 'Library',
    icon: FontAwesomeIcons.bookOpen,
    selectedIcon: FontAwesomeIcons.bookOpen,
    route: '/library',
  ),
  NavItem(
    label: 'Search',
    icon: FontAwesomeIcons.magnifyingGlass,
    selectedIcon: FontAwesomeIcons.magnifyingGlass,
    route: '/search',
  ),
  NavItem(
    label: 'Settings',
    icon: FontAwesomeIcons.gear,
    selectedIcon: FontAwesomeIcons.gear,
    route: '/settings',
  ),
];

final List<NavItem> librarySubNav = [
  NavItem(
    label: 'Subscriptions',
    icon: FontAwesomeIcons.bookOpen,
    selectedIcon: FontAwesomeIcons.bookOpen,
    route: '/library/subscriptions',
  ),
  NavItem(
    label: 'Latest',
    icon: FontAwesomeIcons.clock,
    selectedIcon: FontAwesomeIcons.clock,
    route: '/library/latest',
  ),
  NavItem(
    label: 'Downloads',
    icon: FontAwesomeIcons.download,
    selectedIcon: FontAwesomeIcons.download,
    route: '/library/downloads',
  ),
];
