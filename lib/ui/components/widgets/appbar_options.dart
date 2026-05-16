import 'package:flutter/material.dart';
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
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 42,
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      backgroundColor: context.theme.surfaceContainerLow,
      title: title,
      actions: actions,
    );
  }
}
