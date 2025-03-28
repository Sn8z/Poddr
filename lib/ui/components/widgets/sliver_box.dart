import 'package:flutter/material.dart';

class PoddrSliverBox extends StatelessWidget {
  final Widget sliver;
  const PoddrSliverBox({
    super.key,
    required this.sliver,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedSliver(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      position: DecorationPosition.background,
      sliver: sliver,
    );
  }
}
