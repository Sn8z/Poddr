import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

class PoddrBox extends StatelessWidget {
  final Widget child;
  const PoddrBox({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}
