import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/ui/components/navigation/destinations.dart';

class PoddrBottomBar extends StatelessWidget {
  final GoRouterState state;

  const PoddrBottomBar({
    super.key,
    required this.state,
  });

  bool _isSelected(String route) {
    return state.matchedLocation.startsWith(route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: context.theme.surfaceContainer,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: destinations.map((dest) {
          final isSelected = _isSelected(dest.route);
          return Expanded(
            child: PoddrBottomBarItem(
              icon: dest.icon,
              selectedIcon: dest.selectedIcon,
              title: dest.label,
              status: isSelected
                  ? BottomBarItemStatus.selected
                  : BottomBarItemStatus.normal,
              onTap: () {
                context.go(dest.route);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

enum BottomBarItemStatus {
  normal,
  selected,
  hovered,
  inactive,
}

class PoddrBottomBarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final BottomBarItemStatus status;
  final VoidCallback onTap;

  const PoddrBottomBarItem({
    super.key,
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: status == BottomBarItemStatus.selected
                    ? context.theme.primary
                    : const Color(0x00000000),
                width: 4,
              ),
            ),
            color: status == BottomBarItemStatus.selected
                ? context.theme.surfaceContainerHigh
                : const Color(0x00000000),
            gradient: LinearGradient(
              colors: [
                context.theme.primary.withAlpha(50),
                context.theme.primary.withAlpha(10),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                status == BottomBarItemStatus.selected ? selectedIcon : icon,
                color: status == BottomBarItemStatus.selected
                    ? context.theme.secondary
                    : context.theme.onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
