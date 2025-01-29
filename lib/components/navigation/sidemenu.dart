import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/components/audio/artwork.dart';
import 'package:poddr/components/navigation/destinations.dart';
import 'package:poddr/components/ui/logo.dart';
import 'package:poddr/utils/breakpoints.dart';

class PoddrSideMenu extends StatefulWidget {
  const PoddrSideMenu({super.key, required this.shell});
  final StatefulNavigationShell shell;

  final double smallWidth = 90;
  final double largeWidth = 220;

  @override
  State<PoddrSideMenu> createState() => _PoddrSideMenuState();
}

class _PoddrSideMenuState extends State<PoddrSideMenu> {
  void _goBranch(int index) {
    widget.shell.goBranch(
      index,
      initialLocation: index == widget.shell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool shouldExpand = size.width > Breakpoints.desktopScreen;

    return Container(
      width: shouldExpand ? widget.largeWidth : widget.smallWidth,
      height: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainer,
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
            child: ListView(
              children: destinations.map((dest) {
                bool isSelected =
                    widget.shell.currentIndex == destinations.indexOf(dest);
                return _buildListTile(dest, isSelected, shouldExpand);
              }).toList(),
            ),
          ),
          SizedBox.square(
            dimension: shouldExpand ? widget.largeWidth : widget.smallWidth,
            child: const Artwork(),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(NavItem dest, bool isSelected, bool shouldExpand) {
    final Icon icon = isSelected ? Icon(dest.selectedIcon) : Icon(dest.icon);
    return Material(
      child: ListTile(
        title: shouldExpand
            ? Text(
                dest.label,
                overflow: TextOverflow.fade,
              )
            : icon,
        leading: shouldExpand ? icon : null,
        onTap: () => _goBranch(destinations.indexOf(dest)),
        selected: isSelected,
        shape: isSelected
            ? Border(
                left: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 2),
              )
            : null,
        tileColor: Theme.of(context).colorScheme.surfaceContainer,
        hoverColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        selectedTileColor:
            Theme.of(context).colorScheme.surfaceContainerHighest,
        dense: shouldExpand,
      ),
    );
  }
}
