import 'package:flutter/widgets.dart';
import 'package:poddr/ui/utils/breakpoints.dart';

class BottomPaddingFix extends StatelessWidget {
  const BottomPaddingFix({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width > Breakpoints.tabletScreen) {
      return const SizedBox(height: 136);
    } else {
      return const SizedBox(height: 88);
    }
  }
}
