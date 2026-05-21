import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poddr/core/theme/poddr_theme.dart';
import 'package:poddr/ui/utils/gaps.dart';

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
          color:
              isError ? theme.error.withAlpha(77) : theme.primary.withAlpha(77),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HugeIcon(
            icon: isError
                ? HugeIcons.strokeRoundedAlert01
                : HugeIcons.strokeRoundedAlertSquare,
            size: 18,
            color: isError ? theme.error : theme.primary,
          ),
          gapW12,
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
