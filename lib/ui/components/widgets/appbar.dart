import 'package:flutter/material.dart';

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
    return SliverAppBar(
      pinned: true,
      floating: true,
      forceMaterialTransparency: false,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      surfaceTintColor: Theme.of(context).colorScheme.primary,
      expandedHeight: 120,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 16.0, bottom: 10.0),
        collapseMode: CollapseMode.parallax,
        centerTitle: false,
      ),
      bottom: bottom,
      actions: actions,
    );
  }
}
