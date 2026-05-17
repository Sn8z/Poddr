import 'package:flutter/widgets.dart';

class PageLayout extends StatelessWidget {
  final Widget? header;
  final Widget? options;
  final List<Widget> children;
  final bool isHeaderSticky;

  const PageLayout({
    super.key,
    this.header,
    this.options,
    required this.children,
    this.isHeaderSticky = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isHeaderSticky) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) header!,
            if (options != null) options!,
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (header != null) header!,
              if (options != null) options!,
              ...children,
            ],
          ),
        ),
      );
    }
  }
}
