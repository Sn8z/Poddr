import 'package:flutter/widgets.dart';

class PageLayout extends StatelessWidget {
  final Widget? header;
  final Widget child;
  final bool isHeaderSticky;
  final ValueNotifier<double>? shrinkRatioNotifier;

  const PageLayout({
    super.key,
    this.header,
    required this.child,
    this.isHeaderSticky = true,
    this.shrinkRatioNotifier,
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
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (shrinkRatioNotifier != null) {
                      final offset = notification.metrics.pixels;
                      final newRatio = (offset / 150).clamp(0.0, 1.0);
                      final currentRatio = shrinkRatioNotifier!.value;
                      if ((newRatio - currentRatio).abs() > 0.01) {
                        shrinkRatioNotifier!.value = newRatio;
                      }
                    }
                    return false;
                  },
                  child: child,
                ),
              ),
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
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (shrinkRatioNotifier != null) {
                final offset = notification.metrics.pixels;
                final newRatio = (offset / 150).clamp(0.0, 1.0);
                final currentRatio = shrinkRatioNotifier!.value;
                if ((newRatio - currentRatio).abs() > 0.01) {
                  shrinkRatioNotifier!.value = newRatio;
                }
              }
              return false;
            },
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
        ),
      );
    }
  }
}
