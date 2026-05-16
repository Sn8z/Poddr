import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

class PoddrAppBarOptions extends StatelessWidget {
  const PoddrAppBarOptions({
    super.key,
    this.title,
    this.actions = const [],
  });
  final Widget? title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _PoddrAppBarOptionsDelegate(
        title: title,
        actions: actions,
      ),
    );
  }
}

class _PoddrAppBarOptionsDelegate extends SliverPersistentHeaderDelegate {
  final Widget? title;
  final List<Widget> actions;

  _PoddrAppBarOptionsDelegate({
    this.title,
    required this.actions,
  });

  @override
  double get minExtent => 42;

  @override
  double get maxExtent => 42;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = context.theme;
    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (title != null) Expanded(child: title!),
          ...actions,
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_PoddrAppBarOptionsDelegate oldDelegate) {
    return oldDelegate.title != title || oldDelegate.actions != actions;
  }
}
