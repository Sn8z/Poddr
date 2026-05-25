import 'package:flutter/widgets.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';

class _NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class PageLayout extends StatelessWidget {
  final List<Widget> slivers;

  const PageLayout({
    super.key,
    this.slivers = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        scrollBehavior: _NoGlowScrollBehavior(),
        slivers: [
          ...slivers,
          SliverToBoxAdapter(child: BottomPaddingFix()),
        ],
      ),
    );
  }
}
