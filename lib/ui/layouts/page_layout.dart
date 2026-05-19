import 'package:flutter/widgets.dart';

class PageLayout extends StatelessWidget {
  final Widget? header;
  final Widget child;
  final bool isHeaderSticky;

  const PageLayout({
    super.key,
    this.header,
    required this.child,
    this.isHeaderSticky = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isHeaderSticky) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (header != null) header!,
              Expanded(child: child),
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (header != null) header!,
                child,
              ],
            ),
          ),
        ),
      );
    }
  }
}
