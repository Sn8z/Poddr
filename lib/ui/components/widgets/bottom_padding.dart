import 'package:flutter/material.dart';
import 'package:poddr/ui/utils/breakpoints.dart';

class BottomPaddingFix extends StatelessWidget {
  const BottomPaddingFix({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width > Breakpoints.tabletScreen) {
      return const SliverToBoxAdapter(
        child: SizedBox(height: 136),
      );
    } else {
      return const SliverToBoxAdapter(
        child: SizedBox(height: 88),
      );
    }
  }
}
