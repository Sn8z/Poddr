import 'package:flutter/material.dart';

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
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 72,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      title: title,
      actions: actions,
    );
  }
}
