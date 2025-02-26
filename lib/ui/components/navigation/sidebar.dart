import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/ui/components/audio/artwork.dart';
import 'package:poddr/ui/components/navigation/destinations.dart';
import 'package:poddr/ui/components/widgets/logo.dart';
import 'package:poddr/ui/utils/breakpoints.dart';

class PoddrSideBar extends StatelessWidget {
  final GoRouterState state;

  const PoddrSideBar({
    super.key,
    required this.state,
  });

  bool _isSelected(String route) {
    return state.matchedLocation.startsWith(route);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool shouldExpand = size.width > Breakpoints.desktopScreen;

    return Padding(
      padding: const EdgeInsets.only(
        left: 8,
        top: 8,
        bottom: 8,
      ),
      child: Container(
        width: shouldExpand ? 220 : 80,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const SizedBox(
              height: 80,
              child: Center(
                child: PoddrLogo(
                  size: 40,
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: destinations.map((dest) {
                  final isSelected = _isSelected(dest.route);
                  return PoddrSideBarItem(
                    icon: dest.icon,
                    selectedIcon: dest.selectedIcon,
                    title: dest.label,
                    status: isSelected
                        ? SideBarItemStatus.selected
                        : SideBarItemStatus.normal,
                    onTap: () {
                      context.go(dest.route);
                    },
                  );
                }).toList(),
              ),
            ),
            SizedBox.square(
              dimension: shouldExpand ? 220 : 80,
              child: const Artwork(),
            ),
          ],
        ),
      ),
    );
  }
}

enum SideBarItemStatus {
  normal,
  selected,
  hovered,
  inactive,
}

class PoddrSideBarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final SideBarItemStatus status;
  final VoidCallback onTap;

  const PoddrSideBarItem({
    super.key,
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool shouldExpand = size.width > Breakpoints.desktopScreen;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: status == SideBarItemStatus.selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 4,
              ),
            ),
            color: status == SideBarItemStatus.selected
                ? Theme.of(context).colorScheme.surfaceContainerHigh
                : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: shouldExpand
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                status == SideBarItemStatus.selected ? selectedIcon : icon,
                color: status == SideBarItemStatus.selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              if (shouldExpand) ...[
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: status == SideBarItemStatus.selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
