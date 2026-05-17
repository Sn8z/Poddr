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
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: context.theme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: title != null || subtitle != null || actions.isNotEmpty,
            child: Row(
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
                        style: TextStyle(
                          color: context.theme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (subtitle != null)
                      Text(
                        subtitle ?? '',
                        style: TextStyle(
                          color:
                              context.theme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
          ),
          if (title != null || subtitle != null || actions.isNotEmpty) gapH8,
          ...children,
        ],
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const SearchBox({
    super.key,
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: context.theme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title ?? '',
              style: context.theme.textTheme.titleMedium.copyWith(
                    color: context.theme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          if (title != null) gapH8,
          ...children,
        ],
      ),
    );
  }
}
