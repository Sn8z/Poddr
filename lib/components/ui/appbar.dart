import 'package:flutter/material.dart';

class PoddrAppBar extends StatelessWidget {
  const PoddrAppBar({
    super.key,
    required this.title,
    this.bottom,
    this.actions,
  });

  final Widget title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      forceMaterialTransparency: false,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Theme.of(context).colorScheme.primary,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        title: title,
        collapseMode: CollapseMode.parallax,
        centerTitle: false,
        titlePadding: const EdgeInsets.all(8.0),
        expandedTitleScale: 2.0,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
      ),
      bottom: bottom,
      actions: actions,
    );
  }
}
