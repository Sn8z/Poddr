import 'package:flutter/widgets.dart';

class PoddrCarousel extends StatelessWidget {
  const PoddrCarousel({super.key, this.children = const []});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    //TODO: https://docs.flutter.dev/release/breaking-changes/default-scroll-behavior-drag
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: children,
      ),
    );
  }
}
