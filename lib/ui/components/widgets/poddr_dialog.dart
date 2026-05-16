import 'package:flutter/widgets.dart';

class PoddrDialog extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const PoddrDialog({
    super.key,
    required this.child,
    this.maxWidth = 400,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );
  }
}
