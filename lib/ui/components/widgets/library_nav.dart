import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/utils/breakpoints.dart';

class LibrarySegment {
  final String label;
  final IconData icon;
  final String route;

  const LibrarySegment({
    required this.label,
    required this.icon,
    required this.route,
  });
}

class PoddrLibraryNav extends StatelessWidget {
  final String currentRoute;
  final List<LibrarySegment> segments;

  const PoddrLibraryNav({
    super.key,
    required this.currentRoute,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    final showLabels = MediaQuery.sizeOf(context).width > Breakpoints.tabletScreen;
    return _SegmentedBar(
      segments: segments,
      currentRoute: currentRoute,
      showLabels: showLabels,
    );
  }
}

class _SegmentedBar extends StatefulWidget {
  final List<LibrarySegment> segments;
  final String currentRoute;
  final bool showLabels;

  const _SegmentedBar({
    required this.segments,
    required this.currentRoute,
    required this.showLabels,
  });

  @override
  State<_SegmentedBar> createState() => _SegmentedBarState();
}

class _SegmentedBarState extends State<_SegmentedBar> {
  int? _hoveredIndex;

  bool _isActive(int index) {
    final route = widget.segments[index].route;
    if (route == '/library/subscriptions') {
      return widget.currentRoute == '/library' ||
          widget.currentRoute == '/library/subscriptions';
    }
    return widget.currentRoute == route;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: theme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.segments.asMap().entries.map((entry) {
          final index = entry.key;
          final segment = entry.value;
          final isActive = _isActive(index);
          final isHovered = _hoveredIndex == index;

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: GestureDetector(
              onTap: () => context.go(segment.route),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: widget.showLabels
                    ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
                    : const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive
                      ? theme.surfaceContainerHigh
                      : (isHovered ? theme.surfaceContainer : const Color(0x00000000)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      segment.icon,
                      size: 18,
                      color: isActive
                          ? theme.secondary
                          : theme.onSurfaceVariant,
                    ),
                    if (widget.showLabels) ...[
                      const SizedBox(width: 6),
                      Text(
                        segment.label,
                        style: theme.textTheme.labelLarge.copyWith(
                          color: isActive
                              ? theme.secondary
                              : theme.onSurfaceVariant,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
