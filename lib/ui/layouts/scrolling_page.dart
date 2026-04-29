import 'package:flutter/material.dart';
import 'package:poddr/ui/components/widgets/appbar.dart';
import 'package:poddr/ui/components/widgets/appbar_options.dart';
import 'package:poddr/ui/components/widgets/bottom_padding.dart';
import 'package:poddr/ui/utils/gaps.dart';

class ScrollingPageLayout extends StatelessWidget {
  const ScrollingPageLayout({
    super.key,
    required this.title,
    this.appBarActions,
    this.optionsTitle,
    this.optionsActions,
    required this.children,
  });

  final String title;
  final List<Widget>? appBarActions;
  final Widget? optionsTitle;
  final List<Widget>? optionsActions;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: [
            PoddrAppBar(
              title: title,
              actions: appBarActions,
            ),
            PoddrAppBarOptions(
              title: optionsTitle,
              actions: optionsActions ?? const [],
            ),
            sliverGapH16,
            ...children,
            const BottomPaddingFix(),
          ],
        ),
      ),
    );
  }
}
