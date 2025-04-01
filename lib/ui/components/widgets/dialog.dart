import 'package:flutter/material.dart';

class PoddrDialog extends StatelessWidget {
  final double? width;
  final double? height;
  final List<Widget>? children;

  const PoddrDialog({
    super.key,
    this.width,
    this.height,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      contentPadding: const EdgeInsets.all(12),
      children: children,
    );
  }
}
