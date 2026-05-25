import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/utils/gaps.dart';

class ContentBox extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget> actions;
  final List<Widget> children;

  const ContentBox({
    super.key,
    this.title,
    this.subtitle,
    this.actions = const [],
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedSliver(
      decoration: BoxDecoration(
        color: theme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      sliver: SliverPadding(
        padding: const EdgeInsets.all(8),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            if (title != null || subtitle != null || actions.isNotEmpty)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            Text(
                              title ?? '',
                              style: theme.textTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.primary,
                              ),
                            ),
                          if (subtitle != null)
                            Text(
                              subtitle ?? '',
                              style: theme.textTheme.labelMedium.copyWith(
                                color: theme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: actions,
                      ),
                    ],
                  ),
                  gapH8,
                ],
              ),
            ...children,
          ]),
        ),
      ),
    );
  }
}
