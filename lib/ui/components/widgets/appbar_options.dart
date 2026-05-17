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
}
