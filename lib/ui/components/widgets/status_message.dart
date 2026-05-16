import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';

class PoddrStatusMessage extends StatelessWidget {
  final String message;
  final bool isError;

  const PoddrStatusMessage({
    super.key,
    required this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isError
            ? theme.errorContainer.withAlpha(50)
            : theme.primaryContainer.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError
              ? theme.error.withAlpha(77)
              : theme.primary.withAlpha(77),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? LucideIcons.alertCircle : LucideIcons.info,
            size: 18,
            color: isError ? theme.error : theme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: context.theme.textTheme.bodySmall.copyWith(
                    color: isError ? theme.error : theme.primary,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
