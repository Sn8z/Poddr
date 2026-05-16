import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

class PoddrAppBar extends StatelessWidget {
  const PoddrAppBar({
    super.key,
    required this.title,
    this.bottom,
    this.actions,
  });

  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: true,
      delegate: _PoddrAppBarDelegate(
        title: title,
        actions: actions,
        bottom: bottom,
      ),
    );
  }
}

class _PoddrAppBarDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  _PoddrAppBarDelegate({
    required this.title,
    this.actions,
    this.bottom,
  });

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 120;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = context.theme;
    final shrinkRatio = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final fontSize = 28 * (1 - shrinkRatio * 0.5) + 14 * shrinkRatio;

    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceContainerHigh,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 10 + (1 - shrinkRatio) * 40,
                top: 16 * shrinkRatio,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: theme.onSurface,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
            ),
          ),
          if (bottom != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: bottom!,
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_PoddrAppBarDelegate oldDelegate) {
    return oldDelegate.title != title ||
        oldDelegate.actions != actions ||
        oldDelegate.bottom != bottom;
  }
}
