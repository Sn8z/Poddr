import 'package:flutter/widgets.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/utils/gaps.dart';

class EmptyState extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        gapH32,
        icon,
        gapH16,
        Text(
          title,
          style: context.theme.textTheme.titleMedium.copyWith(
            color: context.theme.onSurfaceVariant,
          ),
        ),
        gapH8,
        Text(
          subtitle,
          style: context.theme.textTheme.bodyMedium.copyWith(
            color: context.theme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
