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
      color: theme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          title != null ? Expanded(child: title!) : const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}
