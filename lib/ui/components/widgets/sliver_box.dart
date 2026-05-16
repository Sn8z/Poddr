import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

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
        color: context.theme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      position: DecorationPosition.background,
      sliver: sliver,
    );
  }
}
